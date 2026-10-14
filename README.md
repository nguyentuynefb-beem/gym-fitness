# Hệ thống Quản lý Phòng Gym / Fitness (Titan Fitness)

**Đề 23 — Môn học: Triển khai và Quản trị Hệ thống Phần mềm**

## 1. Thông tin sinh viên

- **Họ và tên:** Nguyễn Đức Tuyên
- **MSSV:** DTC245200566
- **Lớp:** CNTT K23I
- **Hệ thống triển khai:** Docker Compose trên Ubuntu 24.04 LTS (WSL 2)

---

## 2. Kiến trúc hệ thống & Mạng (Network Architecture)

Hệ thống được thiết kế theo mô hình kiến trúc phân lớp an toàn (Defense in Depth) kết hợp bộ đôi cụm giám sát **Prometheus + Grafana** và cụm log tập trung **Loki + Promtail**:

```
[ Khách hàng / Quản trị viên ]               [ Kỹ sư Quản trị / Giám sát ]
             │                                              │
             │ (Cổng 80: Redirect -> 443)                   │ (Cổng 3001: Grafana UI)
             │ (Cổng 443: HTTPS Ingress)                    │ (Cổng 9090: Prometheus UI)
             │                                              │ (Cổng 3100: Loki API)
             ▼                                              ▼
    ┌─────────────────┐                            ┌─────────────────┐
    │  Nginx Gateway  │ (Image: nginx:1.27-alpine) │   Grafana 11.2  │ (Port 3001)
    └────────┬────────┘                            └────────┬────────┘
             │                                              │ (Truy vấn metrics & logs)
             │ (Mạng nội bộ 'frontend')                     ├────────────────────────┐
             ├───────────────────────┬─────────────▶┌───────▼─────────┐      ┌───────▼─────────┐
             │                       │              │ Prometheus 2.54 │      │    Loki 3.1     │
             ▼                       ▼              └────────┬────────┘      │   (Cổng 3100)   │
    ┌─────────────────┐     ┌─────────────────┐              │ (Metrics)     └───────▲─────────┘
    │   Node.js App   │     │   phpMyAdmin    │              ├────────┐              │ (Push logs)
    │  (Titan Fitness)│     │  (Cổng web DB)  │              │        │              │
    │  (User: node)   │     │ (Subpath /pma/) │              ▼        ▼              │
    │ (/metrics:3000) │     └────────┬────────┘     ┌─────────┐ ┌──────────┐ ┌───────┴─────────┐
    └────────┬────────┘              │              │  Nginx  │ │ cAdvisor │ │    Promtail     │
             │                       │              │Exporter │ │  (8080)  │ │   (Log Shipper) │
             │ (Mạng nội bộ 'backend' - Cô lập)     └─────────┘ └──────────┘ └───────▲─────────┘
             └───────────────────────┼──────────────┐        │                       │
                                     ▼              ▼        ▼ (Mạng backend)        ├────────────────┐
                            ┌─────────────────┐    ┌───────────────────┐             │ (Đọc file log) │
                            │  MySQL 8.4 DB   │◀───│  mysqld-exporter  │             ▼                ▼
                            │    (gym_db)     │    │    (Cổng 9104)    │      [ app_logs ]     [ nginx_logs ]
                            └─────────────────┘    └───────────────────┘       (/var/log/app)   (/var/log/nginx)
```

---

## 3. Các biện pháp Hardening & An toàn hệ thống (Tiêu chí 6)

1. **Network Isolation (Cô lập mạng):**
   - Mạng `backend` được cấu hình `internal: true`. Container CSDL MySQL và mysqld-exporter hoàn toàn không thể bị quét cổng hoặc kết nối từ bên ngoài host.
   - Các container `app` và `phpmyadmin` không mở cổng trực tiếp ra host. Mọi lưu lượng truy cập ứng dụng bắt buộc phải đi qua Reverse Proxy Nginx.
2. **Non-Root Container:**
   - Ứng dụng Node.js trong `app/Dockerfile` được phân quyền và thực thi dưới user unprivileged `node` (UID/GID 1000), tuân thủ nguyên tắc Least Privilege.
3. **Mật khẩu mạnh & Phân quyền CSDL:**
   - Mật khẩu tạo ngẫu nhiên bằng OpenSSL hex 24-byte (48 ký tự).
   - Ứng dụng web chỉ kết nối bằng tài khoản người dùng ứng dụng `gym_app`, không sử dụng tài khoản `root`.
4. **SSL/TLS & HTTPS:**
   - Tự động chuyển hướng toàn bộ lưu lượng HTTP (cổng 80) sang HTTPS (cổng 443) bằng mã phản hồi `301 Moved Permanently`.
   - Cấu hình chỉ chấp nhận giao thức hiện đại `TLSv1.2` và `TLSv1.3` với danh sách ciphers an toàn.
   - Hỗ trợ SAN (Subject Alternative Name) cho `localhost` và `127.0.0.1`.
5. **Nginx Security Headers & Tối ưu:**
   - `X-Frame-Options: SAMEORIGIN` (Chống tấn công Clickjacking).
   - `X-Content-Type-Options: nosniff` (Chống MIME-type sniffing).
   - `X-XSS-Protection: 1; mode=block` (Chống Cross-Site Scripting).
   - `Referrer-Policy: strict-origin-when-cross-origin`.
   - `Strict-Transport-Security: max-age=31536000; includeSubDomains`.
   - `server_tokens off`: Ẩn thông tin phiên bản Nginx trong response headers.
   - Giới hạn body upload (`client_max_body_size 25M`).
   - Cấu hình format log chi tiết thời gian phản hồi (`rt`, `uct`, `uht`, `urt`) phục vụ Promtail/Loki.

---

## 4. Hướng dẫn cài đặt & Khởi chạy

### Bước 1: Chuẩn bị biến môi trường
Sao chép cấu hình mẫu từ `.env.example`:
```bash
cp .env.example .env
```
*(Nếu cần tạo mới mật khẩu mạnh, có thể dùng lệnh `openssl rand -hex 24` để điền vào `MYSQL_PASSWORD` và `MYSQL_ROOT_PASSWORD`)*.

### Bước 2: Sinh chứng chỉ SSL (Tùy chọn nếu muốn tạo mới)
Chứng chỉ mặc định đã được tạo sẵn trong thư mục `nginx/ssl/`. Nếu muốn sinh lại:
```bash
bash nginx/ssl/generate-certs.sh
```

### Bước 3: Khởi động toàn bộ hệ thống bằng Docker Compose
```bash
docker compose up -d --build
```

Kiểm tra trạng thái các container:
```bash
docker compose ps
```

---

## 5. Hướng dẫn truy cập các dịch vụ

| Dịch vụ | Địa chỉ truy cập | Ghi chú & Tài khoản mặc định |
| :--- | :--- | :--- |
| **Website Titan Fitness (Trang chủ)** | `https://localhost/` | Tự động chuyển hướng từ `http://localhost/` |
| **Trang Quản trị Admin (Dashboard)** | `https://localhost/admin` | Quản lý hội viên, gói tập, lịch tập, HLV |
| **Quản lý Hội viên** | `https://localhost/admin/members` | Thêm, sửa, xóa, tìm kiếm hội viên |
| **Quản lý Gói tập** | `https://localhost/admin/packages` | Quản lý các gói tập gym, giá, thời hạn |
| **Quản lý Huấn luyện viên** | `https://localhost/admin/trainers` | Danh sách PT, chuyên môn, kinh nghiệm |
| **Quản lý Lịch tập** | `https://localhost/admin/schedules` | Xếp lịch tập theo khung giờ và phòng tập |
| **Công cụ Quản trị CSDL (phpMyAdmin)** | `https://localhost/pma/` | Đăng nhập bằng `gym_app` hoặc `root` |
| **Hệ thống Giám sát Grafana** | `http://localhost:3001` | **Tài khoản:** `admin` / `admin` (5 Dashboards sẵn có) |
| **Dashboard Log tập trung (Loki)** | `http://localhost:3001/d/titan-gym-loki-logs/centralized-logging-loki-promtail` | Giám sát stream log trực tiếp và phân tích lỗi |
| **Máy chủ Thu thập Prometheus** | `http://localhost:9090` | Xem danh sách Target tại `/targets` (Tất cả UP) |
| **Máy chủ Log tập trung Loki** | `http://localhost:3100/ready` | Trả về trạng thái `ready` của Loki engine |
| **Healthcheck Gateway (Nginx)** | `https://localhost/health` | Trả về trạng thái UP của Nginx |
| **Metrics Nginx (Stub Status)** | `https://localhost/stub_status` | Phục vụ Nginx Exporter cào dữ liệu |

---

## 6. Danh sách các câu truy vấn LogQL mẫu (Tiêu chí 5)

Hệ thống hỗ trợ đầy đủ cú pháp LogQL trên Grafana (Tab **Explore** ➔ Chọn DataSource **Loki**):

| Mục đích truy vấn | Câu lệnh LogQL |
| :--- | :--- |
| **1. Xem toàn bộ log hệ thống** | `{job=~"nginx|gym-app"}` |
| **2. Xem log JSON ứng dụng Node.js** | `{job="gym-app"} \| json` |
| **3. Lọc log cảnh báo / lỗi 404** | `{job="gym-app"} \| json \| level="warn"` |
| **4. Lọc log lỗi hệ thống (HTTP 500)** | `{job="gym-app"} \| json \| level="error"` |
| **5. Xem log truy cập Nginx** | `{job="nginx", log_type="access"}` |
| **6. Lọc các request lỗi từ Nginx** | `{job="nginx"} \| status >= 400` |
| **7. Đếm tốc độ log theo job (Metrics)** | `sum by (job) (rate({job=~"nginx|gym-app"}[1m]))` |

---

## 7. Lịch sử tiến độ thực hiện đề tài

- **Ngày 1 (`feature/day01-database-schema`)**:
  - Thiết kế Schema CSDL MySQL 8.4 chuẩn hóa (`db/init/001-schema.sql`).
  - Dữ liệu mẫu (Seed data) đầy đủ cho 5 bảng chính (`db/init/002-seed-data.sql`).
  - Cấu hình ban đầu `compose.yaml` (MySQL, Node.js App skeleton, phpMyAdmin).
- **Ngày 2 (`feature/day02-web-gym-app`)**:
  - Xây dựng giao diện Landing page chuyên nghiệp Titan Fitness (Giới thiệu, Gói tập, Đội ngũ PT, Lịch biểu, Form đăng ký tập thử).
  - Hoàn thiện toàn bộ Module quản trị Admin với đầy đủ tính năng CRUD: Thống kê Dashboard, Hội viên, Gói tập, Huấn luyện viên, Lịch tập.
  - Tích hợp kết nối Pool CSDL MySQL (`mysql2/promise`) bền bỉ và xử lý lỗi đồng bộ.
- **Ngày 3 (`feature/day03-nginx-reverse-proxy`)**:
  - Triển khai Nginx 1.27 Alpine làm Reverse Proxy & Ingress Gateway.
  - Cấu hình SSL tự ký (RSA 2048 SAN) và tự động redirect HTTP sang HTTPS.
  - Áp dụng các chính sách Hardening: Network Isolation, đóng cổng host trực tiếp, Non-root App container, bộ Security Headers chuẩn.
  - Cấu hình reverse proxy cho phpMyAdmin (`/pma/`) và Nginx metrics (`/stub_status`).
- **Ngày 4 (`feature/day04-monitoring-prometheus-grafana`)**:
  - Tích hợp thư viện `prom-client` vào ứng dụng Node.js, cung cấp endpoint `/metrics` chuẩn Prometheus.
  - Triển khai `mysqld-exporter:v0.15.1`, `nginx-prometheus-exporter:1.3.0`, `cAdvisor:v0.49.1`.
  - Cấu hình Prometheus 2.54 tự động scrape 5 targets với trạng thái UP 100%.
  - Tự động hóa hoàn toàn Grafana 11.2 (Provisioning) với Datasource Prometheus và 4 Dashboards chi tiết.
- **Ngày 5 (`feature/day05-logging-loki-promtail`)**:
  - Triển khai hệ thống ghi log tập trung Grafana **Loki 3.1** và **Promtail 3.1**.
  - Thiết lập luồng log kép cho Web App (Stdout + JSON File tại volume `app_logs`).
  - Thu thập và phân tích Nginx Access/Error logs (volume `nginx_logs`) với pipeline trích xuất status, method, latency.
  - Tự động nạp Loki DataSource và Dashboard `Centralized Logging (Loki & Promtail)` vào Grafana.
  - Xây dựng và nghiệm thu 7 câu lệnh LogQL mẫu, xuất báo cáo [day05-verification.txt](docs/evidence/day05-verification.txt).