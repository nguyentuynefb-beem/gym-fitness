-- ====================================================================
-- Du lieu mau (Seed Data) cho He thong Quan ly Phong Gym / Fitness
-- Sinh vien: Nguyen Duc Tuyen - MSSV: DTC245200566
-- ====================================================================

USE gym_db;

-- 1. Seed Goi tap (packages)
INSERT INTO packages (id, name, category, duration_months, price, description, features) VALUES
(1, 'Gói Cơ Bản (Standard Gym)', 'Gym', 1, 450000, 
 'Tập luyện không giới hạn khung giờ tất cả các ngày trong tháng tại khu vực máy tập.', 
 'Tủ đồ thông minh, Tắm nóng lạnh, Đo chỉ số InBody miễn phí 1 lần/tháng'),

(2, 'Gói Nâng Cao (Gym & Cardio)', 'Gym', 3, 1200000, 
 'Toàn quyền sử dụng khu vực tạ tự do, máy khối, máy chạy và khu chức năng Functional Training.', 
 'Miễn phí tủ locker riêng, Khăn tập mỗi buổi, Đo InBody 2 lần/tháng, Tặng 1 buổi định hướng cùng PT'),

(3, 'Gói Yoga & Chữa Lành (Wellness)', 'Yoga', 6, 2800000, 
 'Tham gia không giới hạn các lớp Yoga cơ bản, Yoga chuỗi, Yin Yoga và Pilates thảm.', 
 'Thảm tập cao cấp, Phòng thiền yên tĩnh, Nước detox thảo mộc miễn phí, Xông hơi thảo dược sau buổi tập'),

(4, 'Gói VIP Toàn Năng (All-Access)', 'VIP', 12, 5500000, 
 'Gói tập đẳng cấp nhất: Tự do tập Gym, tham gia mọi lớp Yoga, Boxing và khu VIP Lounge.', 
 'Locker riêng VIP, Khăn tắm & nước khoáng mỗi ngày, Bể sục Jacuzzi & Sauna, Ưu tiên đặt lịch PT, Giảm 20% đồ uống'),

(5, 'Gói KickFit & Boxing Chiến Binh', 'Boxing', 1, 3000000, 
 'Chương trình rèn luyện thể lực và tự vệ 1 kèm 1 cường độ cao cùng Huấn luyện viên chuyên nghiệp.', 
 'Bao tay Boxing cá nhân, Nước điện giải mỗi buổi tập, Lịch tập linh hoạt tùy chọn cùng PT');

-- 2. Seed Huan luyen vien (trainers)
INSERT INTO trainers (id, full_name, phone, email, specialty, experience_years, bio, avatar_url, status) VALUES
(1, 'Trần Quốc Tuấn', '0912345671', 'tuan.tran@gymfitness.vn', 
 'Thể hình & Tăng cơ chuyên sâu', 6, 
 'Cựu vận động viên thể hình quốc gia, chuyên gia phục hồi chuyển hóa và siết cơ thi đấu.', 
 '/images/trainers/trainer-1.jpg', 'active'),

(2, 'Lê Hải Yến', '0912345672', 'yen.le@gymfitness.vn', 
 'Yoga Master & Hatha Flow', 5, 
 'Chứng chỉ Yoga Alliance RYT-500 tại Ấn Độ, chuyên trị liệu cột sống và giảm căng thẳng.', 
 '/images/trainers/trainer-2.jpg', 'active'),

(3, 'Vũ Hoàng Long', '0912345673', 'long.vu@gymfitness.vn', 
 'KickBoxing & Đốt mỡ cấp tốc (HIIT)', 4, 
 'Đai đen Taekwondo, chuyên gia huấn luyện thể lực đỉnh cao và kỹ năng phản xạ tự vệ.', 
 '/images/trainers/trainer-3.jpg', 'active'),

(4, 'Phạm Minh Châu', '0912345674', 'chau.pham@gymfitness.vn', 
 'Pilates & Chỉnh dáng cơ thể', 3, 
 'Chuyên gia huấn luyện cải thiện tư thế vẹo cột sống, thon gọn eo và phục hồi sau sinh.', 
 '/images/trainers/trainer-4.jpg', 'active');

-- 3. Seed Hoi vien (members)
INSERT INTO members (id, full_name, phone, email, gender, date_of_birth, package_id, start_date, end_date, status, notes) VALUES
(1, 'Nguyễn Văn An', '0901111001', 'an.nguyen@gmail.com', 'male', '1998-05-12', 1, '2026-10-01', '2026-11-01', 'active', 'Mục tiêu tăng 3kg cơ, tập sau giờ làm lúc 18h.'),
(2, 'Trần Thị Bích', '0901111002', 'bich.tran@gmail.com', 'female', '2001-08-20', 3, '2026-07-15', '2027-01-15', 'active', 'Học viên Yoga chăm chỉ, đăng ký kèm trị liệu đau vai gáy.'),
(3, 'Lê Hoàng Dũng', '0901111003', 'dung.le@gmail.com', 'male', '1995-12-04', 2, '2026-09-01', '2026-12-01', 'active', 'Tập luyện giữ vóc dáng và tim mạch khỏe mạnh.'),
(4, 'Phạm Ngọc Hà', '0901111004', 'ha.pham@gmail.com', 'female', '1999-03-18', 4, '2026-01-10', '2027-01-10', 'active', 'Hội viên VIP, sử dụng đầy đủ tiện ích xông hơi và bể sục.'),
(5, 'Đỗ Minh Khang', '0901111005', 'khang.do@gmail.com', 'male', '2002-11-25', 5, '2026-10-05', '2026-11-05', 'active', 'Tập Boxing giảm mỡ bụng, 3 buổi/tuần cùng PT Long.'),
(6, 'Vũ Phương Linh', '0901111006', 'linh.vu@gmail.com', 'female', '2000-07-09', 3, '2026-05-01', '2026-11-01', 'active', 'Đam mê Pilates và thiền chuông xoay.'),
(7, 'Hoàng Trọng Nghĩa', '0901111007', 'nghia.hoang@gmail.com', 'male', '1993-02-14', 1, '2026-08-10', '2026-09-10', 'expired', 'Gói tập đã hết hạn ngày 10/09, đang liên hệ tư vấn gia hạn.'),
(8, 'Bùi Thảo My', '0901111008', 'my.bui@gmail.com', 'female', '2003-09-30', 2, '2026-10-10', '2027-01-10', 'active', 'Sinh viên mới đăng ký, được hưởng ưu đãi giảm giá thẻ học kỳ.'),
(9, 'Đặng Quốc Huy', '0901111009', 'huy.dang@gmail.com', 'male', '1997-04-05', 4, '2026-10-12', '2027-10-12', 'active', 'Khách VIP vừa ký hợp đồng 1 năm, nhận phòng tủ locker số 12.'),
(10, 'Ngô Thanh Trúc', '0901111010', 'truc.ngo@gmail.com', 'female', '2004-01-22', 1, '2026-10-13', '2026-11-13', 'pending', 'Mới điền thông tin đăng ký dùng thử qua website, chờ xác nhận kích hoạt.');

-- 4. Seed Lich tap / Dat lich (schedules)
INSERT INTO schedules (id, member_id, trainer_id, session_date, time_slot, workout_type, status, notes) VALUES
(1, 1, 1, '2026-10-14', '18:00 - 19:30', 'Tập ngực & tay sau', 'scheduled', 'Kiểm tra kỹ thuật đẩy tạ đòn Bench Press.'),
(2, 2, 2, '2026-10-14', '07:00 - 08:30', 'Hatha Yoga cơ bản', 'scheduled', 'Tập thở Pranayama và giãn cơ lưng dưới.'),
(3, 5, 3, '2026-10-14', '19:30 - 21:00', 'KickFit & Đấm bao cát', 'scheduled', 'Buổi tập cường độ cao kết hợp nhảy dây đốt calo.'),
(4, 4, 4, '2026-10-15', '09:00 - 10:30', 'Pilates Re-former', 'scheduled', 'Chỉnh tư thế thắt lưng và cơ trọng tâm core.'),
(5, 3, 1, '2026-10-15', '17:30 - 19:00', 'Tập lưng xô & chân', 'scheduled', 'Deadlift đúng form, tăng tạ an toàn.'),
(6, 6, 2, '2026-10-16', '06:30 - 08:00', 'Vinyasa Flow đón bình minh', 'scheduled', 'Khởi động ngày mới với chuỗi chào mặt trời.'),
(7, 8, 3, '2026-10-16', '16:00 - 17:30', 'Cardio & Thể lực học đường', 'scheduled', 'Tập luyện tăng sức bền với tạ chuông Kettlebell.'),
(8, 1, 1, '2026-10-12', '18:00 - 19:30', 'Tập khởi động toàn thân', 'completed', 'Hội viên hoàn thành tốt giáo án buổi đầu tiên.'),
(9, 2, 2, '2026-10-11', '07:00 - 08:30', 'Yoga thư giãn cuối tuần', 'completed', 'Buổi tập kết thúc với 15 phút thư giãn Savasana sâu.'),
(10, 5, 3, '2026-10-13', '19:30 - 21:00', 'Boxing di chuyển bước chân', 'cancelled', 'Hội viên bận công tác đột xuất, dời lịch sang ngày 14.');
