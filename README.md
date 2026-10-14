# Hệ thống Quản lý Phòng Gym / Fitness (Titan Fitness)

**Đề 23 — Môn học: Triển khai và Quản trị Hệ thống Phần mềm**

## 1. Thông tin sinh viên

- **Họ và tên:** Nguyễn Đức Tuyên
- **MSSV:** DTC245200566
- **Lớp:** CNTT K23I
- **Hệ thống triển khai:** Docker Compose trên Ubuntu 24.04 LTS (WSL 2)

---

## 2. Kiến trúc hệ thống & Mạng (Network Architecture)

Hệ thống được thiết kế theo mô hình kiến trúc phân lớp an toàn (Defense in Depth) với Nginx đóng vai trò là Reverse Proxy & Ingress Gateway duy nhất:

```
[ Khách hàng / Quản trị viên ]
             │
             │ (Cổng 80: HTTP Redirect -> HTTPS)
             │ (Cổng 443: HTTPS với SSL tự ký & Security Headers)
             ▼
    ┌─────────────────┐
    │  Nginx Gateway  │ (Image: nginx:1.27-alpine)
    └────────┬────────┘
             │ (Mạng nội bộ 'frontend')
             ├───────────────────────────────────┐
             ▼                                   ▼
    ┌─────────────────┐                 ┌─────────────────┐
    │   Node.js App   │                 │   phpMyAdmin    │
    │  (Titan Fitness)│                 │  (Cổng web DB)  │
    │ (User: node)    │                 │ (Subpath /pma/) │
    └────────┬────────┘                 └────────┬────────┘
             │                                   │
             │ (Mạng nội bộ 'backend' - Cô lập)  │
             └─────────────────┬─────────────────┘
                               ▼
                      ┌─────────────────┐
                      │  MySQL 8.4 DB   │ (Chỉ kết nối nội bộ,
                      │    (gym_db)     │  không mở cổng ra host)
                      └─────────────────┘
```

---

## 3. Các biện pháp Hardening & An toàn hệ thống (Tiêu chí 6)

1. **Network Isolation (Cô lập mạng):**
   - Mạng `backend` được cấu hình `internal: true`. Container CSDL MySQL hoàn toàn không thể bị quét cổng hoặc kết nối từ bên ngoài host.
   - Các container `app` và `phpmyadmin` không mở cổng trực tiếp ra host (đóng các cổng 18080 và 18081). Mọi lưu lượng bắt buộc phải đi qua Reverse Proxy Nginx.
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

| Dịch vụ | Địa chỉ truy cập | Ghi chú |
| :--- | :--- | :--- |
| **Website Titan Fitness (Trang chủ)** | `https://localhost/` | Tự động chuyển hướng từ `http://localhost/` |
| **Trang Quản trị Admin (Dashboard)** | `https://localhost/admin` | Quản lý hội viên, gói tập, lịch tập, HLV |
| **Quản lý Hội viên** | `https://localhost/admin/members` | Thêm, sửa, xóa, tìm kiếm hội viên |
| **Quản lý Gói tập** | `https://localhost/admin/packages` | Quản lý các gói tập gym, giá, thời hạn |
| **Quản lý Huấn luyện viên** | `https://localhost/admin/trainers` | Danh sách PT, chuyên môn, kinh nghiệm |
| **Quản lý Lịch tập** | `https://localhost/admin/schedules` | Xếp lịch tập theo khung giờ và phòng tập |
| **Công cụ Quản trị CSDL (phpMyAdmin)** | `https://localhost/pma/` | Đăng nhập bằng `gym_app` hoặc `root` |
| **Healthcheck Gateway** | `https://localhost/health` | Trả về trạng thái UP của Nginx |
| **Metrics Nginx (Stub Status)** | `https://localhost/stub_status` | Phục vụ Prometheus cào dữ liệu |

---

## 6. Lịch sử tiến độ thực hiện đề tài

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
