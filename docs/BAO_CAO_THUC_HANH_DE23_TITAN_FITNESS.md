TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN VÀ TRUYỀN THÔNG
KHOA CÔNG NGHỆ THÔNG TIN

---

# BÁO CÁO THỰC HÀNH
### MÔN: TRIỂN KHAI VÀ QUẢN TRỊ HỆ THỐNG PHẦN MỀM

## ĐỀ 23: WEBSITE QUẢN LÝ PHÒNG TẬP GYM / FITNESS (TITAN FITNESS)

- **Sinh viên thực hiện:** Nguyễn Đức Tuyên
- **Mã sinh viên:** DTC245200566
- **Lớp:** CNTT K23I
- **Giảng viên hướng dẫn:** ThS. Lê Khánh Dương
- **Hệ thống triển khai:** Docker Compose trên nền tảng Ubuntu 24.04 LTS (WSL 2)
- **Kho mã nguồn GitHub:** https://github.com/nguyentuynefb-beem/gym-fitness.git

---

# LỜI CẢM ƠN

Trước hết, em xin gửi lời cảm ơn chân thành và sâu sắc nhất đến giảng viên bộ môn - ThS. Lê Khánh Dương cùng toàn thể quý thầy cô tại Khoa Công nghệ Thông tin, Trường Đại học Công nghệ Thông tin và Truyền thông đã tận tình truyền đạt những kiến thức nền tảng và chuyên sâu trong môn học **Triển khai và Quản trị Hệ thống Phần mềm**.

Những chuyên đề học tập về ảo hóa container bằng Docker, điều phối dịch vụ với Docker Compose, định tuyến mạng với Nginx Reverse Proxy, mã hóa an toàn qua SSL/TLS, hệ thống thu thập chỉ số Prometheus kết hợp trực quan hóa Grafana, tập trung và phân tích nhật ký (Centralized Logging) bằng bộ công cụ Loki - Promtail - LogQL, cùng các nguyên lý tối quan trọng về an toàn thông tin (Defense in Depth, Least Privilege, Hardening) đã trang bị cho em nền tảng tư duy vững chắc để hiện thực hóa đồ án này.

Trong quá trình thực hiện **Đề tài 23: "Hệ thống Quản lý Phòng Gym / Fitness (Titan Fitness)"**, em đã có cơ hội vận dụng trọn vẹn toàn bộ kiến thức được học vào một kịch bản kỹ thuật thực tế, xây dựng một hệ thống hoạt động ổn định, có tính sẵn sàng cao, được giám sát tự động hóa và bảo vệ đa tầng theo tiêu chuẩn công nghiệp hiện đại.

Mặc dù đã nỗ lực nghiên cứu và hoàn thiện hệ thống một cách chỉn chu, bài báo cáo khó tránh khỏi những hạn chế nhất định. Em rất mong nhận được những lời nhận xét, góp ý quý báu từ thầy cô để tiếp tục cải thiện sản phẩm cũng như nâng cao năng lực chuyên môn trong lĩnh vực DevOps và Quản trị hạ tầng phần mềm.

*Em xin chân thành cảm ơn!*

---

# MỤC LỤC

1. [GIỚI THIỆU ĐỀ TÀI](#1-giới-thiệu-đề-tài)
   - 1.1. Mục tiêu
   - 1.2. Phạm vi
   - 1.3. Kết quả đạt được
2. [YÊU CẦU VÀ CÔNG NGHỆ SỬ DỤNG](#2-yêu-cầu-và-công-nghệ-sử-dụng)
   - 2.1. Yêu cầu của đề tài
   - 2.2. Bảng công nghệ sử dụng
   - 2.3. Môi trường triển khai
3. [KIẾN TRÚC VÀ CẤU TRÚC HỆ THỐNG](#3-kiến-trúc-và-cấu-trúc-hệ-thống)
   - 3.1. Kiến trúc phân tầng tổng thể
   - 3.2. Thiết kế các mạng Docker phân lập
   - 3.3. Cấu trúc thư mục dự án chuẩn hóa
4. [TRIỂN KHAI WEBSITE, MYSQL VÀ PHPMYADMIN](#4-triển-khai-website-mysql-và-phpmyadmin)
   - 4.1. Triển khai bằng Docker Compose
   - 4.2. Cấu hình CSDL MySQL 8.4 và cấu trúc dữ liệu
   - 4.3. Ứng dụng Web Titan Fitness (Node.js & Express)
   - 4.4. Công cụ quản trị CSDL phpMyAdmin
5. [CẤU HÌNH NGINX REVERSE PROXY VÀ SSL/TLS](#5-cấu-hình-nginx-reverse-proxy-và-ssltls)
   - 5.1. Mục đích và vai trò Ingress Gateway
   - 5.2. Cấu hình định tuyến Proxy và Chứng chỉ SSL/TLS tự ký SAN
   - 5.3. Bộ tiêu đề bảo mật (Security Headers) và Chống DoS bằng Rate Limiting
   - 5.4. Chuẩn hóa định dạng Access Log và Error Log
6. [GIÁM SÁT VỚI PROMETHEUS VÀ GRAFANA](#6-giám-sát-với-prometheus-và-grafana)
   - 6.1. Cấu hình Prometheus Server và 5 targets giám sát
   - 6.2. Các bộ thu thập chỉ số (Exporters)
   - 6.3. Hệ thống 4 Dashboards chuyên sâu trên Grafana
   - 6.4. Đánh giá kết quả giám sát tài nguyên và hiệu năng
7. [TẬP TRUNG LOG VỚI LOKI, PROMTAIL VÀ LOGQL](#7-tập-trung-log-với-loki-promtail-và-logql)
   - 7.1. Cấu hình hệ thống lưu trữ log Loki
   - 7.2. Tác nhân thu thập nhật ký Promtail
   - 7.3. Các kịch bản truy vấn và phân tích với LogQL
8. [HARDENING VÀ CÁC BIỆN PHÁP BẢO MẬT ĐA TẦNG](#8-hardening-và-các-biện-pháp-bảo-mật-đa-tầng)
   - 8.1. Cô lập mạng cơ sở dữ liệu (Network Segmentation)
   - 8.2. Ngăn chặn leo thang đặc quyền (no-new-privileges & cap_drop)
   - 8.3. Thực thi tài khoản không đặc quyền (Non-Root UID 1000)
   - 8.4. Giới hạn tài nguyên hệ thống (Linux Cgroups limits)
   - 8.5. Hệ thống tập tin chỉ đọc, phân quyền bí mật và ngoại lệ cAdvisor
9. [QUẢN LÝ MÃ NGUỒN VÀ CẤU HÌNH TRÊN GITHUB](#9-quản-lý-mã-nguồn-và-cấu-hình-trên-github)
   - 9.1. Quản lý Kho lưu trữ (Repository)
   - 9.2. Quy trình phân nhánh Git Flow và Lịch sử Commit
   - 9.3. Tài liệu hóa hệ thống với README.md
   - 9.4. Bảo vệ bí mật và thông tin cấu hình nhạy cảm
10. [KIỂM THỬ VÀ KẾT QUẢ ĐẠT ĐƯỢC](#10-kiểm-thử-và-kết-quả-đạt-được)
    - 10.1. Ma trận kết quả kiểm thử 6 tiêu chí kỹ thuật
    - 10.2. Kiểm thử dữ liệu và các luồng nghiệp vụ trên Web
    - 10.3. Kiểm thử tự động hóa kịch bản bảo mật (security-audit.sh: 5/5 PASS)
11. [HƯỚNG DẪN DEMO VÀ VẬN HÀNH HỆ THỐNG](#11-hướng-dẫn-demo-và-vận-hành-hệ-thống)
    - 11.1. Các bước khởi động hệ thống từ trạng thái sạch
    - 11.2. Kịch bản Demo thực tế 8 bước bảo vệ đồ án
    - 11.3. Quy trình dừng và giải phóng hệ thống
    - 11.4. Bộ câu hỏi vấn đáp chuyên sâu và hướng dẫn trả lời
12. [KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN](#12-kết-luận-và-hướng-phát-triển)
    - 12.1. Kết luận
    - 12.2. Hướng phát triển mở rộng
13. [PHỤ LỤC: DANH SÁCH HÌNH ẢNH MINH CHỨNG](#phụ-lục-danh-sách-hình-ảnh-minh-chứng)

---

# 1. GIỚI THIỆU ĐỀ TÀI

Đề tài thực hành được giao là **Đề 23: Website Quản lý Phòng tập Gym / Fitness (Titan Fitness)**. Theo yêu cầu chuẩn của môn học *Triển khai và Quản trị Hệ thống Phần mềm*, sinh viên cần hiện thực hóa một hệ thống ứng dụng web hoàn chỉnh phục vụ công tác quản lý hội viên, huấn luyện viên, các gói tập và lịch học tại trung tâm thể hình; đồng thời toàn bộ hạ tầng phải được ảo hóa theo kiến trúc container, định tuyến an toàn qua Reverse Proxy, tích hợp hệ thống giám sát thời gian thực, quản trị nhật ký tập trung và áp dụng các chính sách làm cứng bảo mật (Hardening) nghiêm ngặt.

Hệ thống **Titan Fitness** không chỉ giải quyết bài toán nghiệp vụ phần mềm mà còn là một mô hình kiến trúc chuẩn mực về quy trình triển khai phần mềm (DevOps / SRE) trong môi trường sản xuất hiện đại.

## 1.1. Mục tiêu

- **Triển khai ứng dụng quản lý phòng tập Gym:** Xây dựng ứng dụng web hiện đại, hỗ trợ khách hàng xem danh sách gói tập, đội ngũ huấn luyện viên (PT), lịch mở lớp và gửi form đăng ký tập thử; cung cấp trang quản trị (Admin Dashboard) để quản lý hội viên và nghiệp vụ.
- **Quản lý dữ liệu tập trung với MySQL:** Thiết kế cơ sở dữ liệu quan hệ lưu trữ thông tin hội viên, gói tập, huấn luyện viên và đơn đăng ký; tích hợp công cụ phpMyAdmin qua đường dẫn an toàn để quản trị trực quan.
- **Thiết lập Cổng Ingress Gateway với Nginx:** Cấu hình Nginx đóng vai trò Reverse Proxy duy nhất tiếp nhận lưu lượng mạng bên ngoài, ép buộc chuyển hướng HTTP sang HTTPS thông qua chứng chỉ SSL/TLS tự ký hỗ trợ SAN (Subject Alternative Name).
- **Giám sát toàn diện (Observability):** Tích hợp Prometheus tự động cào (scrape) chỉ số từ 5 targets (Node.js app, MySQL, Nginx, cAdvisor, Prometheus); trực quan hóa trên 4 Dashboard Grafana chuyên sâu.
- **Tập trung hóa nhật ký (Centralized Logging):** Thu thập toàn bộ access/error log từ Nginx và ứng dụng bằng Promtail, chuyển về Loki lưu trữ và xây dựng các truy vấn LogQL phục vụ điều tra sự cố.
- **Bảo mật đa tầng (Defense in Depth):** Thiết lập cô lập mạng nội bộ CSDL, áp dụng cgroups giới hạn trần tài nguyên (CPU/RAM), hạ quyền container xuống non-root (UID 1000), bật cấm leo thang đặc quyền `no-new-privileges`, bộ 8/8 Security Headers và chống tấn công từ chối dịch vụ DoS/Brute-force bằng Nginx Rate Limiting (mã lỗi HTTP 429).

## 1.2. Phạm vi

Hệ thống được phát triển, đóng gói và kiểm thử thực nghiệm trên nền tảng **Ubuntu 24.04 LTS chạy trên WSL 2 (Windows Subsystem for Linux)** kết hợp công cụ điều phối **Docker Compose v2**. Toàn bộ dịch vụ được cấu hình trên cùng một máy chủ host nội bộ, mô phỏng chính xác hạ tầng máy chủ ảo (Cloud VPS).

## 1.3. Kết quả đạt được

Hệ thống **Titan Fitness** đã được triển khai hoàn chỉnh 100% về mặt kỹ thuật với 10 microservices phối hợp nhịp nhàng:
- Trang chủ và hệ thống CRUD quản lý phòng gym hoạt động mượt mà, phản hồi tức thì.
- Kết nối CSDL MySQL 8.4 được bảo vệ tuyệt đối trong mạng cô lập (không lộ cổng 3306 ra ngoài).
- Nginx Ingress điều phối thông minh, bảo mật HTTPS với ổ khóa xanh, chặn spam tự động qua Rate Limit.
- Cụm giám sát Prometheus đạt 5/5 targets UP, Grafana hiển thị trực quan các biểu đồ tải.
- Cụm logging Loki - Promtail ghi nhận và phân tích tức thời các dòng log qua 7 câu truy vấn LogQL.
- Kịch bản kiểm thử bảo mật tự động `security-audit.sh` đạt tuyệt đối **5/5 PASS**.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 1.1 VÀO ĐÂY: TRANG CHỦ TITAN FITNESS ]          |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 1.1 – Giao diện Trang chủ Website Quản lý Phòng tập Titan Fitness 】**

---

# 2. YÊU CẦU VÀ CÔNG NGHỆ SỬ DỤNG

## 2.1. Yêu cầu của đề tài

Theo quy định đề tài thực hành môn Triển khai và Quản trị Hệ thống Phần mềm, sinh viên cần đáp ứng đầy đủ 7 tiêu chí đánh giá cốt lõi:
1. **Quản lý mã nguồn trên Git:** Sử dụng GitHub, tổ chức phân nhánh tính năng theo ngày (Git Flow), thông điệp commit rõ ràng theo chuẩn Conventional Commits, bảo vệ tuyệt đối thông tin bảo mật (`.env`, `.gitignore`).
2. **Triển khai Ứng dụng & CSDL:** Ứng dụng web hoàn chỉnh kết nối CSDL MySQL, có dữ liệu mẫu và cung cấp giao diện quản trị phpMyAdmin.
3. **Nginx Reverse Proxy & SSL/TLS:** Đóng vai trò cổng vào duy nhất, cấu hình SSL/TLS tự ký, chuyển hướng HTTP 80 -> HTTPS 443, trang bị đầy đủ bộ Security Headers.
4. **Giám sát hệ thống (Monitoring):** Cấu hình Prometheus định kỳ thu thập số liệu từ các exporters; Grafana kết nối data source và hiển thị các biểu đồ giám sát tài nguyên (CPU, RAM, Disk, Network) và ứng dụng.
5. **Quản trị nhật ký tập trung (Logging):** Thiết lập Promtail thu thập log, Loki lưu trữ và thực thi các câu lệnh truy vấn LogQL phục vụ phân tích log.
6. **Hardening & An toàn thông tin:** Áp dụng ma trận làm cứng hệ thống tối thiểu 4-6 biện pháp (Network isolation, Least privilege, non-root user, cgroups resource limit, no-new-privileges, rate limiting).
7. **Báo cáo và Trình bày:** Soạn thảo báo cáo kỹ thuật tối thiểu 10 trang, chuẩn bị kịch bản demo và trả lời câu hỏi vấn đáp của giảng viên.

## 2.2. Bảng công nghệ sử dụng

| STT | Thành phần hệ thống | Công nghệ / Phiên bản | Vai trò & Trách nhiệm trong hệ thống |
| :---: | :--- | :--- | :--- |
| **1** | **Web Application** | Node.js 20 LTS / Express / EJS | Xử lý logic nghiệp vụ phòng gym, giao diện người dùng, cung cấp API và xuất metrics `/metrics`. |
| **2** | **Database Server** | MySQL 8.4 LTS (Community) | Lưu trữ quan hệ dữ liệu hội viên, gói tập, huấn luyện viên, lịch học và đơn đăng ký tập thử. |
| **3** | **Database GUI** | phpMyAdmin 5.2 (Apache) | Giao diện đồ họa truy vấn, kiểm tra cấu trúc bảng và quản lý CSDL trực quan. |
| **4** | **Ingress Gateway** | Nginx 1.27 (Alpine Linux) | Cổng Ingress tiếp nhận HTTPS, chấm dứt TLS (TLS Termination), Rate Limiting và định tuyến proxy. |
| **5** | **Metrics Server** | Prometheus 2.54.1 | Máy chủ cào chỉ số (Pull-based), lưu trữ time-series database và cảnh báo. |
| **6** | **Metrics Exporter (DB)**| mysqld-exporter 0.15.1 | Kết nối CSDL MySQL qua tài khoản hạn quyền để thu thập chỉ số kết nối, truy vấn, bộ nhớ đệm. |
| **7** | **Metrics Exporter (Proxy)**| nginx-prometheus-exporter 1.3.0 | Cào dữ liệu từ Nginx `stub_status` để thống kê số lượng kết nối và request đang xử lý. |
| **8** | **Container Metrics** | Google cAdvisor 0.49.1 | Thu thập trực tiếp thông số tiêu thụ CPU, RAM, Network và I/O của toàn bộ các container Docker. |
| **9** | **Visualization** | Grafana 11.2.0 | Bảng điều khiển trực quan hóa, kết nối data source Prometheus và Loki để vẽ biểu đồ và phân tích log. |
| **10**| **Log Engine** | Grafana Loki 3.1.0 | Hệ thống lưu trữ và đánh chỉ mục metadata cho log tập trung, tối ưu hiệu năng ghi. |
| **11**| **Log Shipper** | Grafana Promtail 3.1.0 | Tác nhân giám sát file log trên volume Nginx/App, gắn nhãn (labels) và đẩy (push) về Loki. |
| **12**| **Container Orchestration**| Docker & Docker Compose v2 | Đóng gói môi trường đồng nhất, điều phối vòng đời và kết nối mạng nội bộ giữa các container. |

## 2.3. Môi trường triển khai

Hệ thống được vận hành trên hạ tầng máy trạm cục bộ sử dụng hệ điều hành Ubuntu 24.04 LTS tích hợp trong nhân WSL 2 của Windows 11. Các tham số phần cứng và môi trường:
- **Hệ điều hành Host:** Windows 11 Pro 64-bit.
- **Hạ tầng Ảo hóa:** WSL 2 (Windows Subsystem for Linux) - Ubuntu 24.04 LTS (Kernel 5.15+).
- **Docker Engine:** Phiên bản 27.x kết hợp Docker Compose v2.
- **Bộ nhớ RAM máy chủ:** 16 GB DDR4.
- **Bộ xử lý:** Đa nhân (Multi-core CPU).

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 2.1 VÀO ĐÂY: DOCKER COMPOSE PS / WSL2 ]        |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 2.1 – Trạng thái khởi tạo các dịch vụ trên nền tảng Docker / WSL2 】**

---

# 3. KIẾN TRÚC VÀ CẤU TRÚC HỆ THỐNG

## 3.1. Kiến trúc phân tầng tổng thể

Hệ thống được thiết kế theo mô hình **Phòng thủ theo chiều sâu (Defense in Depth)** kết hợp phân tách trách nhiệm (Separation of Concerns). Khách hàng và quản trị viên bên ngoài hoàn toàn không thể truy cập trực tiếp vào các dịch vụ tầng dưới mà bắt buộc phải đi qua cổng ngõ kiểm soát an ninh **Nginx Ingress Gateway**.

```
[ Khách hàng / Quản trị viên ]               [ Kỹ sư Quản trị / Giám sát ]
             │                                              │
             │ (Cổng 80: HTTP Redirect -> 443)              │ (Cổng 3001: Grafana UI)
             │ (Cổng 443: HTTPS Ingress)                    │ (Cổng 9090: Prometheus UI)
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
    │ (Titan Fitness) │     │ (Subpath /pma/) │              │        │              │
    │ (/metrics:3000) │     └────────┬────────┘     ┌─────────┐ ┌──────────┐ ┌───────┴─────────┐
    └────────┬────────┘              │              │  Nginx  │ │ cAdvisor │ │    Promtail     │
             │                       │              │Exporter │ │  (8080)  │ │  (Logs Shipper) │
             │ (Mạng nội bộ 'backend' - CÔ LẬP)     └─────────┘ └──────────┘ └───────▲─────────┘
             └───────────────────────┼──────────────┐        │                       │
                                     ▼              ▼        ▼ (Mạng backend)        ├────────────────┐
                            ┌─────────────────┐    ┌───────────────────┐             │ (Đọc file log) │
                            │  MySQL 8.4 DB   │◀───│  mysqld-exporter  │             ▼                ▼
                            │    (gym_db)     │    │    (Cổng 9104)    │      [ app_logs ]     [ nginx_logs ]
                            └─────────────────┘    └───────────────────┘       (/var/log/app)   (/var/log/nginx)
```

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN HÌNH 3.1 VÀO ĐÂY: SƠ ĐỒ KIẾN TRÚC HỆ THỐNG ]       |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Hình 3.1 – Sơ đồ Kiến trúc Hệ thống Phân tầng và Luồng dữ liệu Titan Fitness 】**

## 3.2. Thiết kế các mạng Docker phân lập

Để ngăn chặn triệt để nguy cơ tấn công ngang (Lateral Movement), hạ tầng mạng được phân chia thành 2 Network riêng biệt:
1. **Mạng `frontend`:** Là mạng cầu nối (bridge network) phục vụ giao tiếp giữa Ingress Nginx với các dịch vụ cung cấp giao diện web cho người dùng cuối (Node.js App) và giao diện quản trị cơ sở dữ liệu (phpMyAdmin).
2. **Mạng `backend` (`internal: true`):** Là mạng nội bộ biệt lập hoàn toàn với thế giới bên ngoài. Mạng này không có cổng kết nối ra ngoài (No external gateway). Chỉ các dịch vụ cần đọc ghi CSDL (Node.js App, phpMyAdmin, mysqld-exporter) mới được kết nối vào mạng này để giao tiếp với MySQL. Cổng 3306 của CSDL không bao giờ được xuất (publish) ra máy host, triệt tiêu hoàn toàn khả năng bị rà quét cổng từ mạng ngoài.

## 3.3. Cấu trúc thư mục dự án chuẩn hóa

Dự án được cấu trúc theo mô hình module hóa rõ ràng, dễ bảo trì và phân quyền:

```
gym-fitness/
├── compose.yaml                  # File điều phối Docker Compose v2 duy nhất của toàn hệ thống
├── .env.example                  # File cấu hình biến môi trường mẫu chuẩn hóa
├── .gitignore                    # Bộ lọc bảo vệ bí mật tuyệt đối khỏi Git
├── README.md                     # Tài liệu hướng dẫn vận hành và kiến trúc hệ thống
├── security-audit.sh             # Kịch bản Bash kiểm thử tự động hóa 5/5 tiêu chí bảo mật
├── app/                          # Mã nguồn ứng dụng Titan Fitness (Node.js Express EJS)
│   ├── Dockerfile                # Multi-stage build, non-root user UID 1000
│   ├── package.json              # Khai báo thư viện phụ thuộc (express, mysql2, prom-client...)
│   ├── server.js                 # Điểm khởi chạy ứng dụng, cấu hình route, kết nối DB & metrics
│   ├── views/                    # Giao diện EJS (Trang chủ, Gói tập, Đăng ký, Admin Dashboard)
│   └── public/                   # Tài nguyên tĩnh CSS, JS, hình ảnh phòng tập
├── db/                           # Cấu hình CSDL và kịch bản khởi tạo
│   └── init/
│       └── 01-init.sql           # DDL tạo bảng members, packages, trainers, schedules và dữ liệu mẫu
├── nginx/                        # Cấu hình Ingress Gateway
│   ├── nginx.conf                # Reverse proxy, SSL SAN, Rate Limiting, 8/8 Security Headers
│   └── ssl/                      # Cặp khóa SSL tự ký SAN (server.crt, server.key)
├── prometheus/                   # Cấu hình thu thập chỉ số
│   └── prometheus.yml            # Khai báo 5 scrape jobs (app, mysql, nginx, cadvisor, prometheus)
├── grafana/                      # Cấu hình trực quan hóa
│   └── provisioning/             # Tự động hóa nạp Data Sources và 4 Dashboards (Zero-touch)
├── loki/                         # Cấu hình máy chủ lưu trữ log
│   └── loki-config.yaml          # Thiết lập filesystem, TSDB storage engine
├── promtail/                     # Cấu hình tác nhân chuyển log
│   └── promtail-config.yaml      # Khai báo đường dẫn log Nginx và App, gán nhãn metadata
└── docs/                         # Báo cáo thực hành, tài liệu đặc tả và file minh chứng kiểm thử
```

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 3.2 VÀO ĐÂY: CẤU TRÚC THƯ MỤC DỰ ÁN ]          |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 3.2 – Cấu trúc Cây Thư mục Dự án gym-fitness trên WSL2 / VS Code 】**

---

# 4. TRIỂN KHAI WEBSITE, MYSQL VÀ PHPMYADMIN

## 4.1. Triển khai bằng Docker Compose

Toàn bộ 10 container dịch vụ được khai báo chặt chẽ trong file `compose.yaml`. Các dịch vụ phụ thuộc được kiểm soát bằng cơ chế `depends_on` kèm điều kiện `condition: service_healthy` (như ứng dụng Node.js chỉ được khởi chạy khi container MySQL đã hoàn tất nạp dữ liệu và phản hồi `mysqladmin ping` thành công). Việc khởi động hệ thống được thực thi bằng một lệnh duy nhất:
```bash
docker compose up -d
```

## 4.2. Cấu hình CSDL MySQL 8.4 và cấu trúc dữ liệu

Dịch vụ CSDL sử dụng phiên bản chính thức `mysql:8.4` (bản hỗ trợ dài hạn LTS mới nhất). CSDL mang tên `gym_db` được tự động nạp cấu trúc và dữ liệu thông qua volume mount file `/db/init/01-init.sql`:
- **Bảng `members`:** Lưu trữ hồ sơ hội viên (Họ tên, SĐT, Email, Giới tính, Ngày sinh, Ngày tham gia, Trạng thái hoạt động).
- **Bảng `packages`:** Chứa danh mục các gói tập Gym thể hình (VIP, Classic, Yoga, Cardio, Thời hạn tháng, Học phí, Số buổi tập).
- **Bảng `trainers`:** Danh sách Huấn luyện viên cá nhân (Họ tên, Chuyên môn, SĐT, Năm kinh nghiệm, Tiểu sử).
- **Bảng `schedules`:** Lịch mở các lớp tập luyện theo khung giờ trong tuần và phòng tập.
- **Bảng `trial_registrations`:** Tiếp nhận trực tiếp các đơn đăng ký tập thử từ khách hàng ngoài trang chủ.

Toàn bộ thông tin đăng nhập mật khẩu của MySQL (`MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`) được đọc an toàn từ file môi trường `.env`, tuyệt đối không lưu cứng trong code.

## 4.3. Ứng dụng Web Titan Fitness (Node.js & Express)

Ứng dụng được viết bằng nền tảng **Node.js 20 LTS** kết hợp framework **Express** và template engine **EJS**. Ứng dụng cung cấp:
- **Trang chủ chuyên nghiệp:** Trực quan hóa hình ảnh phòng tập, bảng giá các gói hội viên, thông tin huấn luyện viên cá nhân và thời khóa biểu tập luyện.
- **Form đăng ký tập thử:** Khách hàng điền thông tin và gói tập mong muốn, dữ liệu được xác thực và lưu tức thời vào bảng `trial_registrations`.
- **Trang quản trị (Admin Dashboard):** Hỗ trợ đầy đủ các thao tác thêm, sửa, xóa, tìm kiếm hội viên, cập nhật trạng thái đơn đăng ký và xem tổng quan số liệu phòng gym.
- **Tích hợp Metrics:** Thư viện `prom-client` được nhúng để tự động trích xuất các chỉ số thời gian thực tại endpoint nội bộ `/metrics` (HTTP request duration, memory heap, CPU usage...).

## 4.4. Công cụ quản trị CSDL phpMyAdmin

Dịch vụ phpMyAdmin được cấu hình chạy trên nền web, kết nối trực tiếp với service `mysql` qua mạng `backend`. Để đảm bảo an ninh, phpMyAdmin được đặt sau Nginx Ingress tại subpath an toàn `/pma/` và chỉ cho phép người quản trị có tài khoản đăng nhập để thao tác sao lưu, phục hồi dữ liệu hoặc kiểm tra cấu trúc bảng.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 4.1 VÀO ĐÂY: WEBSITE TITAN FITNESS ]            |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 4.1 – Giao diện Website Titan Fitness và Form Đăng ký Tập thử 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 4.2 VÀO ĐÂY: PHPMYADMIN & CSDL GYM_DB ]        |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 4.2 – Giao diện Quản trị CSDL phpMyAdmin và Cấu trúc Bảng trong gym_db 】**

---

# 5. CẤU HÌNH NGINX REVERSE PROXY VÀ SSL/TLS

## 5.1. Mục đích và vai trò Ingress Gateway

Nginx đóng vai trò là chốt chặn an ninh vòng ngoài duy nhất (Ingress Gateway) của toàn bộ hệ thống. Nhiệm vụ chính của Nginx bao gồm:
- Tiếp nhận toàn bộ lưu lượng truy cập từ người dùng trên cổng tiêu chuẩn HTTP (80) và HTTPS (443).
- Thực thi chuyển hướng bắt buộc (Redirect 301) từ HTTP sang HTTPS để mã hóa dữ liệu đường truyền.
- Đóng vai trò điểm cuối giải mã TLS (TLS Termination), giảm tải gánh nặng xử lý mã hóa cho ứng dụng backend.
- Phân phối yêu cầu (Reverse Proxy) thông minh: Đường dẫn gốc `/` chuyển tiếp tới Node.js App; đường dẫn `/pma/` chuyển tiếp tới phpMyAdmin.

## 5.2. Cấu hình định tuyến Proxy và Chứng chỉ SSL/TLS tự ký SAN

Hệ thống sử dụng chứng chỉ số tự ký (Self-Signed Certificate) được tạo tự động qua OpenSSL với phần mở rộng **SAN (Subject Alternative Name)**, khai báo rõ ràng các định danh `DNS:localhost`, `IP:127.0.0.1`. Điều này giúp các trình duyệt hiện đại chấp nhận kết nối mã hóa an toàn mà không báo lỗi tên miền không khớp.
Cấu hình giao thức được giới hạn nghiêm ngặt ở **TLSv1.2** và **TLSv1.3**, loại bỏ hoàn toàn các phiên bản cũ kém an toàn (SSLv3, TLSv1.0, TLSv1.1) kèm bộ mật mã mã hóa mạnh (High-grade ciphers).

## 5.3. Bộ tiêu đề bảo mật (Security Headers) và Chống DoS bằng Rate Limiting

Để bảo vệ người dùng và ứng dụng web khỏi các lỗ hổng OWASP phổ biến, Nginx được cấu hình tiêm trực tiếp bộ **8 tiêu đề bảo mật chuẩn công nghiệp**:
1. `X-Frame-Options: SAMEORIGIN` — Ngăn chặn triệt để tấn công Clickjacking.
2. `X-Content-Type-Options: nosniff` — Chống tấn công MIME-type sniffing.
3. `X-XSS-Protection: 1; mode=block` — Kích hoạt bộ lọc chống Cross-Site Scripting của trình duyệt.
4. `Referrer-Policy: strict-origin-when-cross-origin` — Bảo vệ thông tin rò rỉ qua URL chuyển tiếp.
5. `Strict-Transport-Security: max-age=31536000; includeSubDomains` (HSTS) — Bắt buộc trình duyệt ghi nhớ truy cập bằng HTTPS trong vòng 1 năm.
6. `Content-Security-Policy (CSP)` — Kiểm soát chặt chẽ các nguồn tải tài nguyên JavaScript, CSS, Font và hình ảnh.
7. `Permissions-Policy: camera=(), microphone=(), geolocation=()` — Vô hiệu hóa việc lạm dụng phần cứng thiết bị người dùng.
8. `server_tokens off` — Ẩn hoàn toàn thông tin chi tiết về phiên bản Nginx trong response header, ngăn kẻ tấn công dò quét lỗ hổng theo version.

Bên cạnh đó, chính sách **Rate Limiting** được thiết lập chặt chẽ:
- Vùng chung (`general_limit`): Giới hạn 10 requests/giây cho toàn bộ trang tĩnh.
- Vùng nghiêm ngặt (`strict_limit`): Giới hạn 2 requests/giây cho các endpoint trọng yếu dễ bị tấn công brute-force hoặc spam bot như `/admin` và `/register-trial`. Khi vượt ngưỡng, Nginx lập tức từ chối và trả về mã lỗi **HTTP 429 (Too Many Requests)**.

## 5.4. Chuẩn hóa định dạng Access Log và Error Log

Các file log của Nginx được ghi định dạng JSON/Extended kết hợp mã trạng thái, IP nguồn, thời gian phản hồi và User-Agent vào thư mục `/var/log/nginx`, sau đó được ánh xạ ra volume của máy host để Promtail thu thập đưa về Loki.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 5.1 VÀO ĐÂY: NGINX HTTPS VÀ Ổ KHÓA XANH ]      |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 5.1 – Website truy cập qua HTTPS với Ổ khóa xanh và Chứng chỉ SSL SAN 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 5.2 VÀO ĐÂY: FILE CẤU HÌNH NGINX.CONF ]        |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 5.2 – Nội dung File Cấu hình Ingress Gateway Nginx (Proxy, SSL, Security Headers, Rate Limit) 】**

---

# 6. GIÁM SÁT VỚI PROMETHEUS VÀ GRAFANA

## 6.1. Cấu hình Prometheus Server và 5 targets giám sát

Prometheus được triển khai với phiên bản ổn định `v2.54.1`. File cấu hình `prometheus.yml` định nghĩa tần suất cào dữ liệu (`scrape_interval: 5s`), cho phép thu thập số liệu gần như thời gian thực từ **5 mục tiêu (targets)**:
1. `titan-fitness-app`: Endpoint `app:3000/metrics` trích xuất chỉ số Node.js Runtime.
2. `mysql`: Endpoint `mysqld-exporter:9104` cào chỉ số hoạt động CSDL.
3. `nginx`: Endpoint `nginx-exporter:9113` cào chỉ số traffic reverse proxy.
4. `cadvisor`: Endpoint `cadvisor:8080` cào chỉ số tài nguyên toàn bộ container.
5. `prometheus`: Endpoint nội bộ `localhost:9090` tự giám sát chính Prometheus server.

Cả 5 targets đều được xác thực hoạt động ổn định ở trạng thái **UP (100%)** trên giao diện điều khiển `http://localhost:9090/targets`.

## 6.2. Các bộ thu thập chỉ số (Exporters)

- **cAdvisor (Container Advisor):** Gắn trực tiếp vào Docker socket (`/var/run/docker.sock`) và filesystem nhân Linux (`/sys/fs/cgroup`) để đọc số liệu sử dụng CPU, dung lượng RAM, tốc độ đọc ghi đĩa và lưu lượng mạng của từng container đang chạy.
- **mysqld-exporter:** Sử dụng tài khoản đặc thù được cấp quyền tối thiểu trong MySQL để đo lường số truy vấn mỗi giây (QPS), số kết nối đang mở, tỷ lệ trúng bộ đệm (Buffer Pool Hit Ratio) và các truy vấn chậm (Slow Queries).
- **nginx-prometheus-exporter:** Trích xuất các kết nối đang hoạt động (Active Connections), trạng thái đọc/ghi/chờ và tổng số requests tiếp nhận từ module `stub_status` của Nginx.

## 6.3. Hệ thống 4 Dashboards chuyên sâu trên Grafana

Grafana được cấu hình tự động (Provisioning) nạp Data Source Prometheus và tự động dựng **4 Dashboard chuyên biệt**:
1. **Node.js Application Dashboard:** Giám sát tốc độ requests/giây, thời gian đáp ứng trung bình (Latency p95/p99), tỷ lệ mã lỗi HTTP 4xx/5xx, mức tiêu thụ Heap Memory và Event Loop lag.
2. **MySQL Overview Dashboard:** Giám sát lưu lượng truy vấn theo thời gian thực, số lượng Client Connections đồng thời, trạng thái bộ nhớ đệm InnoDB và lưu lượng I/O CSDL.
3. **Nginx Reverse Proxy Dashboard:** Trực quan hóa số lượng kết nối đang active, biểu đồ phân bố mã trạng thái HTTP (2xx, 3xx, 4xx, 5xx) và đặc biệt là số lượng requests bị Rate Limit chặn đứng (Mã 429).
4. **cAdvisor Containers Dashboard:** Giám sát tổng quan sức khỏe toàn bộ 10 container: tỷ lệ % CPU, dung lượng RAM (MB/GB) so với ngưỡng trần Cgroups khai báo, và lưu lượng Network I/O.

## 6.4. Đánh giá kết quả giám sát tài nguyên và hiệu năng

Hệ thống giám sát giúp phát hiện tức thì các điểm nghẽn hiệu năng (bottleneck). Khi người dùng thao tác trên website hoặc khi kịch bản tấn công DoS được kích hoạt, các biểu đồ trên Grafana lập tức phản ánh biến động, chứng minh tính sẵn sàng và khả năng quan sát (Observability) vượt trội của đồ án.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 6.1 VÀO ĐÂY: PROMETHEUS TARGETS 5/5 UP ]       |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 6.1 – Giao diện Prometheus /targets với Đầy đủ 5 Mục tiêu ở Trạng thái UP 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 6.2 VÀO ĐÂY: GRAFANA DASHBOARDS GIÁM SÁT ]     |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 6.2 – Bảng điều khiển Grafana Giám sát Toàn diện Hệ thống và Container 】**

---

# 7. TẬP TRUNG LOG VỚI LOKI, PROMTAIL VÀ LOGQL

## 7.1. Cấu hình hệ thống lưu trữ log Loki

Loki 3.1.0 đóng vai trò là kho lưu trữ tập trung dữ liệu nhật ký hệ thống. Khác với Elasticsearch tốn kém tài nguyên do đánh chỉ mục toàn văn bản (Full-text index), Loki chỉ đánh chỉ mục cho các nhãn nhãn (Labels: `job`, `container`, `environment`, `stream`), giúp hệ thống vận hành vô cùng nhẹ nhàng, tiết kiệm RAM và tối ưu hóa thời gian khởi động trong môi trường Docker WSL2.

## 7.2. Tác nhân thu thập nhật ký Promtail

Promtail 3.1.0 được cấu hình như một shipper chạy nền. Promtail đọc liên tục các dòng log được ghi ra từ các volume chia sẻ:
- Log Ingress Gateway: `/var/log/nginx/access.log` và `/var/log/nginx/error.log`.
- Log Ứng dụng Backend: `/var/log/app/app.log`.

Sau khi phân tích và gắn các nhãn siêu dữ liệu tương ứng (`job="nginx"`, `job="app"`), Promtail đóng gói các log chunk và đẩy qua giao thức HTTP API về cổng 3100 của Loki.

## 7.3. Các kịch bản truy vấn và phân tích với LogQL

Bằng công cụ **Grafana Explore**, người quản trị có thể truy vấn và sàng lọc nhật ký theo thời gian thực với ngôn ngữ **LogQL**. Dự án đã kiểm thử và chuẩn hóa **7 câu truy vấn mẫu tiêu biểu**:

1. **Xem toàn bộ log Ingress Nginx:**
   ```logql
   {job="nginx"}
   ```
2. **Lọc các truy vấn thành công (Mã HTTP 200):**
   ```logql
   {job="nginx"} |= " 200 "
   ```
3. **Giám sát các cuộc tấn công bị Rate Limit chặn đứng (Mã HTTP 429):**
   ```logql
   {job="nginx"} |= " 429 "
   ```
4. **Phân tích các giao dịch tạo mới dữ liệu (Phương thức HTTP POST):**
   ```logql
   {job="nginx"} |= "POST"
   ```
5. **Truy vấn log vận hành của ứng dụng Node.js:**
   ```logql
   {job="app"}
   ```
6. **Lọc các thông báo lỗi và ngoại lệ của hệ thống:**
   ```logql
   {job="app"} |~ "(?i)(error|exception|fail)"
   ```
7. **Đo lường tần suất phát sinh log lỗi theo thời gian:**
   ```logql
   rate({job="nginx"} |= " 429 " [1m])
   ```

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 7.1 VÀO ĐÂY: LOGQL TRUY VẤN {job="nginx"} ]     |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 7.1 – Grafana Explore thực thi truy vấn LogQL căn bản {job="nginx"} 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 7.2 VÀO ĐÂY: LOGQL LỌC MÃ HTTP 429 RATE LIMIT ]|
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 7.2 – Grafana Explore lọc các bản ghi bị Nginx Rate Limiting chặn với mã HTTP 429 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 7.3 VÀO ĐÂY: LOGQL LỌC HTTP POST / APP ERROR ]  |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 7.3 – Grafana Explore phân tích các giao dịch HTTP POST và Log ứng dụng 】**

---

# 8. HARDENING VÀ CÁC BIỆN PHÁP BẢO MẬT ĐA TẦNG

Hệ thống **Titan Fitness** áp dụng triệt để nguyên tắc **Defense in Depth** và **Least Privilege** với ma trận làm cứng bảo mật 6 lớp vững chắc:

| Tầng bảo vệ (Layer) | Biện pháp Hardening cụ thể | Cấu hình kỹ thuật hiện thực | Mục đích & Nguy cơ ngăn chặn |
| :--- | :--- | :--- | :--- |
| **Ingress Gateway** | Rate Limiting & DoS Protection | `limit_req_zone` (10r/s chung, 2r/s nhạy cảm), mã lỗi `HTTP 429`. | Chống vét cạn mật khẩu (Brute-force), spam bot và từ chối dịch vụ (DoS). |
| **Container Engine** | Resource Limits (Linux Cgroups) | Trần CPU/RAM: MySQL (1GB/1 CPU), App (512MB/0.75 CPU), Nginx (256MB)... | Chống cạn kiệt tài nguyên host, ngăn chặn hiện tượng sập hệ thống dây chuyền do OOM. |
| **Privilege Layer** | Least Privilege & Non-Root User | Chạy user `node` (UID 1000), bật `no-new-privileges: true`, `cap_drop: [ALL]`. | Vô hiệu hóa nguy cơ leo thang đặc quyền (Container Breakout) hoặc can thiệp kernel host. |
| **Network Layer** | Network Segmentation (Cô lập CSDL) | Mạng `backend` cấu hình `internal: true`. Cổng 3306 không publish ra máy host. | Ngăn chặn kẻ tấn công dò quét cổng hoặc chọc thủng CSDL trực tiếp từ mạng ngoài. |
| **Data & Filesystem**| Read-only Mount & File Permissions | Cấu hình mount `:ro`, đặt quyền `chmod 600 .env`, che giấu `server_tokens off`. | Ngăn kẻ tấn công sửa đổi file cấu hình và thu thập phiên bản phần mềm. |
| **Browser Security** | 8/8 Security Headers & TLS Strict | Đầy đủ HSTS, CSP, X-Frame-Options, X-Content-Type-Options, TLSv1.2/1.3. | Chống Clickjacking, XSS, Sniffing, ép buộc duyệt web bảo mật HTTPS. |

## 8.1. Cô lập mạng cơ sở dữ liệu (Network Segmentation)

Mạng `backend` được khai báo cờ `internal: true`. Trong cơ chế ảo hóa của Docker, điều này đồng nghĩa với việc Docker hủy bỏ hoàn toàn việc tạo iptables routing rule kết nối mạng này với default gateway của máy host. Do đó, bất kỳ nỗ lực kết nối từ bên ngoài vào IP hoặc port 3306 của CSDL đều lập tức bị trả về lỗi `Connection Refused`.

## 8.2. Ngăn chặn leo thang đặc quyền (no-new-privileges & cap_drop)

Trong Linux kernel, các chương trình mang cờ `setuid` hoặc `setgid` có thể cho phép một tiến trình người dùng thường nâng quyền lên quyền của chủ sở hữu file (thường là root). Bằng cách khai báo:
```yaml
security_opt:
  - no-new-privileges:true
cap_drop:
  - ALL
```
Docker ép cờ `PR_SET_NO_NEW_PRIVS` lên tiến trình container và con của nó, đồng thời tước bỏ toàn bộ các năng lực hạt nhân thừa thãi (Linux Capabilities). Dù kẻ tấn công có khai thác được lỗ hổng RCE trong code, chúng cũng không thể nâng quyền để xâm nhập máy chủ host.

## 8.3. Thực thi tài khoản không đặc quyền (Non-Root UID 1000)

Tại file `app/Dockerfile`, ứng dụng Node.js được chỉ định chạy dưới danh tính người dùng `node` có mã định danh `UID=1000, GID=1000`:
```dockerfile
USER node
```
Điều này đảm bảo tiến trình ứng dụng tuân thủ nghiêm ngặt nguyên tắc đặc quyền tối thiểu.

## 8.4. Giới hạn tài nguyên hệ thống (Linux Cgroups limits)

Để phòng chống hiện tượng "hàng xóm ồn ào" (Noisy Neighbor) hoặc các cuộc tấn công làm tràn bộ nhớ gây lỗi kernel panic (Out Of Memory - OOM Killer), từng dịch vụ trong `compose.yaml` đều được áp mức trần CPU và RAM rõ ràng thông qua hệ thống cgroups:
- `mysql`: `memory: 1024M`, `cpus: '1.0'`
- `app`: `memory: 512M`, `cpus: '0.75'`
- `nginx`: `memory: 256M`, `cpus: '0.5'`
- `grafana`: `memory: 256M`, `cpus: '0.5'`
- `loki`: `memory: 512M`, `cpus: '0.5'`

## 8.5. Ngoại lệ cAdvisor và giải thích bảo vệ

Trong bảng điều phối `compose.yaml`, dịch vụ `cadvisor` sử dụng cờ `privileged: true`. Đây là một **ngoại lệ kỹ thuật có chủ đích** và hoàn toàn hợp lệ trong kiến trúc DevOps. Bởi vì cAdvisor là công cụ quản trị hệ thống tầng sâu, nó bắt buộc phải có quyền đọc dữ liệu thống kê trực tiếp từ `/sys/fs/cgroup` và `/var/run/docker.sock` của nhân Linux thì mới có thể đo lường và cung cấp số liệu CPU/RAM của các container khác cho Prometheus.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 8.1 VÀO ĐÂY: KIỂM TRA NETWORK ISOLATION ]       |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 8.1 – Kiểm tra Cô lập CSDL: Cổng 3306 bị Chặn Hoàn toàn từ Host 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 8.2 VÀO ĐÂY: KẾT QUẢ SECURITY AUDIT 5/5 PASS ]  |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 8.2 – Kịch bản Kiểm tra Bảo mật Tự động security-audit.sh Đạt Chuẩn 5/5 PASS 】**

---

# 9. QUẢN LÝ MÃ NGUỒN VÀ CẤU HÌNH TRÊN GITHUB

## 9.1. Quản lý Kho lưu trữ (Repository)

Toàn bộ mã nguồn, kịch bản triển khai và tài liệu dự án được lưu trữ và quản lý phiên bản chuyên nghiệp trên GitHub tại địa chỉ:
👉 **Repository URL:** `https://github.com/nguyentuynefb-beem/gym-fitness.git`

## 9.2. Quy trình phân nhánh Git Flow và Lịch sử Commit

Dự án áp dụng chặt chẽ mô hình **Git Flow**, phân tách rành mạch theo các nhánh tính năng tương ứng với từng ngày triển khai:
- `main`: Nhánh phát hành chính thức, chứa mã nguồn ổn định nhất.
- `develop`: Nhánh tích hợp trung tâm.
- `feature/day01-database-schema`: Xây dựng cấu trúc CSDL và DDL MySQL.
- `feature/day02-web-gym-app`: Hoàn thiện ứng dụng Node.js Titan Fitness.
- `feature/day03-nginx-reverse-proxy`: Cấu hình Nginx Ingress, SSL SAN, Security Headers.
- `feature/day04-monitoring-prometheus-grafana`: Triển khai Prometheus, Exporters và 4 Dashboards.
- `feature/day05-logging-loki-promtail`: Tích hợp Loki, Promtail và 7 truy vấn LogQL.
- `feature/day06-security-hardening`: Hiện thực hóa 6 tầng bảo mật và kịch bản `security-audit.sh`.
- `feature/day07-documentation-report`: Hoàn thiện Báo cáo tổng hợp, kịch bản Demo và Slide bảo vệ.

Mọi commit đều tuân thủ nghiêm ngặt quy ước **Conventional Commits** (ví dụ: `feat(nginx): configure reverse proxy with self-signed ssl san`, `feat(security): implement multi-layer hardening and audit script`).

## 9.3. Tài liệu hóa hệ thống với README.md

File `README.md` tại thư mục gốc đóng vai trò như một cẩm nang vận hành chi tiết: Giới thiệu hệ thống, sơ đồ kiến trúc, bảng cổng kết nối, hướng dẫn chạy hệ thống với 1 lệnh, danh sách tài khoản mặc định, hướng dẫn truy vấn LogQL và bảng ma trận Hardening.

## 9.4. Bảo vệ thông tin nhạy cảm (.env, .gitignore)

Để phòng ngừa rủi ro rò rỉ thông tin xác thực lên mạng công cộng:
- File `.env` chứa mật khẩu thực tế được loại trừ tuyệt đối bằng file `.gitignore`.
- Dự án cung cấp file `.env.example` chứa các tham số mẫu an toàn để phục vụ cấu hình môi trường mới.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 9.1 VÀO ĐÂY: GIAO DIỆN GITHUB REPOSITORY ]     |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 9.1 – Giao diện Kho lưu trữ GitHub của Dự án Titan Fitness 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 9.2 VÀO ĐÂY: LỊCH SỬ COMMIT & CÁC NHÁNH GIT ]   |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 9.2 – Lịch sử Commit và Hệ thống Nhánh Git Flow Chuẩn hóa 】**

---

# 10. KIỂM THỬ VÀ KẾT QUẢ ĐẠT ĐƯỢC

## 10.1. Ma trận kết quả kiểm thử 6 tiêu chí kỹ thuật

| Tiêu chí đánh giá | Phương thức kiểm tra thực nghiệm | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
| :--- | :--- | :--- | :--- | :---: |
| **Tiêu chí 1: Quản lý Git** | Kiểm tra Git branches, commit log và file `.gitignore` | Có nhánh feature, commit chuẩn, không lộ `.env` | Nhánh rành mạch, bảo mật bí mật 100% | **ĐẠT** |
| **Tiêu chí 2: Web & CSDL** | Khởi động `docker compose up -d`, kiểm tra web & phpMyAdmin | Web CRUD mượt mà, DB có bảng và dữ liệu mẫu | Dữ liệu nạp tự động, CRUD hoạt động tốt | **ĐẠT** |
| **Tiêu chí 3: Nginx Gateway** | Truy cập `http://localhost` và `https://localhost` | Redirect 301 sang HTTPS, SSL SAN hợp lệ, 8 headers | HTTPS ổ khóa xanh, 8/8 Security Headers | **ĐẠT** |
| **Tiêu chí 4: Monitoring** | Truy cập `localhost:9090/targets` và `localhost:3001` | 5 targets UP, 4 Dashboards hiển thị số liệu | 5/5 targets UP, biểu đồ Grafana động | **ĐẠT** |
| **Tiêu chí 5: Logging** | Kiểm tra `/ready` Loki, chạy 7 query LogQL trên Explore | Loki Ready, lọc được log 200, 429, POST, error | Promtail chuyển log liên tục, LogQL chính xác| **ĐẠT** |
| **Tiêu chí 6: Hardening** | Chạy kịch bản tự động `./security-audit.sh` | Vượt qua 5 bài test về mạng, DoS, user, header, RAM | 5/5 PASS tuyệt đối | **ĐẠT** |

## 10.2. Kiểm thử dữ liệu và các luồng nghiệp vụ trên Web

- Thử nghiệm đăng ký gói tập từ form Trang chủ: Điền thông tin khách hàng mới $
ightarrow$ Kiểm tra CSDL qua phpMyAdmin $
ightarrow$ Bản ghi xuất hiện ngay lập tức trong bảng `trial_registrations`.
- Thử nghiệm thêm mới hội viên trên Admin Dashboard: Thông tin hội viên mới lập tức hiển thị trên giao diện và lưu trữ vĩnh viễn trên volume `mysql_data`.

## 10.3. Kiểm thử tự động hóa kịch bản bảo mật (security-audit.sh: 5/5 PASS)

Kịch bản `security-audit.sh` được lập trình để thực hiện 5 bài kiểm tra nghiêm ngặt:
1. `[TEST 1/5]` Quét cổng MySQL 3306 từ ngoài Host $
ightarrow$ **PASS (Connection Refused)**.
2. `[TEST 2/5]` Bắn liên tiếp 30 requests vào `/admin` $
ightarrow$ **PASS (24/30 request bị chặn với HTTP 429)**.
3. `[TEST 3/5]` Quét 8 tiêu đề bảo mật Nginx Ingress $
ightarrow$ **PASS (8/8 Security Headers hiện diện)**.
4. `[TEST 4/5]` Kiểm tra danh tính tài khoản container $
ightarrow$ **PASS (UID=1000 node, Non-root)**.
5. `[TEST 5/5]` Kiểm tra trần tài nguyên Cgroups $
ightarrow$ **PASS (Toàn bộ container có limit CPU/RAM)**.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 10.1 VÀO ĐÂY: DOCKER COMPOSE PS HEALTHY ]       |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 10.1 – Trạng thái Vận hành Ổn định và Khỏe mạnh của 11 Container 】**

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 10.2 VÀO ĐÂY: KIỂM THỬ NGHIỆP VỤ FORM WEB ]     |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 10.2 – Kết quả Kiểm thử Thao tác Đăng ký Thành viên Mới trên Website 】**

---

# 11. HƯỚNG DẪN DEMO VÀ VẬN HÀNH HỆ THỐNG

## 11.1. Các bước khởi động hệ thống từ trạng thái sạch

1. Mở terminal Ubuntu 24.04 trên WSL 2 và di chuyển vào thư mục dự án:
   ```bash
   cd ~/projects/gym-fitness
   ```
2. Đảm bảo file cấu hình `.env` đã được khởi tạo:
   ```bash
   cp -n .env.example .env
   ```
3. Kích hoạt toàn bộ hạ tầng bằng Docker Compose:
   ```bash
   docker compose up -d
   ```
4. Xác nhận trạng thái vận hành của 11 container:
   ```bash
   docker compose ps
   ```

## 11.2. Kịch bản Demo thực tế 8 bước bảo vệ đồ án

- **Bước 1 (Website Titan Fitness):** Mở trình duyệt truy cập `https://localhost`, giới thiệu giao diện Dark Luxury của phòng tập gym, danh mục các gói tập, đội ngũ huấn luyện viên PT, thời khóa biểu và thực hiện điền thông tin gửi form đăng ký tập thử 7 ngày miễn phí.
- **Bước 2 (CSDL phpMyAdmin):** Mở tab trình duyệt truy cập `https://localhost/pma/`, đăng nhập và mở CSDL `gym_db`, kiểm tra bảng `trial_registrations` để chứng minh dữ liệu vừa đăng ký ở Bước 1 đã được lưu trữ tức thời vào MySQL 8.4.
- **Bước 3 (Nginx Ingress & SSL HTTPS):** Kiểm tra vai trò cổng Ingress Gateway của Nginx: truy cập thử `http://localhost` để giảng viên thấy trình duyệt tự động chuyển hướng 301 sang `https://localhost`, mở popup xem thông tin chứng chỉ SSL tự ký có đầy đủ Subject Alternative Name (SAN: `localhost`, `127.0.0.1`), và kiểm tra bộ 8 tiêu đề bảo mật Security Headers (F12 Network hoặc lệnh cURL).
- **Bước 4 (Giám sát Prometheus):** Truy cập `http://localhost:9090/targets`, chứng minh toàn bộ 5/5 targets (`titan-fitness-app`, `mysql`, `nginx`, `cadvisor`, `prometheus`) đều đang hoạt động hoàn hảo ở trạng thái màu xanh **UP**.
- **Bước 5 (Trực quan hóa Grafana):** Truy cập `http://localhost:3001`, trình diễn 4 Dashboards chuyên sâu (Node.js Application, MySQL Overview, Nginx Gateway, Docker Containers cAdvisor) với các biểu đồ tải CPU, RAM, lưu lượng Network I/O và số lượng HTTP requests biến động trực quan theo thời gian thực.
- **Bước 6 (Quản trị Log tập trung Loki & LogQL):** Mở Grafana Explore, chọn Data Source Loki và thực thi các câu truy vấn LogQL mẫu như `{job="nginx"}` và `{job="app"}` để thấy các dòng log vừa phát sinh khi thao tác trên web, minh chứng cơ chế thu thập log tự động của Promtail.
- **Bước 7 (Bảo mật Hardening Đa tầng):** Trình diễn 2 kịch bản an ninh then chốt:
  1. Kích hoạt Rate Limiting chống tấn công DoS/Brute-force bằng lệnh:
     ```bash
     for i in {1..15}; do curl -k -s -o /dev/null -w "%{http_code} " https://localhost/admin; done
     ```
     Chỉ cho giảng viên thấy màn hình xuất hiện mã **HTTP 429 (Too Many Requests)**, sau đó vào Grafana Explore gõ `{job="nginx"} |= "429"` để thấy dòng log ghi nhận sự kiện chặn tấn công.
  2. Chạy kịch bản kiểm tra bảo mật tự động:
     ```bash
     ./security-audit.sh
     ```
     Màn hình xuất ra kết quả **5/5 PASS** tuyệt đối (cô lập CSDL, chặn DoS, Security Headers, Non-root UID 1000, Cgroups limits).
- **Bước 8 (Mã nguồn GitHub & Tài liệu README):** Mở trình duyệt xem Repository GitHub của dự án (`https://github.com/nguyentuynefb-beem/gym-fitness`), giới thiệu quy trình phân nhánh Git Flow (từ `feature/day01` đến `feature/day07`), lịch sử commit chuẩn hóa Conventional Commits, tài liệu hướng dẫn vận hành chi tiết `README.md` và kiểm tra file `.gitignore` để chứng minh bí mật mật khẩu `.env` được bảo vệ tuyệt đối.

## 11.3. Quy trình dừng và giải phóng hệ thống

Khi kết thúc phiên làm việc hoặc giải phóng bộ nhớ RAM:
```bash
docker compose down
```
*(Nếu muốn xóa sạch toàn bộ dữ liệu database để kiểm thử từ đầu: `docker compose down -v`)*.

## 11.4. Bộ câu hỏi vấn đáp chuyên sâu và hướng dẫn trả lời

- **Câu hỏi 1: Tại sao Nginx lại có thể chặn được DoS và mã 429 mang ý nghĩa gì?**
  *Trả lời:* Nginx sử dụng thuật toán Leaky Bucket thông qua chỉ thị `limit_req_zone` để theo dõi tần suất gửi request của từng địa chỉ IP (`$binary_remote_addr`). Khi client vượt quá hạn mức 2 req/s, Nginx sẽ từ chối xử lý và trả về mã HTTP 429 (Too Many Requests), giúp bảo vệ tài nguyên ứng dụng phía sau không bị quá tải.
- **Câu hỏi 2: Tại sao cổng 3306 của MySQL không thể kết nối từ máy Host?**
  *Trả lời:* Vì trong `compose.yaml`, dịch vụ MySQL không khai báo chỉ thị `ports:` để ánh xạ ra ngoài, đồng thời mạng `backend` được thiết lập `internal: true`. Docker sẽ không tạo đường dẫn định tuyến ra ngoài, đảm bảo dữ liệu được cô lập tuyệt đối.
- **Câu hỏi 3: Vì sao container cAdvisor lại cần cờ `privileged: true`?**
  *Trả lời:* cAdvisor có nhiệm vụ thu thập chỉ số phần cứng của toàn bộ các container khác. Nó bắt buộc phải có quyền truy cập trực tiếp vào hệ thống cgroups của nhân Linux (`/sys/fs/cgroup`) và Docker daemon socket (`/var/run/docker.sock`). Đây là đặc thù kỹ thuật bắt buộc của công cụ giám sát container.

---
*(Vị trí dán ảnh minh chứng)*

```
+-------------------------------------------------------------------------+
|                                                                         |
|                [ DÁN ẢNH 11.1 VÀO ĐÂY: QUY TRÌNH LIVE DEMO HỆ THỐNG ]   |
|                                                                         |
+-------------------------------------------------------------------------+
```
**【 Ảnh 11.1 – Sơ đồ Trình tự 8 Bước Thực hiện Kịch bản Demo Trực tiếp trước Giảng viên 】**

---

# 12. KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN

## 12.1. Kết luận

Sau quá trình học tập, nghiên cứu và triển khai thực nghiệm, đề tài **"Hệ thống Quản lý Phòng Gym / Fitness (Titan Fitness) - Đề 23"** đã hoàn thành xuất sắc toàn bộ các mục tiêu đề ra:
- Xây dựng thành công hệ thống ứng dụng web chuyên nghiệp, ổn định và đầy đủ nghiệp vụ quản lý phòng tập.
- Triển khai và điều phối trơn tru 10 dịch vụ container hóa thông qua một file Docker Compose duy nhất.
- Đảm bảo an toàn thông tin với kiến trúc Ingress Nginx, mã hóa SSL/TLS SAN, bộ 8/8 Security Headers, Rate Limiting và cô lập mạng CSDL.
- Xây dựng hệ thống quan sát toàn diện (Full Observability) với bộ đôi Prometheus + Grafana và hệ thống nhật ký tập trung Loki + Promtail + LogQL.
- Thực thi xuất sắc các chính sách làm cứng bảo mật (Hardening), đạt kết quả kiểm thử tự động tuyệt đối 5/5 PASS.
- Toàn bộ quy trình phát triển được kiểm soát chặt chẽ bằng Git Flow và tài liệu hóa khoa học.

## 12.2. Hướng phát triển mở rộng

- **Triển khai Production với Domain thật và Let's Encrypt:** Sử dụng Certbot tự động gia hạn chứng chỉ SSL công khai thay vì chứng chỉ tự ký.
- **Tự động hóa CI/CD Pipeline:** Tích hợp GitHub Actions để tự động build Docker Image, quét lỗ hổng bảo mật (Trivy scan) và tự động deploy khi có commit mới.
- **Cảnh báo tự động (Alerting):** Tích hợp Prometheus Alertmanager gửi thông báo cảnh báo tức thì qua Telegram hoặc Discord khi có sự cố quá tải CPU hoặc sập dịch vụ.
- **Mở rộng cụm CSDL:** Cấu hình mô hình MySQL Master - Slave Replication để tăng cường khả năng chịu lỗi và cân bằng tải đọc ghi.

---

# PHỤ LỤC: DANH SÁCH HÌNH ẢNH MINH CHỨNG

Dưới đây là bảng tổng hợp danh mục toàn bộ **20 hình ảnh minh chứng thực nghiệm** được trích dẫn trong cuốn báo cáo:

| STT | Mã định danh hình ảnh | Tên / Chú thích hình ảnh minh chứng | Thuộc Chương | Mục đích minh chứng |
| :---: | :--- | :--- | :--- :--- | :--- |
| **1** | **Ảnh 1.1** | Giao diện Trang chủ Website Quản lý Phòng tập Titan Fitness | Chương 1 | Minh chứng ứng dụng web hoạt động thực tế. |
| **2** | **Ảnh 2.1** | Trạng thái khởi tạo các dịch vụ trên nền tảng Docker / WSL2 | Chương 2 | Minh chứng môi trường Docker Compose sẵn sàng. |
| **3** | **Hình 3.1** | Sơ đồ Kiến trúc Hệ thống Phân tầng và Luồng dữ liệu | Chương 3 | Minh chứng kiến trúc mạng Defense in Depth. |
| **4** | **Ảnh 3.2** | Cấu trúc Cây Thư mục Dự án gym-fitness trên WSL2 | Chương 3 | Minh chứng chuẩn hóa mã nguồn dự án. |
| **5** | **Ảnh 4.1** | Giao diện Website Titan Fitness và Form Đăng ký Tập thử | Chương 4 | Minh chứng nghiệp vụ đăng ký hội viên web. |
| **6** | **Ảnh 4.2** | Giao diện phpMyAdmin và Cấu trúc Bảng trong `gym_db` | Chương 4 | Minh chứng kết nối CSDL và dữ liệu quan hệ. |
| **7** | **Ảnh 5.1** | Website truy cập qua HTTPS với Ổ khóa xanh và SSL SAN | Chương 5 | Minh chứng mã hóa an toàn Ingress Gateway. |
| **8** | **Ảnh 5.2** | Nội dung File Cấu hình Ingress Gateway `nginx.conf` | Chương 5 | Minh chứng cấu hình proxy, SSL và headers. |
| **9** | **Ảnh 6.1** | Giao diện Prometheus `/targets` với 5/5 Targets UP | Chương 6 | Minh chứng thu thập chỉ số hệ thống toàn vẹn. |
| **10**| **Ảnh 6.2** | Bảng điều khiển Grafana Giám sát Toàn diện Hệ thống | Chương 6 | Minh chứng trực quan hóa số liệu container. |
| **11**| **Ảnh 7.1** | Grafana Explore thực thi truy vấn LogQL `{job="nginx"}` | Chương 7 | Minh chứng lưu trữ log tập trung tại Loki. |
| **12**| **Ảnh 7.2** | Grafana Explore lọc các bản ghi bị Rate Limit (Mã 429) | Chương 7 | Minh chứng phát hiện sự kiện an ninh qua log. |
| **13**| **Ảnh 7.3** | Grafana Explore phân tích giao dịch HTTP POST và App log | Chương 7 | Minh chứng khả năng truy vấn log nghiệp vụ. |
| **14**| **Ảnh 8.1** | Kiểm tra Cô lập CSDL: Cổng 3306 bị Chặn từ Host | Chương 8 | Minh chứng Hardening tầng mạng nội bộ. |
| **15**| **Ảnh 8.2** | Kết quả kịch bản bảo mật `security-audit.sh` (5/5 PASS) | Chương 8 | Minh chứng vượt qua 5 bài test an toàn thông tin. |
| **16**| **Ảnh 9.1** | Giao diện Kho lưu trữ GitHub của Dự án Titan Fitness | Chương 9 | Minh chứng quản lý mã nguồn trên GitHub. |
| **17**| **Ảnh 9.2** | Lịch sử Commit và Hệ thống Nhánh Git Flow Chuẩn hóa | Chương 9 | Minh chứng quy trình phát triển chuyên nghiệp. |
| **18**| **Ảnh 10.1**| Trạng thái Vận hành Ổn định của 11 Container (`docker compose ps`)| Chương 10| Minh chứng sức khỏe các dịch vụ hệ thống. |
| **19**| **Ảnh 10.2**| Kết quả Kiểm thử Thao tác Đăng ký Thành viên Mới | Chương 10| Minh chứng luồng dữ liệu thông suốt Web - DB. |
| **20**| **Ảnh 11.1**| Sơ đồ Trình tự 8 Bước Thực hiện Kịch bản Live Demo | Chương 11| Minh chứng kịch bản bảo vệ đồ án trước GVHD. |
