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

## 3. Ma trận 6 Biện pháp Bảo mật Chuyên sâu & Hardening Đa tầng (Tiêu chí 6)

Hệ thống được thiết kế và bảo vệ đa tầng theo nguyên tắc **Defense in Depth** (Phòng thủ theo chiều sâu) và **Least Privilege** (Đặc quyền tối thiểu), bao phủ từ cổng ngõ Ingress Gateway đến Container, Mạng và Cơ sở Dữ liệu:

| STT | Tầng bảo vệ (Layer) | Biện pháp Hardening cụ thể | Cấu hình kỹ thuật hiện thực | Mục đích & Nguy cơ ngăn chặn | Minh chứng kiểm thử |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | **Ingress Gateway** | **Rate Limiting & DoS Protection** | `limit_req_zone` (10 req/s cho web chung, 2 req/s cho `/register-trial` và `/admin`), trả về mã `HTTP 429`. | Ngăn chặn tấn công vét cạn mật khẩu (Brute-force), spam bot và từ chối dịch vụ (DoS). | Test 2 trong `security-audit.sh`: 24/30 request dồn dập bị chặn với HTTP 429. |
| **2** | **Container Engine** | **Resource Limits (Cgroups)** | Khai báo trần CPU/RAM trong `compose.yaml`: MySQL (1GB/1 CPU), App (512MB/0.75 CPU), Nginx (256MB/0.5 CPU)... | Chống cạn kiệt tài nguyên máy chủ host, ngăn ngừa hiện tượng crash dây chuyền do OOM (Out of Memory). | Test 5 trong `security-audit.sh`: `docker stats --no-stream` hiển thị rõ giới hạn RAM từng container. |
| **3** | **Privilege Layer** | **Nguyên tắc Least Privilege & Non-Root** | Container App chạy user `node` (UID 1000), bật `security_opt: [no-new-privileges:true]`, thu hồi toàn bộ quyền thừa `cap_drop: [ALL]`. | Vô hiệu hóa nguy cơ leo thang đặc quyền (Container Breakout) hoặc can thiệp kernel máy chủ host. | Test 4 trong `security-audit.sh`: Xác nhận UID=1000(node), không có quyền root. |
| **4** | **Network Layer** | **Network Segmentation (Cô lập CSDL)** | Mạng `backend` cấu hình `internal: true`. Cổng MySQL 3306 hoàn toàn không publish ra máy host. | Ngăn chặn kẻ tấn công dò quét cổng hoặc khai thác CSDL trực tiếp từ mạng bên ngoài. | Test 1 trong `security-audit.sh`: Quét cổng 3306 trả về `Connection Refused` 100%. |
| **5** | **Database Layer** | **Phân quyền tối thiểu & Mật khẩu mạnh** | Ứng dụng chỉ kết nối qua user `gym_app` với quyền hạn chế trên `gym_db`. Mật khẩu OpenSSL ngẫu nhiên hex 48 ký tự. | Ngăn chặn chiếm quyền quản trị server CSDL ngay cả khi ứng dụng bị tấn công SQL Injection. | Biến môi trường `.env` phân tách tài khoản root và user ứng dụng riêng biệt. |
| **6** | **Web & Transport** | **Bộ Security Headers & Modern TLS** | Cấu hình chỉ hỗ trợ `TLSv1.2` / `TLSv1.3`, tự động chuyển hướng 301 sang HTTPS. Trang bị 8 tiêu chí Security Headers (`CSP`, `HSTS`, `X-Frame-Options`, `nosniff`...). | Chống tấn công Clickjacking, MIME-sniffing, XSS, Man-in-the-Middle và nghe lén dữ liệu. | Test 3 trong `security-audit.sh`: Quét và xác nhận 8/8 tiêu chí Security Headers. |

### 🛠️ Kịch bản Kiểm thử Bảo mật Tự động (`security-audit.sh`)

Toàn bộ 5 kịch bản kiểm thử bảo mật đã được tự động hóa trong file script [`security-audit.sh`](security-audit.sh):
```bash
# Thực hiện kiểm thử bảo mật tự động
bash security-audit.sh
```

Báo cáo nghiệm thu chi tiết được lưu trữ tại: [`docs/evidence/day06-verification.txt`](docs/evidence/day06-verification.txt).

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
- **Ngày 6 (`feature/day06-security-hardening`)**:
  - Triển khai toàn diện 6 biện pháp Security Hardening đa tầng (Gateway, Container, Privilege, Network, Database, Web & Transport).
  - Cấu hình Nginx Rate Limiting (`limit_req_zone`) chống DoS/Brute-force với mã phản hồi `HTTP 429 Too Many Requests`.
  - Khai báo trần giới hạn CPU/RAM (Resource Limits / Cgroups) cho 100% container trong `compose.yaml`.
  - Thực thi nguyên tắc Least Privilege: container chạy Non-Root (`node` UID 1000), `security_opt: [no-new-privileges:true]`, thu hồi toàn bộ quyền thừa `cap_drop: [ALL]`.
  - Cô lập mạng CSDL MySQL 2 lớp (`internal: true`, không publish port 3306 ra host).
  - Phân quyền người dùng tối thiểu cho `gym_app` cùng mật khẩu ngẫu nhiên OpenSSL hex 48 ký tự.
  - Trang bị đầy đủ 8 tiêu chí Security Headers (`Content-Security-Policy`, `HSTS`, `X-Frame-Options`, `X-Content-Type-Options`, `Permissions-Policy`, `server_tokens off`).
  - Xây dựng kịch bản kiểm thử bảo mật tự động [`security-audit.sh`](security-audit.sh) với 5 bài test xâm nhập giả lập (đạt tỷ lệ 5/5 Pass 100%).
  - Xuất báo cáo nghiệm thu bảo mật [day06-verification.txt](docs/evidence/day06-verification.txt).