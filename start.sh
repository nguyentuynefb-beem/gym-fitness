#!/usr/bin/env bash
# ====================================================================
# TITAN FITNESS - KHỞI CHẠY TOÀN BỘ HỆ THỐNG (BACKEND & FRONTEND)
# Hệ thống quản trị phòng Gym chuyên nghiệp
# Hỗ trợ: Docker Compose trên Ubuntu / WSL 2
# ====================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_DIR}"

# Định nghĩa màu sắc ANSI
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ==============================================================="
    echo "    TITAN FITNESS - KHỞI CHẠY HỆ THỐNG (BACKEND & FRONTEND)"
    echo "    Đề tài 23: Triển khai và Quản trị Hệ thống Phần mềm"
    echo "    Môi trường: Docker Compose trên Ubuntu 24.04 LTS (WSL 2)"
    echo "  ==============================================================="
    echo -e "${NC}"
}

check_prerequisites() {
    echo -e "${BLUE}[1/4] Kiểm tra các điều kiện tiên quyết...${NC}"
    
    # 1. Kiểm tra Docker CLI
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}[LỖI] Docker chưa được cài đặt. Vui lòng cài đặt Docker trước khi tiếp tục.${NC}"
        exit 1
    fi

    # 2. Kiểm tra Docker Daemon đang hoạt động
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}[LỖI] Docker daemon chưa được khởi động!${NC}"
        echo -e "${YELLOW}Gợi ý: Hãy mở ứng dụng Docker Desktop trên Windows hoặc chạy lệnh 'sudo service docker start'.${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}✓${NC} Docker daemon đang hoạt động tốt."

    # 3. Kiểm tra Docker Compose
    if ! docker compose version >/dev/null 2>&1; then
        echo -e "${RED}[LỖI] 'docker compose' không khả dụng.${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}✓${NC} Docker Compose plugin đã sẵn sàng."

    # 4. Kiểm tra file cấu hình .env
    echo -e "${BLUE}[2/4] Kiểm tra cấu hình môi trường (.env)...${NC}"
    if [ ! -f ".env" ]; then
        echo -e "  ${YELLOW}! Chưa tìm thấy file .env, đang tự động tạo từ .env.example...${NC}"
        if [ -f ".env.example" ]; then
            cp .env.example .env
            RAND_PASS_APP=$(openssl rand -hex 16 2>/dev/null || date +%s | sha256sum | base64 | head -c 24)
            RAND_PASS_ROOT=$(openssl rand -hex 16 2>/dev/null || date +%s | sha256sum | base64 | head -c 24)
            sed -i "s/REPLACE_WITH_RANDOM_PASSWORD/${RAND_PASS_APP}/g" .env
            sed -i "s/REPLACE_WITH_DIFFERENT_RANDOM_PASSWORD/${RAND_PASS_ROOT}/g" .env
            echo -e "  ${GREEN}✓${NC} Đã tạo file .env thành công với mật khẩu bảo mật ngẫu nhiên."
        else
            echo -e "${RED}[LỖI] Không tìm thấy file .env.example để khởi tạo cấu hình.${NC}"
            exit 1
        fi
    else
        echo -e "  ${GREEN}✓${NC} File cấu hình .env đã sẵn sàng."
    fi

    # 5. Kiểm tra chứng chỉ SSL Nginx
    echo -e "${BLUE}[3/4] Kiểm tra chứng chỉ SSL/TLS cho HTTPS...${NC}"
    if [ ! -f "nginx/ssl/server.crt" ] || [ ! -f "nginx/ssl/server.key" ]; then
        echo -e "  ${YELLOW}! Thiếu chứng chỉ SSL, đang tự động sinh chứng chỉ SSL tự ký (RSA 2048 SAN)...${NC}"
        if [ -f "nginx/ssl/generate-certs.sh" ]; then
            bash nginx/ssl/generate-certs.sh
            echo -e "  ${GREEN}✓${NC} Đã tạo chứng chỉ SSL thành công."
        else
            echo -e "${RED}[LỖI] Không tìm thấy script nginx/ssl/generate-certs.sh.${NC}"
            exit 1
        fi
    else
        echo -e "  ${GREEN}✓${NC} Chứng chỉ SSL (server.crt & server.key) đã tồn tại."
    fi
}

wait_for_services() {
    echo -e "\n${BLUE}[4/4] Khởi động và kiểm tra sức khỏe các dịch vụ (Healthcheck)...${NC}"
    
    # Khởi chạy Docker Compose (Build lại app nếu có thay đổi)
    docker compose up -d --build

    echo -e "\n${YELLOW}Đang đợi các dịch vụ trọng yếu (MySQL, Node.js App, Nginx) đạt trạng thái Healthy...${NC}"
    
    local max_retries=30
    local count=0
    local app_ready=0
    local mysql_ready=0
    local nginx_ready=0

    while [ $count -lt $max_retries ]; do
        sleep 2
        count=$((count + 1))
        
        # Kiểm tra MySQL
        if [ $mysql_ready -eq 0 ]; then
            if [ "$(docker inspect -f '{{.State.Health.Status}}' gym-fitness-mysql-1 2>/dev/null || true)" = "healthy" ]; then
                mysql_ready=1
                echo -e "  ${GREEN}✓${NC} Cơ sở dữ liệu MySQL 8.4: SẴN SÀNG (Healthy)"
            fi
        fi

        # Kiểm tra App Node.js (Full-stack Backend & Frontend EJS)
        if [ $app_ready -eq 0 ]; then
            if [ "$(docker inspect -f '{{.State.Health.Status}}' gym-fitness-app-1 2>/dev/null || true)" = "healthy" ]; then
                app_ready=1
                echo -e "  ${GREEN}✓${NC} Ứng dụng Titan Fitness (Backend & Frontend): SẴN SÀNG (Healthy)"
            fi
        fi

        # Kiểm tra Nginx Ingress
        if [ $nginx_ready -eq 0 ]; then
            if [ "$(docker inspect -f '{{.State.Health.Status}}' gym-fitness-nginx-1 2>/dev/null || true)" = "healthy" ]; then
                nginx_ready=1
                echo -e "  ${GREEN}✓${NC} Cổng Ingress Gateway Nginx (TLS/HTTPS): SẴN SÀNG (Healthy)"
            fi
        fi

        if [ $mysql_ready -eq 1 ] && [ $app_ready -eq 1 ] && [ $nginx_ready -eq 1 ]; then
            break
        fi
        echo -n "."
    done
    echo ""

    if [ $mysql_ready -eq 1 ] && [ $app_ready -eq 1 ] && [ $nginx_ready -eq 1 ]; then
        echo -e "${GREEN}${BOLD}>>> TOÀN BỘ HỆ THỐNG ĐÃ SẴN SÀNG VÀ CHẠY ỔN ĐỊNH 100%! <<<${NC}"
    else
        echo -e "${YELLOW}Lưu ý: Một số dịch vụ vẫn đang hoàn tất khởi động. Bạn có thể kiểm tra qua './start.sh status'.${NC}"
    fi
}

show_urls() {
    echo -e "\n${CYAN}======================================================================${NC}"
    echo -e "${BOLD}         BẢNG ĐIỀU HƯỚNG TRUY CẬP HỆ THỐNG TITAN FITNESS             ${NC}"
    echo -e "${CYAN}======================================================================${NC}"
    printf "%-35s | %-32s\n" "Dịch vụ" "Địa chỉ truy cập (URL)"
    echo "------------------------------------+---------------------------------"
    printf "${GREEN}%-35s${NC} | ${BOLD}%-32s${NC}\n" "1. Website Titan Fitness (Trang chủ)" "https://localhost/"
    printf "${GREEN}%-35s${NC} | ${BOLD}%-32s${NC}\n" "2. Trang Quản trị Admin (Dashboard)" "https://localhost/admin"
    printf "%-35s | %-32s\n" "3. Quản lý Cơ sở dữ liệu (phpMyAdmin)" "https://localhost/pma/"
    printf "%-35s | %-32s\n" "4. Hệ thống Giám sát (Grafana UI)" "http://localhost:3001"
    printf "%-35s | %-32s\n" "5. Thu thập chỉ số (Prometheus UI)" "http://localhost:9090"
    printf "%-35s | %-32s\n" "6. API Log tập trung (Loki Ready)" "http://localhost:3100/ready"
    printf "%-35s | %-32s\n" "7. Healthcheck Gateway Nginx" "https://localhost/health"
    echo -e "${CYAN}======================================================================${NC}"
    echo -e "${YELLOW}* Thông tin đăng nhập mặc định:${NC}"
    echo -e "  - Grafana Dashboard: Tài khoản ${BOLD}admin${NC} / Mật khẩu ${BOLD}admin${NC}"
    echo -e "  - phpMyAdmin: Tài khoản ${BOLD}gym_app${NC} hoặc ${BOLD}root${NC} (Xem mật khẩu trong file .env)"
    echo -e "${YELLOW}* Lưu ý chứng chỉ SSL:${NC} Do sử dụng chứng chỉ tự ký (Self-signed), vui lòng bấm 'Nâng cao' (Advanced) -> 'Tiếp tục truy cập' (Proceed to localhost) khi mở trình duyệt."
    echo -e "\n${BOLD}Các lệnh tiện ích thao tác nhanh:${NC}"
    echo -e "  - Xem trạng thái 11 container: ${CYAN}./start.sh status${NC}"
    echo -e "  - Xem logs realtime Web & App: ${CYAN}./start.sh logs${NC}"
    echo -e "  - Xem logs toàn bộ dịch vụ:   ${CYAN}./start.sh logs-all${NC}"
    echo -e "  - Khởi động lại hệ thống:      ${CYAN}./start.sh restart${NC}"
    echo -e "  - Dừng toàn bộ hệ thống:       ${CYAN}./start.sh stop${NC}"
    echo -e "  - Chạy kiểm thử bảo mật 6 tầng: ${CYAN}./start.sh audit${NC}"
    echo -e "${CYAN}======================================================================${NC}\n"
}

action_stop() {
    print_banner
    echo -e "${YELLOW}Đang dừng toàn bộ các container hệ thống Titan Fitness...${NC}"
    docker compose down
    echo -e "${GREEN}✓ Toàn bộ hệ thống đã được dừng thành công.${NC}"
}

action_restart() {
    print_banner
    echo -e "${YELLOW}Đang khởi động lại toàn bộ dịch vụ...${NC}"
    docker compose restart
    wait_for_services
    show_urls
}

action_status() {
    print_banner
    echo -e "${BLUE}Trạng thái hiện tại của toàn bộ 11 container:${NC}\n"
    docker compose ps
}

action_logs() {
    echo -e "${CYAN}Đang theo dõi log thời gian thực của App Node.js và Nginx Gateway... (Nhấn Ctrl+C để thoát)${NC}\n"
    docker compose logs -f --tail=100 app nginx
}

action_logs_all() {
    echo -e "${CYAN}Đang theo dõi toàn bộ log 11 dịch vụ... (Nhấn Ctrl+C để thoát)${NC}\n"
    docker compose logs -f --tail=50
}

action_audit() {
    print_banner
    if [ -f "security-audit.sh" ]; then
        echo -e "${CYAN}Bắt đầu chạy kịch bản kiểm thử bảo mật đa tầng tự động...${NC}\n"
        bash security-audit.sh
    else
        echo -e "${RED}[LỖI] Không tìm thấy file security-audit.sh.${NC}"
    fi
}

ACTION="${1:-up}"

case "${ACTION}" in
    up|start)
        print_banner
        check_prerequisites
        wait_for_services
        show_urls
        ;;
    down|stop)
        action_stop
        ;;
    restart)
        action_restart
        ;;
    status|ps)
        action_status
        ;;
    logs)
        action_logs
        ;;
    logs-all)
        action_logs_all
        ;;
    audit)
        action_audit
        ;;
    help|--help|-h)
        print_banner
        echo "Cách sử dụng: ./start.sh [LỆNH]"
        echo ""
        echo "Danh sách lệnh hỗ trợ:"
        echo "  up | start       (Mặc định) Build và khởi chạy toàn bộ hệ thống (Back, Front, DB, Monitor)"
        echo "  down | stop      Dừng toàn bộ hệ thống container"
        echo "  restart          Khởi động lại toàn bộ dịch vụ"
        echo "  status | ps      Kiểm tra trạng thái các container và healthcheck"
        echo "  logs             Xem log thời gian thực của Web App và Nginx Ingress"
        echo "  logs-all         Xem log toàn bộ 11 dịch vụ"
        echo "  audit            Chạy bài test bảo mật đa tầng (security-audit.sh)"
        echo "  help             Hiển thị thông tin hướng dẫn này"
        echo ""
        ;;
    *)
        echo -e "${RED}Lệnh không hợp lệ: '${ACTION}'${NC}"
        echo "Chạy './start.sh help' để xem danh sách các lệnh được hỗ trợ."
        exit 1
        ;;
esac
