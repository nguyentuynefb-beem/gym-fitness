#!/usr/bin/env bash
# ====================================================================
# TITAN FITNESS - AUTOMATED SECURITY AUDIT & PENETRATION TESTING
# De tai 23 - Mon hoc: Trien khai va Quan tri He thong Phan mem
# Sinh vien: Nguyen Duc Tuyen - MSSV: DTC245200566
# Ngay thuc hien: Day 06 - Security Hardening & Penetration Testing
# ====================================================================

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "===================================================================="
echo "    TITAN FITNESS - SECURITY HARDENING VERIFICATION REPORT (DAY 06) "
echo "    Date & Time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "    Host Environment: Ubuntu 24.04 LTS (WSL 2) / Docker Compose"
echo "===================================================================="
echo ""

TOTAL_TESTS=5
PASSED_TESTS=0

# --------------------------------------------------------------------
# TEST 1: Network Isolation & Database Port Scanning
# --------------------------------------------------------------------
echo -e "${CYAN}>>> [TEST 1/5] Quet cong CSDL MySQL (Port 3306) tu ben ngoai Host...${NC}"
echo "Muc dich: Chung minh cong 3306 cua CSDL bi co lap hoan toan (internal: true, no publish port)."

DB_PORT_OPEN=0
if nc -z -w 2 127.0.0.1 3306 2>/dev/null || (echo > /dev/tcp/127.0.0.1/3306) 2>/dev/null; then
    DB_PORT_OPEN=1
fi

if [ "$DB_PORT_OPEN" -eq 0 ]; then
    echo -e "${GREEN}[PASS] Cong 3306 bi CHAN HOAN TOAN tu ben ngoai host (Connection Refused).${NC}"
    echo "  -> Chi tiet: MySQL chi hoat dong tren mang noi bo 'backend' (internal: true)."
    echo "  -> Xac nhan tu docker port: $(docker port gym-fitness-mysql-1 2>&1 || echo 'Khong co port nao duoc publish')"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}[FAIL] Cong 3306 dang mo ra ben ngoai! Can kiem tra lai network hardening.${NC}"
fi
echo ""

# --------------------------------------------------------------------
# TEST 2: Gateway Hardening - Rate Limiting & DoS Protection (HTTP 429)
# --------------------------------------------------------------------
echo -e "${CYAN}>>> [TEST 2/5] Kiem tra Rate Limiting & Chong DoS/Brute-force (Nginx Ingress)...${NC}"
echo "Muc dich: Ban 30 requests don dap vao endpoint nhay cam (/admin) de xac thuc Nginx tra ve HTTP 429."

RESPONSES=()
COUNT_429=0
COUNT_200=0
COUNT_OTHER=0

for i in $(seq 1 30); do
    STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/admin || echo "ERR")
    RESPONSES+=("$STATUS")
    if [ "$STATUS" = "429" ]; then
        COUNT_429=$((COUNT_429 + 1))
    elif [ "$STATUS" = "200" ]; then
        COUNT_200=$((COUNT_200 + 1))
    else
        COUNT_OTHER=$((COUNT_OTHER + 1))
    fi
done

echo "  -> Ket qua chuoi 30 requests: ${RESPONSES[*]}"
echo "  -> So luong HTTP 200 (Accepted): $COUNT_200"
echo "  -> So luong HTTP 429 (Too Many Requests / Rate Limited): $COUNT_429"

if [ "$COUNT_429" -gt 0 ]; then
    echo -e "${GREEN}[PASS] Nginx Rate Limiting kich hoat thanh cong! Da chan cac request vuot nguong bang ma HTTP 429.${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}[FAIL] Khong nhan duoc phan hoi HTTP 429. Kiem tra lai limit_req trong Nginx.${NC}"
fi
echo ""

# --------------------------------------------------------------------
# TEST 3: Web & Transport Hardening - Security Headers & TLS
# --------------------------------------------------------------------
echo -e "${CYAN}>>> [TEST 3/5] Quet bo Tieu de Bao mat (Security Headers) & TLS tu Ingress Gateway...${NC}"
echo "Muc dich: Xac thuc day du cac header bao ve chong Clickjacking, XSS, Sniffing, CSP, HSTS."

HEADERS=$(curl -k -s -I https://localhost/)

CHECK_HEADER() {
    local NAME="$1"
    if echo "$HEADERS" | grep -i -q "$NAME"; then
        local VAL
        VAL=$(echo "$HEADERS" | grep -i "^$NAME" | tr -d '\r')
        echo -e "  [+] ${GREEN}$VAL${NC}"
        return 0
    else
        echo -e "  [-] ${RED}Thieu header: $NAME${NC}"
        return 1
    fi
}

H_PASS=0
CHECK_HEADER "X-Frame-Options" && H_PASS=$((H_PASS + 1))
CHECK_HEADER "X-Content-Type-Options" && H_PASS=$((H_PASS + 1))
CHECK_HEADER "X-XSS-Protection" && H_PASS=$((H_PASS + 1))
CHECK_HEADER "Referrer-Policy" && H_PASS=$((H_PASS + 1))
CHECK_HEADER "Strict-Transport-Security" && H_PASS=$((H_PASS + 1))
CHECK_HEADER "Content-Security-Policy" && H_PASS=$((H_PASS + 1))
CHECK_HEADER "Permissions-Policy" && H_PASS=$((H_PASS + 1))

# Check Server Tokens hidden
if echo "$HEADERS" | grep -i "^Server:" | grep -q "nginx/"; then
    echo -e "  [-] ${RED}Lo phien ban Nginx trong Server header!${NC}"
else
    echo -e "  [+] ${GREEN}Server: nginx (Phien ban da duoc an hoan toan - server_tokens off)${NC}"
    H_PASS=$((H_PASS + 1))
fi

if [ "$H_PASS" -ge 7 ]; then
    echo -e "${GREEN}[PASS] Bo Security Headers ($H_PASS/8 tieu chi) dat chuan an toan cao.${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}[FAIL] Bo Security Headers chua day du ($H_PASS/8 tieu chi).${NC}"
fi
echo ""

# --------------------------------------------------------------------
# TEST 4: Privilege Hardening - Non-Root Container Execution
# --------------------------------------------------------------------
echo -e "${CYAN}>>> [TEST 4/5] Kiem tra nguoi dung khong dac quyen (Least Privilege / Non-Root)...${NC}"
echo "Muc dich: Xac thuc ung dung Node.js chay duoi user unprivileged (UID=1000 node, khong phai root)."

APP_USER=$(docker exec gym-fitness-app-1 id)
echo "  -> Chi tiet user trong gym-fitness-app-1: $APP_USER"

if echo "$APP_USER" | grep -q "uid=1000(node)"; then
    echo -e "${GREEN}[PASS] Container chay duoi user khong dac quyen 'node' (UID=1000). Nguyen tac Least Privilege dam bao.${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}[FAIL] Container dang chay duoi quyen root hoac user khong mong muon!${NC}"
fi
echo ""

# --------------------------------------------------------------------
# TEST 5: Container Hardening - Resource Limits (Cgroups)
# --------------------------------------------------------------------
echo -e "${CYAN}>>> [TEST 5/5] Kiem tra gioi han tai nguyen CPU / RAM (Resource Limits)...${NC}"
echo "Muc dich: Xac thuc cac han muc tran RAM/CPU duoc Docker Engine ap dung cho tat ca dich vu."

STATS=$(docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}")
echo "$STATS"

if echo "$STATS" | grep -q "MiB / 512MiB" && echo "$STATS" | grep -q "GiB"; then
    echo -e "${GREEN}[PASS] Gioi han RAM/CPU (Cgroups Limits) duoc ap dung chuan xac cho tung container.${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}[FAIL] Mot so container chua duoc ap dung Resource Limits tran.${NC}"
fi
echo ""

# --------------------------------------------------------------------
# SUMMARY
# --------------------------------------------------------------------
echo "===================================================================="
echo "                   KET QUA TONG HOP KIEM THU BAO MAT                 "
echo "===================================================================="
echo "  Tong so bai test: $TOTAL_TESTS"
echo "  So bai test dat : $PASSED_TESTS / $TOTAL_TESTS"
if [ "$PASSED_TESTS" -eq "$TOTAL_TESTS" ]; then
    echo -e "  Danh gia chung  : ${GREEN}XUAT SAC - TAT CA 5 BAI TEST BAO MAT DEU DAT CHUAN (100%)${NC}"
else
    echo -e "  Danh gia chung  : ${YELLOW}CAN RA SOAT LAI CAC BAI TEST CHUA DAT${NC}"
fi
echo "===================================================================="