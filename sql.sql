DROP DATABASE IF EXISTS bookdb;
CREATE DATABASE bookdb;
USE bookdb;
INSERT INTO category VALUES
('C01', 'Kinh doanh'),
('C02', 'Sức khỏe'),
('C03', 'Marketing'),
('C04', 'Lập trình'),
('C05', 'Truyện tranh'),
('C06', 'Công nghệ'),
('C07', 'Đời sống'),
('C08', 'Lịch sử'),
('C09', 'Giáo dục');

INSERT INTO customers (customerId, fullName, email, phone, address, dateOfBirth) VALUES
('CU01', 'Phan Tống Hoàng Bang', 'banghohoang16102005@gmail.com', '0328327303', 'Gia Lai', '2005-10-16'),
('CU02', 'Nguyễn Vũ Triết', 'nguyenvutriet0205@gmail.com', '0367182579', 'Bình Phước', '2005-05-02'),
('CU03', 'Huỳnh Gia Diễm Ngọc', 'ngochuynh150905@gmail.com', '0942327872', 'Khánh Hòa', '2005-09-15'),
('CU04', 'Võ Thị Mai Quỳnh', 'maiquynhvnlhb@gmail.com', '0386035123', 'Đồng Tháp', '2005-05-21'),
('CU05', 'Đào Nguyễn Nhật Anh', 'anhdnn@gmail.com', '0915345678', 'TP. HCM', '2005-10-09'),
('CU06', 'Trương Công Anh', 'anhtc@gmail.com', '0988654321', 'Bà Rịa - Vũng Tàu', '2005-09-07'),
('CU07', 'Nguyễn Thái Bảo', 'baont@gmail.com', '0905112233', 'Đồng Nai', '2005-05-04'),
('CU08', 'Nguyễn Phúc Huy Hoàng', 'hoangnph@gmail.com', '0904112233', 'Bà Rịa - Vũng Tàu', '2005-10-16'),
('CU09', 'Đoàn Quốc Huy', 'huyqd@gmail.com', '0901112234', 'Bến Tre', '2005-11-08'),
('CU10', 'Lê Quang Hưng', 'hunglq@gmail.com', '0901112235', 'Bình Thuận', '2005-09-23'),
('CU11', 'Lương Nguyễn Thành Hưng', 'hunglnth@gmail.com', '0901212233', 'Ninh Thuận', '2005-10-26'),
('CU12', 'Đoàn Ngọc Mạnh', 'manhdn@gmail.com', '0901112733', 'Đăk Nông', '2005-01-19'),
('CU13', 'Dương Trung Nam', 'namdt@gmail.com', '0901142233', 'Gia Lai', '2005-08-04'),
('CU14', 'Nguyễn Hoàng Phúc', 'phucnh@gmail.com', '0901192234', 'TP. HCM', '2005-06-25'),
('CU15', 'Trần Hoàng Phúc Quân', 'quanthp@gmail.com', '0901152433', 'Đà Nẵng', '2005-03-16'),
('CU16', 'Võ Tấn Tài', 'taivt@gmail.com', '0907752433', 'Tiền Giang', '2005-04-24'),
('CU17', 'Châu Minh Trọng', 'trongcm@gmail.com', '0901162433', 'Bến Tre', '2005-05-04'),
('CU18', 'Phạm Công Trường', 'truongpc@gmail.com', '0901157433', 'Bến Tre', '2005-08-12'),
('CU19', 'Hoàng Thanh Tú', 'tuht@gmail.com', '0901152413', 'Nghệ An', '2005-06-24'),
('CU20', 'Phạm Lê Anh Tú', 'tupla@gmail.com', '0921152433', 'Bến Tre', '2005-07-01'),
('CU21', 'Nguyễn Đoàn Trường Vĩ', 'vindt@gmail.com', '0901142493', 'Bến Tre', '2005-01-17'),
('CU22', 'Nguyễn Thanh Phúc', 'phucnt@gmail.com', '0901932433', 'Bình Thuận', '2005-03-16'),
('CU23', 'Lâm Khánh Duy', 'duylk@gmail.com', '0911152443', 'Kiên Giang', '2005-05-28'),
('CU24', 'Nguyễn Văn Quang Duy', 'duynvq@gmail.com', '0901252433', 'TP. HCM', '2005-10-16'),
('CU25', 'Hoàng Văn Đông', 'donghv@gmail.com', '0901152433', 'Đăk Nông', '2005-03-15'),
('CU26', 'Nguyễn Hoàng Giáp', 'giapnh@gmail.com', '0901952433', 'TP. HCM', '2005-03-17'),
('CU27', 'Đặng Gia Huy', 'huydg@gmail.com', '0901152463', 'TP. HCM', '2005-09-30'),
('CU28', 'Nguyễn Trường Minh', 'minhnt@gmail.com', '0901152573', 'Bà Rịa - Vũng Tàu', '2005-09-20'),
('CU29', 'Đặng Quang Hoàng Nghĩa', 'nghiadqh@gmail.com', '0902252433', 'Ninh Thuận', '2005-03-24'),
('CU30', 'Huỳnh Anh Nguyên', 'nguyenha@gmail.com', '0901152123', 'Gia Lai', '2005-04-11'),
('CU31', 'Trần Minh Trọng Nhân', 'nhantmt@gmail.com', '0907252433', 'TP. HCM', '2005-07-22'),
('CU32', 'Nguyễn Tấn Phát', 'phatnt@gmail.com', '0901152448', 'Kiên Giang', '2005-06-23'),
('CU33', 'Phan Hồng Phúc', 'phucph@gmail.com', '0901152459', 'Gia Lai', '2005-12-25'),
('CU34', 'Nguyễn Nhật Thiên', 'thiennn@gmail.com', '0901232433', 'Bến Tre', '2005-05-21'),
('CU35', 'Nguyễn Lê Đức Tuệ', 'tuenld@gmail.com', '0901452433', 'Phú Yên', '2005-03-10'),
('CU36', 'Nguyễn Thành Vinh', 'vinhnt@gmail.com', '0901672433', 'TP. HCM', '2005-04-30'),
('CU37', 'Nguyễn Vũ Bảo', 'baonv@gmail.com', '0911223344', 'Quảng Trị', '2005-09-28'),
('CU38', 'Đinh Lê Hoàng Danh', 'danhdlh@gmail.com', '0911223345', 'TP. HCM', '2005-02-15'),
('CU39', 'Huỳnh Gia Định', 'dinhhg@gmail.com', '0911223346', 'Phú Yên', '2005-03-23'),
('CU40', 'Nguyễn Nhật Huy', 'huynn@gmail.com', '0911223347', 'Khánh Hòa', '2005-11-21'),
('CU41', 'Nguyễn Minh Quốc Khánh', 'khanhnmq@gmail.com', '0911223348', 'Tiền Giang', '2005-09-09'),
('CU42', 'Phạm Minh Khánh', 'khanhpm@gmail.com', '0911223349', 'TP. HCM', '2005-05-20'),
('CU43', 'Trần Đăng Khoa', 'khoatd@gmail.com', '0902222433', 'An Giang', '2005-01-15'),
('CU44', 'Trần Cẩm Long', 'longtc@gmail.com', '0902232433', 'Lâm Đồng', '2005-06-14'),
('CU45', 'Nguyễn Hưng Nguyên', 'hungnh@gmail.com', '0902242433', 'Tây Ninh', '2005-12-17'),
('CU46', 'Ô Duy Hoàng Thiện', 'thienodh@gmail.com', '0902252433', 'Khánh Hòa', '2005-02-11'),
('CU47', 'Lưu Quang Tiến', 'tienlq@gmail.com', '0902262433', 'Bình Phước', '2005-01-09'),
('CU48', 'Trần Quang Tiến', 'tientq@gmail.com', '0902272433', 'Quảng Trị', '2005-10-20'),
('CU49', 'Trần Quang Toản', 'toantq@gmail.com', '0902282433', 'Lâm Đồng', '2005-07-14'),
('CU50', 'Trần Văn Tưởng', 'tuongtv@gmail.com', '0902442433', 'Gia Lai', '2005-08-26'),
('CU51', 'Nguyễn Quốc Vĩ', 'vinq@gmail.com', '0902552433', 'Kiên Giang', '2005-10-14'),
('CU52', 'Phạm Thị Vân Ánh', 'anhptv@gmail.com', '0901168433', 'Hà Tĩnh', '2005-07-24'),
('CU53', 'Tạ Hoàng Đạt', 'datth@gmail.com', '0901157343', 'Yên Bái', '2005-03-30'),
('CU54', 'Vũ Minh Đức', 'ducvm@gmail.com', '0901152521', 'TP. HCM', '2005-07-24');


INSERT INTO Users 
(userName, password, role, fullName, registrationDate, customerId, enabled, email_verified)
VALUES
('hoangbang', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Phan Tống Hoàng Bang', CURRENT_DATE, 'CU01',1,1),
('vutriet', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Nguyễn Vũ Triết', CURRENT_DATE, 'CU02',1,1),
('diemngoc', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Huỳnh Gia Diễm Ngọc', CURRENT_DATE, 'CU03',1,1),
('maiquynh', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Võ Thị Mai Quỳnh', CURRENT_DATE, 'CU04',1,1),
('nhatanh', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Đào Nguyễn Nhật Anh', CURRENT_DATE, 'CU05',1,1),
('conganh', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Trương Công Anh', CURRENT_DATE, 'CU06',1,1),
('thaibao', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Nguyễn Thái Bảo', CURRENT_DATE, 'CU07',1,1),
('huyhoang', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Nguyễn Phúc Huy Hoàng', CURRENT_DATE, 'CU08',1,1),
('quochoang', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Đoàn Quốc Huy', CURRENT_DATE, 'CU09',1,1),
('quanghung', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Lê Quang Hưng', CURRENT_DATE, 'CU10',1,1),
('thanhhung', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Lương Nguyễn Thành Hưng', CURRENT_DATE, 'CU11',1,1),
('ngocmanh', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Đoàn Ngọc Mạnh', CURRENT_DATE, 'CU12',1,1),
('trungnam', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Dương Trung Nam', CURRENT_DATE, 'CU13',1,1),
('hoangphuc', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Nguyễn Hoàng Phúc', CURRENT_DATE, 'CU14',1,1),
('hoangquân', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Trần Hoàng Phúc Quân', CURRENT_DATE, 'CU15',1,1),
('tantai', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Võ Tấn Tài', CURRENT_DATE, 'CU16',1,1),
('minhtrong', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Châu Minh Trọng', CURRENT_DATE, 'CU17',1,1),
('congtruong', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Phạm Công Trường', CURRENT_DATE, 'CU18',1,1),
('thanhtu', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Hoàng Thanh Tú', CURRENT_DATE, 'CU19',1,1),
('anhtu', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Phạm Lê Anh Tú', CURRENT_DATE, 'CU20',1,1),
('truongvi', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Nguyễn Đoàn Trường Vĩ', CURRENT_DATE, 'CU21',1,1),
('thanhphuc', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Nguyễn Thanh Phúc', CURRENT_DATE, 'CU22',1,1),
('khanduy', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Lâm Khánh Duy', CURRENT_DATE, 'CU23',1,1),
('quangduy', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Nguyễn Văn Quang Duy', CURRENT_DATE, 'CU24',1,1),
('vandong', '$2a$12$2AmTP34lQ.c.z7KWTflTH.aeuEC9C3ijCfnAScz8gV1FQ1rqEBCgi', 'ROLE_CUSTOMER', 'Hoàng Văn Đông', CURRENT_DATE, 'CU25',1,1),
('hoanggiap', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Hoàng Giáp', CURRENT_DATE, 'CU26',1,1),
('giahuy', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Đặng Gia Huy', CURRENT_DATE, 'CU27',1,1),
('truongminh', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Trường Minh', CURRENT_DATE, 'CU28',1,1),
('hoangnghia', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Đặng Quang Hoàng Nghĩa', CURRENT_DATE, 'CU29',1,1),
('anhnguyen', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Huỳnh Anh Nguyên', CURRENT_DATE, 'CU30',1,1),
('trongnhan', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Trần Minh Trọng Nhân', CURRENT_DATE, 'CU31',1,1),
('tanphat', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Tấn Phát', CURRENT_DATE, 'CU32',1,1),
('hongphuc', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Phan Hồng Phúc', CURRENT_DATE, 'CU33',1,1),
('nhatthien', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Nhật Thiên', CURRENT_DATE, 'CU34',1,1),
('ductue', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Lê Đức Tuệ', CURRENT_DATE, 'CU35',1,1),
('thanhvinh', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Thành Vinh', CURRENT_DATE, 'CU36',1,1),
('vubao', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Vũ Bảo', CURRENT_DATE, 'CU37',1,1),
('hoangdanh', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Đinh Lê Hoàng Danh', CURRENT_DATE, 'CU38',1,1),
('giadhinh', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Huỳnh Gia Định', CURRENT_DATE, 'CU39',1,1),
('nhathuy', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Nhật Huy', CURRENT_DATE, 'CU40',1,1),
('quockhanh', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Minh Quốc Khánh', CURRENT_DATE, 'CU41',1,1),
('minhkhanh', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Phạm Minh Khánh', CURRENT_DATE, 'CU42',1,1),
('dangkhoa', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Trần Đăng Khoa', CURRENT_DATE, 'CU43',1,1),
('camlong', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Trần Cẩm Long', CURRENT_DATE, 'CU44',1,1),
('hungnguyen', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Hưng Nguyên', CURRENT_DATE, 'CU45',1,1),
('duythien', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Ô Duy Hoàng Thiện', CURRENT_DATE, 'CU46',1,1),
('quangtienl', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Lưu Quang Tiến', CURRENT_DATE, 'CU47',1,1),
('quangtient', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Trần Quang Tiến', CURRENT_DATE, 'CU48',1,1),
('quantoan', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Trần Quang Toản', CURRENT_DATE, 'CU49',1,1),
('vantuong', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Trần Văn Tưởng', CURRENT_DATE, 'CU50',1,1),
('quocvi', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Nguyễn Quốc Vĩ', CURRENT_DATE, 'CU51',1,1),
('vananh', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Phạm Thị Vân Ánh', CURRENT_DATE, 'CU52',1,1),
('hoangdat', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Tạ Hoàng Đạt', CURRENT_DATE, 'CU53',1,1),
('minhduc', '$2a$12$o2ldvPsqcZmATybq/SM.euTy4LEqQDQXHS6H3eRf8Jd/RfriOi0L2', 'ROLE_CUSTOMER', 'Vũ Minh Đức', CURRENT_DATE, 'CU54',1,1);

INSERT INTO cart (cartId, quantity, totalAmount, customerId) VALUES
('CA01', 4, 546620.00, 'CU01'),
('CA02', 0, 0.00, 'CU02'),
('CA03', 0, 0.00, 'CU03'),
('CA04', 0, 0.00, 'CU04'),
('CA05', 6, 723510.00, 'CU05'),
('CA06', 0, 0.00, 'CU06'),
('CA07', 0, 0.00, 'CU07'),
('CA08', 0, 0.00, 'CU08'),
('CA09', 0, 0.00, 'CU09'),
('CA10', 0, 0.00, 'CU10'),
('CA11', 0, 0.00, 'CU11'),
('CA12', 5, 1130000.00, 'CU12'),
('CA13', 0, 0.00, 'CU13'),
('CA14', 0, 0.00, 'CU14'),
('CA15', 0, 0.00, 'CU15'),
('CA16', 0, 0.00, 'CU16'),
('CA17', 0, 0.00, 'CU17'),
('CA18', 0, 0.00, 'CU18'),
('CA19', 0, 0.00, 'CU19'),
('CA20', 0, 0.00, 'CU20'),
('CA21', 0, 0.00, 'CU21'),
('CA22', 0, 0.00, 'CU22'),
('CA23', 0, 0.00, 'CU23'),
('CA24', 0, 0.00, 'CU24'),
('CA25', 0, 0.00, 'CU25'),
('CA26', 0, 0.00, 'CU26'),
('CA27', 0, 0.00, 'CU27'),
('CA28', 0, 0.00, 'CU28'),
('CA29', 0, 0.00, 'CU29'),
('CA30', 0, 0.00, 'CU30'),
('CA31', 0, 0.00, 'CU31'),
('CA32', 0, 0.00, 'CU32'),
('CA33', 0, 0.00, 'CU33'),
('CA34', 0, 0.00, 'CU34'),
('CA35', 0, 0.00, 'CU35'),
('CA36', 0, 0.00, 'CU36'),
('CA37', 0, 0.00, 'CU37'),
('CA38', 0, 0.00, 'CU38'),
('CA39', 0, 0.00, 'CU39'),
('CA40', 0, 0.00, 'CU40'),
('CA41', 0, 0.00, 'CU41'),
('CA42', 0, 0.00, 'CU42'),
('CA43', 0, 0.00, 'CU43'),
('CA44', 0, 0.00, 'CU44'),
('CA45', 0, 0.00, 'CU45'),
('CA46', 0, 0.00, 'CU46'),
('CA47', 0, 0.00, 'CU47'),
('CA48', 0, 0.00, 'CU48'),
('CA49', 0, 0.00, 'CU49'),
('CA50', 0, 0.00, 'CU50'),
('CA51', 0, 0.00, 'CU51'),
('CA52', 0, 0.00, 'CU52'),
('CA53', 0, 0.00, 'CU53'),
('CA54', 0, 0.00, 'CU54');
USE bookdb;

INSERT INTO books (bookId, title , author, publisher, publicationYear, description, price, quantity, picture, categoryId, isActive, original_price, soldQuantity ) VALUES
('KD01', 'Lược sử Kinh tế học lầy lội', 'Chen Loi & Cộng sự', 'NXB Hồng Đức', 2018,
'"Lược sử kinh tế học lầy lội: Khủng hoảng dạy cho ta những gì? – Tập 1" là cuốn sách độc đáo đưa người đọc khám phá thế giới kinh tế học qua lăng kính hài hước, gần gũi và dễ hiểu. Thay vì dùng những công thức rối rắm hay các mô hình lý thuyết phức tạp, sách chọn cách tiếp cận bằng những câu chuyện có thật về các cuộc khủng hoảng tài chính nổi tiếng trong lịch sử.
Với giọng kể dí dỏm, cách minh họa sinh động, tác phẩm biến những chủ đề tưởng chừng khô khan thành hành trình khám phá thú vị, khiến kinh tế học trở thành một "người bạn" thân thiện, dễ trò chuyện và dễ hiểu.', 229000, 1000, 'img1.jpg', 'C01', 1, 200000, 400),
('KD02', 'Warren Buffett - Quá Trình Hình Thành Một Nhà Tư Bản Mỹ (Tái Bản)', 'Minh Diệu, Phương Lan dịch', 'NXB Công Thương', 2021,
'Warren Buffett - Quá Trình Hình Thành Một Nhà Tư Bản Mỹ là câu chuyện thú vị về cuộc đời và triết lý đầu tư của nhà lựa chọn cổ phiếu thành công nhất nước Mỹ. Tác giả Roger Lowenstein đã chỉ ra rằng phương pháp đầu tư của Buffett là sự phản chiếu của những giá trị cuộc sống mà ông theo đuổi. Cuốn sách lần theo hành trình từ khi ông còn giao báo cho đến khi trở thành nhà đầu tư vĩ đại.',
200790, 1000, 'https://images.unsplash.com/photo-1512820790803-83ca734da794', 'C01', 1, 200000, 400),

('KD03', 'Phương Pháp Đầu Tư Warren Buffett', 'Robert G.Hagstrom', 'NXB Công Thương', 2021,
'Cuốn sách phân tích phong cách đầu tư của Warren Buffett, hệ thống 12 nguyên lý cốt lõi giúp chọn doanh nghiệp và xây dựng danh mục đầu tư hiệu quả.',
108200, 1000, 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d', 'C01', 1, 200000, 400),

('KD04', 'Binh Pháp Tôn Tử Trong Kinh Doanh', 'Becky Sheetz-Runkle', 'Prentice Hall', 2020,
'Áp dụng chiến lược Tôn Tử vào kinh doanh giúp doanh nghiệp nhỏ cạnh tranh hiệu quả trong thị trường khốc liệt.',
100300, 1000, 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f', 'C01', 1, 200000, 400),
('SK01', 'Làm sạch mạch và máu', 'Nishi Katsuzo', 'NXB Lao Động', 2024,
'Nhiều bạn đọc Việt Nam mến trọng tác giả Nishi Katsuzo có thể đã từng biết đến cuốn Những phương thức phục hồi sức khỏe theo tự nhiên. Cuốn sách này tiếp tục mang đến những thông tin quan trọng về việc chăm sóc sức khỏe, phòng tránh các bệnh nguy hiểm như nhồi máu cơ tim, tai biến mạch máu não và nhiều vấn đề sức khỏe nghiêm trọng khác.',
87200, 1000, 'img5.jpg', 'C02', 1, 200000, 400),

('SK02', 'Cơ Thể Tự Chữa Lành: Giải Cứu Não', 'Anthony William', 'NXB Thanh Niên', 2023,
'Cuốn sách đi sâu vào các vấn đề liên quan đến não bộ như virus, vi khuẩn, kim loại nặng, dược phẩm tồn lưu, các chất ô nhiễm và bức xạ trong cuộc sống hiện đại. Tác giả cũng lý giải nhiều triệu chứng và bệnh trạng tâm thần khiến nhiều bác sĩ và người bệnh gặp khó khăn.',
339300, 1000, 'img6.jpg', 'C02', 1, 200000, 400),

('SK03', 'Sống lành để trẻ', 'Norman W. Walker', 'NXB Công Thương', 2024,
'Cuốn sách nhấn mạnh rằng để trẻ hóa, con người cần tìm ra những nguyên lý cơ bản và chính xác về sức khỏe. Tác giả chia sẻ kinh nghiệm sống khỏe, minh mẫn và tràn đầy năng lượng, đồng thời khuyến khích người đọc nghiên cứu, thay đổi thói quen và hướng tới một cuộc sống trẻ khỏe hơn.',
81750, 1000, 'img7.jpg', 'C02', 1, 200000, 400),

('SK04', 'Khi Hơi Thở Hóa Thinh Không', 'Trần Thanh Hương', 'NXB Lao Động', 2025,
'Khi Hơi Thở Hóa Thinh Không là tự truyện cảm động của một bác sĩ mắc ung thư phổi. Tác phẩm ghi lại hành trình từ những ngày đầu học y, tiếp xúc bệnh nhân cho đến khi phát hiện bệnh và điều trị. Cuốn sách chứa đựng những suy ngẫm sâu sắc về sự sống, cái chết và giá trị của một cuộc đời đáng sống.',
87200, 1000, 'img8.jpg', 'C02', 1, 200000, 400),
('MK01', 'Sách - Marketing Thực Chiến - Từ Chiến Lược Đến Thực Thi', 'John Westwood', 'NXB Dân Trí', 2020,
'Cuốn sách cung cấp các bài tập thực tế, bảng mẫu hữu ích, tóm tắt chương và một kế hoạch marketing mẫu chi tiết để giúp người đọc phát triển kỹ năng kinh doanh quan trọng. Đây là tài liệu cần thiết cho bất kỳ ai muốn thúc đẩy sản phẩm hoặc doanh nghiệp của mình.',
127710, 1000, 'img9.jpg', 'C03', 1, 200000, 500),

('MK02', 'Tâm Lý Học Hành Vi Trong Marketing', 'Tara-Nicholle Nelson', 'NXB Công Thương', 2024,
'Cuốn sách nhấn mạnh rằng chìa khóa phát triển doanh nghiệp ngày nay không chỉ là công nghệ hay mạng xã hội, mà là khả năng thu hút người tiêu dùng bằng cách khơi dậy mong muốn phát triển và biến đổi sâu sắc bên trong họ.',
137970, 1000, 'img10.jpg', 'C03', 1, 200000, 400),

('MK03', 'Con bò tía', 'Seth Godin', 'NXB Lao Động', 2023,
'Con bò tía là cuốn sách nói về sự khác biệt trong marketing. Tác giả chỉ ra rằng những thứ bình thường sẽ nhanh chóng trở nên nhàm chán, còn sự độc đáo mới là yếu tố giúp sản phẩm hay thương hiệu trở nên nổi bật và đáng chú ý.',
135200, 1000, 'img11.jpg', 'C03', 1, 200000, 456),

('MK04', 'Marketing Matters', 'Linh Đàm', 'NXB Thế Giới', 2025,
'Cuốn sách nhấn mạnh vai trò của văn hóa và thế giới quan trong marketing. Theo tác giả, nhiệm vụ của nhà tiếp thị là kể một câu chuyện có sức vang với đúng đối tượng, thay vì chỉ dựa vào những ý tưởng cấp tiến.',
183200, 1000, 'img12.jpg', 'C03', 1, 200000, 400),

('LT01', 'Giáo trình Lập trình Web', 'TS. Đoàn Thanh Nghị', 'NXB Đại học Quốc gia Hồ Chí Minh', 2022,
'Giáo trình cung cấp kiến thức nền tảng về thiết kế và lập trình web: HTML, CSS, JavaScript, PHP và MySQL. Kèm theo hệ thống bài tập thực hành giúp người học xây dựng website hoàn chỉnh.',
99999, 1000, 'img13.jpg', 'C04', 1, 200000, 400),

('LT02', 'LUYỆN THI HỘI THI TIN HỌC TRẺ VỚI SCRATCH 3', 'Học Viện VIETSTEM', 'NXB Đại học Quốc gia Hà Nội', 2023,
'Sách luyện thi tin học trẻ với Scratch 3 dành cho học sinh tiểu học, giúp nâng cao kỹ năng lập trình cơ bản.',
250000, 1000, 'img14.jpg', 'C04', 1, 200000, 400),

('LT03', 'Hành Trang Lập Trình - Những Kỹ Năng Lập Trình Viên Chuyên Nghiệp Cần Có', 'Vũ Công Tấn Tài', 'NXB Thanh Niên', 2020,
'Cuốn sách chia sẻ kinh nghiệm và kỹ năng cần thiết cho lập trình viên, giúp người học hiểu rõ hơn về nghề và con đường phát triển trong lĩnh vực phần mềm.',
179000, 1000, 'img15.jpg', 'C04', 1, 200000, 498),

('LT04', 'ĐƯỜNG VÀO LẬP TRÌNH PYTHON NÂNG CAO', 'PGS.TS Nguyễn Ngọc Giang', 'NXB Thế Giới', 2025,
'Sách cung cấp kiến thức về Python trong bối cảnh AI, Machine Learning và Data Science, giúp người học tiếp cận lập trình hiện đại một cách hiệu quả.',
289000, 1000, 'img16.jpg', 'C04', 1, 200000, 498),

('TT01', 'Công Chúa Tóc Cam', 'Kolya Bùi', 'NXB Hà Nội', 2024,
'Truyện tranh hài hước kể về cô công chúa tóc cam với tính cách đáng yêu, mang lại tiếng cười và sự giải trí cho người đọc.',
111200, 1000, 'img17.jpg', 'C05', 1, 200000, 400),

('TT02', 'Cuộc Phiêu Lưu Của Thuyền Trưởng Sinbad', 'Nghệ Sĩ Quang Thảo', 'NXB Dân Trí', 2024,
'Câu chuyện phiêu lưu của Sinbad bảo vệ Thủy ngọc quyền năng, mang thông điệp về tình yêu thương và bảo vệ môi trường.',
135000, 1000, 'img18.jpg', 'C05', 1, 200000, 400),

('TT03', 'Ếch Ộp - Thời Vàng Son Để Lại', 'Nguyễn Hưng', 'NXB Dân Trí', 2024,
'Những câu chuyện đời thường hài hước nhưng sâu sắc, giúp người đọc nhìn lại bản thân và cảm xúc của mình.',
87200, 1000, 'img19.jpg', 'C05', 1, 200000, 400),

('TT04', 'Em Trai Hàng Xóm Bướng Bỉnh Quá', 'S Monkey', 'NXB Dân Trí', 2023,
'Câu chuyện tình cảm xen lẫn drama giữa các nhân vật trẻ, với nhiều tình huống cảm xúc và bất ngờ.',
183200, 1000, 'img20.jpg', 'C05', 1, 200000, 400),

('CN01', 'Quản Lý Nhân Sự Trong Thời Đại Công Nghệ', 'Peter F. Drucker', 'NXB Công Thương', 2025,
'Cuốn sách gồm 12 bài viết kinh điển của Peter Drucker, tập trung làm rõ vai trò của con người trong thời đại công nghệ và những thay đổi trong quản trị hiện đại.',
143200, 1000, 'img21.jpg', 'C06', 1, 200000, 400),

('CN02', 'Quản Lý Công Nghệ Thông Tin Trong Y Tế - Chiến Lược, Tầm Nhìn Và Kỹ Năng', 'Susan T. Snedaker', 'NXB Thế Giới', 2025,
'Cẩm nang thực hành dành cho lãnh đạo CNTT trong ngành y tế, kết hợp công nghệ với kỹ năng quản trị và định hướng chiến lược.',
137970, 1000, 'img22.jpg', 'C06', 1, 200000, 400),

('CN03', 'NVIDIA - Gã Khổng Lồ Công Nghệ Thống Trị Chip Bán Dẫn AI', 'Tsuda Kenji', 'NXB Công Thương', 2025,
'Câu chuyện về NVIDIA và hành trình trở thành công ty dẫn đầu trong lĩnh vực AI nhờ tận dụng sức mạnh của GPU và công nghệ học sâu.',
151200, 1000, 'img23.jpg', 'C06', 1, 200000, 400),

('CN04', 'Mã Hóa Đằng - Nhà Lãnh Đạo Trầm Lặng', 'Trương Diễm Hà', 'NXB Dân Trí', 2024,
'Tiểu sử Mã Hóa Đằng và hành trình xây dựng Tencent trở thành tập đoàn công nghệ hàng đầu với các sản phẩm như QQ và WeChat.',
120000, 1000, 'img24.jpg', 'C06', 1, 200000, 400),

('ĐS01', 'Công Việc - Tình - Tiền: Đời Sống Thực Tế Trên Hành Trình Tâm Linh', 'Chogyam Trungpa', 'NXB Lao Động', 2013,
'Cuốn sách chia sẻ cách đối diện với cuộc sống hàng ngày bằng sự tỉnh thức, lòng tự trọng và niềm vui trên hành trình tâm linh.',
41250, 1000, 'img25.jpg', 'C07', 1, 200000, 400),

('ĐS02', 'Đời Sống Của Phụ Nữ Ai Cập Cổ Đại', 'Lisa K. Sabbahy', 'NXB Hồng Đức', 2025,
'Khám phá vai trò của phụ nữ Ai Cập cổ đại qua góc nhìn khảo cổ và lịch sử, từ đời sống gia đình đến hoạt động kinh tế và tôn giáo.',
148000, 1000, 'img26.jpg', 'C07', 1, 200000, 400),

('ĐS03', 'Đời Sống Bí Ẩn Của Cây', 'Peter Wohlleben', 'NXB Thế Giới', 2025,
'Cuốn sách khám phá thế giới bí ẩn của cây cối và cách chúng giao tiếp, sinh tồn trong tự nhiên.',
126650, 10000, 'img27.jpg', 'C07', 1, 200000, 400),

('ĐS04', 'Krishnamurti Nói Về Đời Sống - Tập 3', 'J. Krishnamurti', 'NXB Dân Trí', 2024,
'Những suy ngẫm sâu sắc về cuộc sống, thiên nhiên và con người, giúp người đọc tìm ra ý nghĩa và sự thay đổi trong bản thân.',
254150, 1000, 'img28.jpg', 'C07', 1, 200000, 400),

('LS01', 'Chủng Tộc Và Lịch Sử', 'Claude Lévi-Strauss', 'NXB Hà Nội', 2025,
'Cuốn sách là một tuyên ngôn về sự bình đẳng trí tuệ của loài người, đồng thời phản ánh các vấn đề nhân chủng học và lịch sử chủng tộc.',
106250, 1000, 'img29.jpg', 'C08', 1, 200000, 400),

('LS02', 'Xứ Đàng Trong - Lịch Sử Kinh Tế - Xã Hội Việt Nam Thế Kỷ 17 Và 18', 'Li Tana', 'NXB Trẻ', 2025,
'Nghiên cứu về quá trình hình thành và phát triển của xứ Đàng Trong, tập trung vào kinh tế, xã hội và giao thương trong lịch sử Việt Nam.',
120000, 1000, 'img30.jpg', 'C08', 1, 200000, 400),

('LS03', 'Di Sản Tư Tưởng Ả Rập Trong Dòng Chảy Lịch Sử Nhân Loại', 'De Lacy O’Leary', 'NXB Tri Thức', 2025,
'Cuốn sách trình bày sự phát triển tư tưởng Ả Rập và vai trò của nó trong việc thúc đẩy thời kỳ Phục hưng của châu Âu.',
135200, 1000, 'img31.jpg', 'C08', 1, 200000, 400),

('LS04', 'Đất Nước Việt Nam Qua Các Đời', 'Đào Duy Anh', 'NXB Thế Giới', 2025,
'Công trình nghiên cứu địa lý lịch sử Việt Nam qua các thời kỳ, từ sơ khai đến mở rộng lãnh thổ.',
191250, 1000, 'img32.jpg', 'C08', 1, 200000, 400),

('GD01', 'Nếp Nhà - Gia Đình Giáo Dục - Phép Dạy Con', 'Nguyễn Bá Học', 'NXB Kim Đồng', 2025,
'Cuốn sách đưa ra các phương pháp giáo dục con cái trong gia đình, giúp hình thành nhân cách và lối sống tốt.',
38000, 1000, 'img33.jpg', 'C09', 1, 200000, 400),

('GD02', 'Dạy Con Kiểu Do Thái', 'Kim Jung Jin', 'NXB Hồng Đức', 2025,
'Chia sẻ phương pháp giáo dục của người Do Thái, nhấn mạnh vai trò của gia đình và môi trường sống trong việc phát triển trí tuệ trẻ.',
75650, 1000, 'img34.jpg', 'C09', 1, 200000, 400),

('GD03', 'Cẩm Nang Sơ Cấp Cứu Trẻ Em', 'DK', 'NXB Dân Trí', 2019,
'Cuốn sách cung cấp kiến thức sơ cấp cứu cho trẻ em, giúp phụ huynh và giáo viên xử lý các tình huống khẩn cấp hiệu quả.',
159200, 1000, 'img35.jpg', 'C09', 1, 200000, 400),

('GD04', 'Kì Tích Giáo Dục Gia Đình - Con Đường Đến Harvard Của Cô Gái Trương An Kỳ', 'Vương Phi, Trương An Kỳ', 'NXB Dân Số', 2024,
'Ghi chép về hành trình giáo dục con cái toàn diện, hướng đến phát triển cả tri thức lẫn nhân cách.',
140000, 1000, 'img36.jpg', 'C09', 1, 200000, 400),

('KD05', 'Bí Quyết Kinh Doanh Trà Sữa - Cà Phê - Bánh Ngọt', 'Dung Lợi', 'NXB Thế Giới', 2025,
'Cuốn sách hướng dẫn từ A-Z cách mở và quản lý cửa hàng trà sữa, cà phê, bánh ngọt cho người mới bắt đầu.',
152150, 1000, 'img37.jpg', 'C01', 1, 200000, 400),

('KD06', 'Hành Trình Kinh Doanh Trực Tuyến 28 Ngày', 'Carrie Green', 'NXB Công Thương', 2020,
'Cuốn sách chia sẻ cách tận dụng Internet để bắt đầu kinh doanh online, kết nối với nguồn kiến thức và cơ hội toàn cầu.',
120000, 1000, 'img38.jpg', 'C01', 1, 200000, 400),

('KD07', '50 Ý Tưởng Kinh Doanh Đỉnh Nhất', 'Ian Wallis', 'NXB Thế Giới', 2017,
'Tổng hợp 50 ý tưởng kinh doanh sáng tạo, từ cải tiến công nghệ đến chính sách đổi mới giúp nâng cao hiệu suất và sáng tạo.',
104300, 1000, 'img39.jpg', 'C01', 1, 200000, 400),

('KD08', 'Kinh Doanh Trong Thời Đại Hậu Sự Thật', 'Sean Pillot De Chenecey', 'NXB Công Thương', 2025,
'Phân tích các case-study về thương hiệu trong thời đại thiếu niềm tin và đưa ra hướng đi cho doanh nghiệp.',
196000, 1000, 'img40.jpg', 'C01', 1, 200000, 400),

('SK05', 'Cỗ Máy Sự Sống - Ti Thể - Chìa Khóa Cho Sức Khỏe Toàn Diện', 'Daria Mochly-Rosen, Emanuel Rosen', 'NXB Thanh Hóa', 2025,
'Giải thích vai trò của ti thể trong cơ thể và cách cải thiện sức khỏe dựa trên khoa học hiện đại.',
171000, 1000, 'img41.jpg', 'C02', 1, 200000, 400),

('SK06', 'Kiến Thức Cơ Bản Nâng Cao Sức Khỏe', 'Phương Nam Đình', 'NXB Hà Nội', 2025,
'Cung cấp kiến thức cơ bản về sức khỏe, dinh dưỡng, môi trường và phương pháp phòng ngừa bệnh.',
54400, 1000, 'img42.jpg', 'C02', 1, 200000, 400),

('SK07', 'Tâm Lý Học Sức Khỏe', 'TS. Phạm Toàn', 'NXB Trẻ', 2025,
'Phân tích các yếu tố tâm lý ảnh hưởng đến sức khỏe và các nghiên cứu về thói quen, bệnh tật và tuổi thọ.',
132000, 1000, 'img43.jpg', 'C02', 1, 200000, 400),

('SK08', 'Thực Hành Thai Giáo', 'ThS. Đỗ Thanh Huyền', 'NXB Công Thương', 2024,
'Hướng dẫn chi tiết các phương pháp thai giáo theo từng giai đoạn, giúp mẹ và bé phát triển tốt nhất.',
223200, 1000, 'img44.jpg', 'C02', 1, 200000, 400),

('MK05', 'Nghệ Thuật Dụng Binh Trong Marketing', 'Jack Trout, Al Ries', 'NXB Lao Động Xã Hội', 2019,
'Cuốn sách kinh điển về chiến lược marketing, so sánh các chiến thuật tiếp thị với chiến tranh để giúp doanh nghiệp cạnh tranh hiệu quả.',
152150, 1000, 'img45.jpg', 'C03', 1, 200000, 400),

('MK06', 'Ứng Dụng Agile Marketing', 'Andrea Fryrear', 'NXB Công Thương', 2025,
'Giới thiệu phương pháp Agile Marketing giúp doanh nghiệp thích ứng nhanh với thị trường và tối ưu hiệu quả chiến dịch.',
156000, 6000, 'img46.jpg', 'C03', 1, 200000, 400),

('MK07', 'Marketing Tinh Gọn', 'Allan Dib', 'NXB Công Thương', 2025,
'Cuốn sách giúp doanh nghiệp xây dựng chiến lược marketing đơn giản nhưng hiệu quả cao, tập trung vào giá trị cốt lõi.',
194650, 1000, 'img47.jpg', 'C03', 1, 200000, 400),

('MK08', 'Marketing Phải Bán Được Hàng', 'Donald Miller, J. J. Peterson', 'NXB Lao Động', 2020,
'Cuốn sách cung cấp giải pháp xây dựng chiến lược marketing hiệu quả, giúp doanh nghiệp thu hút khách hàng và tăng doanh số.',
111300, 1000, 'img48.jpg', 'C03', 1, 200000, 400),

('LT05', 'Lập Trình AI Cho Người Mới Bắt Đầu', 'TS. Lương Anh Vũ, Tạ Văn Dũng', 'NXB Thanh Niên', 2025,
'Cuốn sách giúp người mới tiếp cận AI nhanh chóng, nắm vững kiến thức nền tảng và ứng dụng vào thực tế.',
200000, 1000, 'img49.jpg', 'C04', 1, 200000, 400),

('LT06', 'Con Gái Học Cách Lập Trình', 'Reshma Saujani', 'NXB Trẻ', 2023,
'Truyền cảm hứng cho các bạn nữ tham gia lĩnh vực lập trình và công nghệ thông tin với những câu chuyện và kinh nghiệm thực tế.',
72000, 1000, 'img50.jpg', 'C04', 1, 200000, 400),

('LT07', 'Ước Vọng Về Quốc Gia Lập Trình', 'Nguyễn Thanh Tùng', 'NXB Trẻ', 2023,
'Chia sẻ hành trình từ sinh viên đến doanh nhân công nghệ, truyền cảm hứng khởi nghiệp và phát triển bản thân.',
64000, 1000, 'img51.jpg', 'C04', 1, 200000, 400),

('LT08', 'Em Học Lập Trình Coding', 'Randy Lynn', 'NXB Dân Trí', 2022,
'Giúp trẻ em làm quen với lập trình thông qua các hoạt động tương tác đơn giản và thú vị.',
103200, 1000, 'img52.jpg', 'C04', 1, 200000, 400),

('TT05', 'Cuốc Xe Tuổi Trẻ - 12 Truyện Tranh Của Các Họa Sĩ Việt Nam', 'Nhiều Tác Giả', 'NXB Thế Giới', 2022,
'Bộ truyện tranh gồm 12 câu chuyện sáng tạo của các họa sĩ trẻ Việt Nam, phản ánh nhiều góc nhìn về cuộc sống và xã hội.',
99999, 1000, 'img53.jpg', 'C05', 1, 200000, 400),

('TT06', 'Bạn Bè Muôn Năm! Tuyển Tập Truyện Tranh Cực Ngắn Về Tình Bạn', 'Liz Climo', 'NXB Kim Đồng', 2023,
'Tập truyện tranh ngắn dễ thương về tình bạn, mang lại cảm xúc ấm áp và tiếng cười nhẹ nhàng.',
118150, 1000, 'img54.jpg', 'C05', 1, 200000, 400),

('TT07', 'Truyện Tranh Tư Duy Cho Bé', 'Hải Minh', 'NXB Phụ Nữ Việt Nam', 2021,
'Những câu chuyện ngụ ngôn kết hợp hình ảnh giúp trẻ phát triển tư duy và khả năng tưởng tượng.',
78400, 1000, 'img55.jpg', 'C05', 1, 200000, 400),

('TT08', 'Kho Tàng Truyện Cổ Việt Nam - Truyện Tranh Song Ngữ', 'Văn Minh', 'NXB Trẻ', 2020,
'Bộ truyện cổ tích Việt Nam với hình ảnh sinh động, giúp trẻ học và yêu văn hóa dân gian.',
237600, 1000, 'img56.jpg', 'C05', 1, 200000, 400),

('CN05', 'Cuộc Chiến Tranh Công Nghệ Cao Ở Hàng Rào Điện Tử McNamara 1966-1972', 'PGS.TS Hoàng Chí Hiếu', 'NXB Tổng hợp TP.HCM', 2022,
'Nghiên cứu về chiến tranh công nghệ cao tại Việt Nam và sự đối đầu giữa trí tuệ con người với máy móc hiện đại.',
79200, 1000, 'img57.jpg', 'C06', 1, 200000, 400),

('CN06', 'Khoa Học Diệu Kì - Công Nghệ Y Học', 'Cath Senker', 'NXB Trẻ', 2022,
'Giới thiệu các công nghệ y học hiện đại giúp chăm sóc sức khỏe và phòng bệnh hiệu quả.',
31500, 1000, 'img58.jpg', 'C06', 1, 200000, 400),

('CN07', 'Tiếp Thị 5.0 - Công Nghệ Vị Nhân Sinh', 'Philip Kotler, Hermawan Kartajaya, Iwan Setiawan', 'NXB Trẻ', 2021,
'Giải thích cách ứng dụng công nghệ trong marketing để đáp ứng nhu cầu khách hàng hiện đại.',
96000, 1000, 'img59.jpg', 'C06', 1, 200000, 400),

('CN08', 'Những Gã Khổng Lồ Công Nghệ Trung Quốc', 'Rebecca A. Fannin', 'NXB Thế Giới', 2021,
'Phân tích sự phát triển mạnh mẽ của ngành công nghệ Trung Quốc và tác động toàn cầu.',
159200, 1000, 'img60.jpg', 'C06', 1, 200000, 400),

('DS05', 'Bây Giờ Và Ở Đây - Thiền Chánh Niệm Trong Đời Sống Hàng Ngày', 'Jon Kabat-Zinn', 'NXB Tổng hợp TP.HCM', 2022,
'Cuốn sách về thiền chánh niệm giúp con người sống trọn vẹn trong hiện tại.',
148000, 1000, 'img61.jpg', 'C07', 1, 200000, 400),

('DS06', 'Seneca - Những Bức Thư Đạo Đức - Chủ Nghĩa Khắc Kỷ', 'Lucius Annaeus Seneca', 'NXB Thế Giới', 2022,
'Giới thiệu triết lý Khắc Kỷ giúp con người vững vàng trước khó khăn và áp lực.',
143100, 1000, 'img62.jpg', 'C07', 1, 200000, 400),

('DS07', 'Đời Sống Bí Ẩn Của Khoa Học', 'Jeremy J. Baumberg', 'NXB Tri Thức', 2022,
'Phân tích hệ sinh thái khoa học hiện đại và những động lực thúc đẩy nghiên cứu.',
172000, 1000, 'img63.jpg', 'C07', 1, 200000, 400),

('DS08', 'Đời Sống Vỉa Hè Sài Gòn', 'Annette M. Kim', 'NXB Dân Trí', 2022,
'Phân tích xã hội và văn hóa đô thị qua hình ảnh vỉa hè Sài Gòn.',
135200, 1000, 'img64.jpg', 'C07', 1, 200000, 400),

('LS05', 'Nhân Chứng Và Lịch Sử', 'Hồ Sơn Đài', 'NXB Quân Đội Nhân Dân', 2025,
'Ghi chép về các nhân chứng và sự kiện lịch sử quan trọng.',
156800, 1000, 'img65.jpg', 'C08', 1, 200000, 400),

('LS06', 'Hy Vọng - Hồi Ký Của Giáo Hoàng Phanxicô', 'Đức Giáo Hoàng Phanxicô', 'NXB Thế Giới', 2025,
'Cuốn hồi ký đầu tiên của một giáo hoàng, kể lại hành trình cuộc đời và đức tin.',
239000, 1000, 'img66.jpg', 'C08', 1, 200000, 400),

('LS07', 'Những Nẻo Đường Ẩm Thực', 'Benjamin A. Wurgaft, Merry I. White', 'NXB Văn Học', 2025,
'Lịch sử ẩm thực dưới góc nhìn văn hóa và xã hội qua nhiều thời kỳ.',
171000, 1000, 'img67.jpg', 'C08', 1, 200000, 400),

('LS08', 'Lịch Sử Các Đội Quân Tiền Thân QĐNDVN', 'Bộ Tổng tham mưu QĐNDVN', 'NXB Quân Đội Nhân Dân', 2025,
'Nghiên cứu quá trình hình thành các lực lượng tiền thân của Quân đội nhân dân Việt Nam.',
177600, 1000, 'img68.jpg', 'C08', 1, 200000, 400),

('GD05', 'Bàn Về Giáo Dục', 'Bertrand Russell', 'NXB Hội Nhà Văn', 2025,
'Quan điểm giáo dục tiến bộ, đề cao tự do và phát triển tư duy cho trẻ.',
170000, 1000, 'img69.jpg', 'C09', 1, 200000, 400),

('GD06', '1001 Câu Chuyện Giáo Dục Trẻ Em', 'Vũ Anh', 'NXB Tri Thức', 2025,
'Kho tàng truyện ngắn giúp trẻ phát triển đạo đức và kỹ năng sống.',
848000, 1000, 'img70.jpg', 'C09', 1, 200000, 400),

('GD07', 'Kỷ Luật Mềm Trong Gia Đình', 'Nguyễn Thị Thu', 'NXB Lao Động', 2021,
'Hướng dẫn giáo dục trẻ 0-10 tuổi thông qua phát triển năng lực và thói quen.',
151200, 1000, 'img71.jpg', 'C09', 1, 200000, 400),

('GD08', 'Giáo Dục Song Ngữ', 'Colin Baker, Wayne E. Wright', 'NXB Dân Trí', 2024,
'Phân tích các vấn đề về giáo dục song ngữ và đa ngữ trong giảng dạy.',
303200, 1000, 'img72.jpg', 'C09', 1, 200000, 400),

('GD09', 'Khoa Học Và Nghệ Thuật Ca Hát', 'Nguyễn Bích Thủy', 'NXB Dân Trí', 2024,
'Giới thiệu các kỹ thuật thanh nhạc từ cơ bản đến nâng cao.',
303200, 1000, 'img73.jpg', 'C09', 1, 200000, 400),

('GD10', 'Tự Vị Tiếng Nói Miền Nam', 'Vương Hồng Sển', 'NXB Tri Thức', 2017,
'Từ điển độc đáo về tiếng nói Nam Bộ, phản ánh văn hóa và ngôn ngữ vùng miền.',
848000, 1000, 'img74.jpg', 'C09', 1, 200000, 400),

('GD18', 'Giải Mã Thần Số Học - Các Kỹ Thuật Ứng Dụng Thần Số Học Vào Khám Phá Bản Thân Và Dự Đoán Vận Mệnh ', '
Sasha Fenton ', 'NXB Tri Thức', 2017,
'Mỗi con số đều ẩn chứa một tầng ý nghĩa, phản chiếu cá tính, hành trình và số phận riêng biệt của mỗi con người.

Từ hàng thiên niên kỷ trước, con người đã sử dụng thần số học để khám phá vận mệnh - không chỉ để hiểu chính mình mà còn soi chiếu những bước ngoặt và sự kiện quan trọng trong đời.

Trong Giải mã Thần số học - Các kỹ thuật ứng dụng thần số học vào khám phá bản thân và dự đoán vận mệnh, thuộc In Focus Series, chuyên gia huyền học danh tiếng Sasha Fenton sẽ dẫn dắt bạn bước vào thế giới nhiệm màu của những con số - nơi tri thức và trực giác giao hòa.

Từ kiến thức nền tảng và toàn diện về thần số học như lược sử hình thành, các con số chủ đạo, cùng nguyên tắc giải mã cơ bản, cho đến việc phân tích ý nghĩa sâu sắc của các con số trong tên và ngày sinh (con số Vận mệnh, con số Cá nhân, con số Trái tim, con số Đường đời, con số Cuộc đời,…), cuốn sách còn mở rộng sang những phương pháp tiên đoán vận mệnh theo năm, tháng, ngày, thậm chí từng giờ.

Đây là cẩm nang hướng dẫn chi tiết và gần gũi, giúp bạn không chỉ đọc vị những con số, mà còn kết nối với dòng chảy năng lượng vũ trụ, để sống trọn vẹn hơn mỗi ngày.. ', 848000, 1000, 'img75.jpg', 'C09', 1, 200000, 400),

('GD11', 'Bí Mật Vũ Trụ ', '
Jake Register ', 'NXB Tri Thức', 2017,
'Trong suốt hàng nghìn năm, chiêm tinh học được xem như chiếc “bản đồ năng lượng” dẫn lối con người tìm về chính mình giữa vũ trụ bao la. Bí mật Vũ trụ của Jake Register là cuốn sách giúp bạn đọc giải mã những tầng sâu trong bản đồ sao, nơi Mặt Trời, Mặt Trăng và Cung Mọc tiết lộ bản chất, cảm xúc và cách ta kết nối với thế giới.

Khác với những cuốn sách chiêm tinh thông thường, “Bí Mật Vũ Trụ” không chỉ nói về cung hoàng đạo mà còn nói về con người, bản năng, và cách chúng ta giao thoa năng lượng với nhau trong đời sống thực. ', 848000, 1000, 'img76.jpg', 'C09',1,200000,400),
('GD12', 'Giải Mã Bàn Tay - Nhìn Tay Thấu Hiểu Nhân Tâm ', '
Thiệu Vệ Hoa ', 'NXB Tri Thức', 2017,
'Thuật nhìn tướng tay là sự tổng kết kinh nghiệm sống của người xưa trong suốt hàng nghìn năm, phù hợp với tâm lý và nguyện vọng của con người. Một chuyên gia quản lý nguồn nhân lực người Nhật Bản đã từng nói rằng: “Rất nhiều nguyên lý trong quản lý nguồn nhân lực thời hiện đại hầu như đều có thể tìm được căn cứ từ trong lịch sử Trung Quốc”.

Chính vì lý do trên, chúng tôi đã quyết định giới thiệu cuốn sách này nhằm giúp bạn đọc tham khảo, khảo cứu cách “biết người hiểu người”của người xưa. ', 848000, 1000, 'img77.jpg', 'C09',1,200000,400),

('GD13', 'Khảo Cổ Học Đồng Bằng Sông Mê Kông - Tập IV :Tả Ngạn Sông Hậu Đến Lưu Vực Sông Đồng Nai ', '
Louis Malleret ', 'NXB Tri Thức', 2017,
'Nghiên cứu khảo cổ học đồng bằng sông Mê Kông sẽ chưa hoàn chỉnh nếu chúng ta chưa hiểu rõ vùng tả ngạn sông Hậu đến lưu vực sông Đồng Nai (Cisbassac). Mặt khác, đây cũng là địa bàn nơi chúng tôi khởi sự các nghiên cứu, cho đến khi sự cấp thiết buộc chúng tôi phải chuyển hướng sang vùng hữu ngạn sông Hậu đến Cà Mau (Transbassạc) và đô thị Óc Eo, Chúng tôi cũng đã bổ sung vào địa bàn này vùng đồng bằng nhỏ hẹp và lưu vực sông Đồng Nai, sao cho phạm vị thám sát khảo cổ - tiếc là vẫn còn dang dở -bao trùm toàn bộ các tỉnh phía Nam Việt Nam. Một lý do khác thôi thúc chúng tôi hoàn thiện nghiên cứu này chính là vai trò to lớn của các cửa sông Mê Kông trong tiến trình thâm nhập của Phật giáo. Nhiều tượng Phật bằng sa thạch có xuất xứ từ các vùng của sông. Một số khác bằng gỗ khá lâu đời được tìm thấy cũng chủ yếu trong vùng Đồng Tháp Mười và qua đó hé lộ một khía cạnh mới trong nghệ thuật tạc tượng vùng này.

Với khoảng 300 di tích được mô tả, phần lớn là di tích mới, Nam Bộ không còn là "vùng đất vô danh" nữa. Nhưng nếu cho rằng tập sách này mang tính toàn diện, tức là nó giải quyết toàn bộ vấn đề, thì có phần võ đoán. Trước hết, chúng tôi không khảo sát khắp các di tích. Tiếp theo, dù hết sức cẩn trọng trong quá trình thăm dò, chúng tôi có thể đã bỏ sót những chỉ dẫn quý báu, vì không phải lúc nào cũng gặp được điều kiện thuận lợi. Do đó, các nhà nghiên cứu sau này vẫn còn cơ hội để khám phá. Suy cho cùng, chúng tôi kỳ vọng vào họ. Vì chúng tôi đã mở đường cho những cuộc thám sát mới mà chúng tôi tin rằng sẽ đơm hoa kết trái ở một vùng đồng bằng mà từ xưa vẫn luôn là mảnh đất màu mỡ cho sự giao thoa của các nền văn minh. ', 848000, 1000, 'img78.jpg', 'C09',1,200000,400),
('GD14', 'Kiến Tạo Thành Phố Hồ Chí Minh Thành Siêu Đô Thị Năng Động - Thông Minh - Giàu Bản Sắc ', '
TS. Nguyễn Thành Phong ', 'NXB Tri Thức', 2017,
'TP. Hồ Chí Minh đang đứng trước một cơ hội có một không hai để tái cấu trúc thành một siêu đô thị tích hợp - sáng tạo - xanh và có bản sắc.

Theo TS Nguyễn Thành Phong, trong không gian mới này, các chức năng kinh tế - xã hội được tái tổ chức theo mô hình liên kết động, đa trung tâm và bổ sung lẫn nhau. Cụ thể: khu vực TP.HCM (cũ) tiếp tục giữ vai trò trung tâm tài chính, văn hóa, giáo dục chất lượng cao và đầu mối điều phối.

Khu vực phía Nam tỉnh Bình Dương phát huy thế mạnh công nghiệp, logistics và đổi mới quy trình sản xuất. Còn Bà Rịa - Vũng Tàu trở thành trung tâm cảng biển quốc tế, du lịch sinh thái và năng lượng tái tạo của toàn vùng.

“Đây không chỉ là thay đổi địa giới, mà là cơ hội lịch sử để chuyển từ một mô hình đô thị phân mảnh, cứng nhắc sang một thực tế thích hợp, năng động, thông tin, cạnh tranh toàn cầu và có khả năng dẫn dắt vùng”, tác giả viết.

Công trình "Kiến tạo TP.HCM thành siêu đô thị năng động - thông minh - giàu bản sắc" được tác giả triển khai theo hướng tiếp cận liên ngành kinh tế - xã hội - văn hóa - công nghệ - thể chế. Đặc biệt, tác giả còn có sự đối chiếu, so sánh với các siêu đô thị quốc tế trên thế giới và trong khu vực như Singapore, London, Paris, Seoul, Thượng Hải…, từ đó rút ra những bài học, kinh nghiệm quý giá cho TP.HCM trên hành trình trở thành siêu đô thị quốc tế. ', 848000, 1000, 'img79.jpg', 'C09',1,200000,400),
('GD15', 'Vọng Âm Sắc Màu ', '
Đỗ Phấn ', 'NXB Tri Thức', 2017,
'Những lát cắt về nền hội họa Việt Nam hiện đại

Không chỉ dành cho giới mỹ thuật, cuốn sách này dành cho bất kỳ ai từng dừng lại thật lâu trước một bức tranh, để suy tư và lắng nghe vọng âm sắc màu.Trong tạp ghi này, họa sĩ - nhà văn Đỗ Phấn phác nên một góc nhìn nhiều tầng bậc về hội họa Việt Nam hiện đại dưới con mắt nhà nghề, tư duy thẩm mỹ nhất quá và kinh nghiệm trực tiếp từ người trong cuộc. Mỗi bài tản văn là một lát cắt tinh xảo, dù khi đó tác giả lặng lẽ đối thoại với quá khứ "Mỹ thuật Đông Dương" hay thẳng thừng truy vấn thực tại hỗn độn và thị trường mỹ thuật đương đại.

Đỗ Phấn không ngại va chạm với quan niệm dễ dãi về nghệ thuật, cũng không xuề xòa trước sự lặp lại vô thức trong sáng tạo. Ông cũng không chủ ý đưa ra một định nghĩa nghệ thuật theo lối trường quy - mà gợi mở những vùng biên giữa tác phẩm và hàng hóa, giữa thẩm mỹ và giải trí, giữa ký ức và hiện tại, giữa người vẽ và đời vẽ..

Vọng âm của những lớp tranh, lớp người, lớp cảm xúc ấy kiến tạo một không gian suy niệm sinh động, tự do, vừa khúc chiết vừa có độ vỡ vụn thời gian. Một cuốn sách dành cho những ai từng lắng nghe vọng âm từ những bức tranh. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD16', 'Văn Hóa Qua Kiến Trúc Nhà Ở ', '
Amos Rapoport ', 'NXB Tri Thức', 2017,
'Tại sao kiến trúc nhà ở lại phản ánh một nền văn hóa?

Khi nhắc đến kiến trúc, chúng ta thường nghĩ đến các công trình mang tính biểu tượng: nhà thờ, cung điện, bảo tàng… Nhưng phần lớn đời sống con người diễn ra trong những ngôi nhà ở - không lộng lẫy nhưng lại là nơi thể hiện rõ nhất những giá trị, niềm tin và lựa chọn văn hóa của mỗi cộng đồng.

Trong cuốn sách kinh điển này, Amos Rapoport - một trong những người tiên phong nghiên cứu mối quan hệ giữa văn hóa và kiến trúc - đưa ra một hướng tiếp cận mới mẻ: nhìn kiến trúc không chỉ như một ngành kỹ thuật, mà là một dạng biểu hiện văn hóa sâu sắc.

Cuốn sách “Văn Hóa Qua Kiến Trúc Nhà Ở” có gì đặc biệt?
Phân tích cách con người từ khắp nơi trên thế giới tạo dựng nên ngôi nhà của mình, không chỉ dựa vào khí hậu hay vật liệu, mà còn dựa vào truyền thống, tín ngưỡng, cách sống và cấu trúc xã hội.

Trình bày rõ ràng, dễ hiểu, dù là một công trình học thuật liên ngành - giao thoa giữa kiến trúc, địa lý văn hóa, nhân học, lịch sử, quy hoạch đô thị…

Từ lều cỏ của người du mục, nhà sàn ở Đông Nam Á, đến các khu định cư đô thị truyền thống - mỗi kiểu nhà đều là một tấm gương soi chiếu cách một nền văn hóa hình dung về không gian sống lý tưởng. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD17', 'Đất Nước Gấm Hoa - Atlas Việt Nam - Ấn Bản Lưu Dấu 63 Tỉnh Thành ', '
Võ Thị Mai Chi, Hồ Quốc Cường ', 'NXB Tri Thức', 2017,
'Việt Nam chúng ta kết tinh của lịch sử hào hùng, thiên nhiên tươi đẹp cùng sức sáng tạo vô biến của con người và giờ đây chúng ta đang có ĐẤT NƯỚC GẤM HOA

Việt Nam là một đất nước xinh đẹp với nhiều vùng văn hóa khác nhau. Với mong muốn mang đến nhũng kiến thức về địa lí, lịch sử, văn hóa và con người một cách dễ nhớ và gần gũi, “Đất nước gấm hoa” giúp bạn đọc nhiều độ tuổi có cái nhìn thật cụ thể và sống động về 63 tỉnh thành trên dải đất hình chữ S của chúng ta.

LỜI GIỚI THIỆU

Quê nhà mình ở đâu trên bản đồ Việt Nam?

Nơi mình sinh ra và lớn lên có điều gì đặc biệt?

Bạn biết không, đất nước của chúng mình đẹp lắm. Từ những dòng thác tung bọt trắng xóa vùng Tây Bắc đến dòng Cửu Long chở nặng phù sa miền Tây Nam Bộ, từ núi rừng bao la nơi sinh sống của nhiều loài động vật quí hiếm đến vùng hải đảo nơi có những giàn khoan tung bay lá cờ đỏ sao vàng, từ những miền đất cổ kính với bề dày lịch sử đến các thành phố trẻ trung tràn đầy sức sống… tất cả hội tụ trên dải đất hình chữ S tươi đẹp, như một di sản tuyệt vời qua hàng ngàn năm dựng nước và giữ nước mà giờ đây cha ông trao lại cho chúng mình. Hành trình đi dọc theo đất nước từ Bắc vào Nam, lên rừng xuống biển cũng là hành trình khám phá nền văn hóa đặc sắc và đa dạng của cộng đồng 54 dân tộc anh em.

Dù chúng mình đang ở nơi đâu trên dải đất hình chữ S, thì bạn và tôi luôn hiểu rằng con đường mình đang đi, món ăn mình đang thưởng thức, công trình mình đang chiêm ngưỡng đều mang theo dấu ấn của lịch sử, của tinh hoa văn hóa đúc kết từ bao đời. 63 tỉnh thành là 63 vùng đất với vị trí địa lí khác nhau, địa hình, dân tộc, bản sắc văn hóa vì thế cũng chứa đựng những dấu ấn riêng. Tất cả tạo nên những hoa văn đặc sắc, vừa khác biệt, vừa hòa quyện vào nhau, tạo nên vẻ đẹp lung linh của đất nước gấm hoa.

Với mong muốn mang đến một quyển sách chứa đựng kiến thức về địa lí, lịch sử, văn hóa, con người thật gần gũi đến bạn đọc nhiều độ tuổi, đặc biệt mong muốn các bạn học sinh có cái nhìn cụ thể và sống động về mỗi vùng đất, mỗi tỉnh thành trên bản đồ Việt Nam, ê kíp thực hiện đã dành tất cả tâm huyết cho quyển Atlas này. Trong từng dòng thông tin, từng hình vẽ, từng mảng màu đều thấm đượm tình yêu đất nước và niềm tự hào là người con của quê hương xứ sở. ĐẤT NƯỚC GẤM HOA - ATLAS VIỆT NAM, cuộc hành trình khám phá 63 bản đồ tỉnh thành đã ra đời với thật nhiều cảm xúc như thế.

Nhóm tác giả rất mong nhận được sự đóng góp ý kiến từ bạn đọc để nội dung quyển sách được hoàn thiện hơn nữa.

Còn bây giờ, chuyến tàu xuyên suốt dải đất hình chữ S sắp sửa khởi hành. Mời bạn sẵn sàng cho kì du lịch thú vị nhất để khám phá đất nước Việt Nam tươi đẹp. Bắt đầu nào! ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD19', 'Con Người Và Nghệ Thuật Chăm ', '
Jeanne Leuba ', 'NXB Tri Thức', 2007,
'Một cánh cửa mở vào nền văn minh Champa rực rỡ và huyền bí.

Dù diện tích nhỏ bé, vương quốc Champa từng vươn ra biển lớn, giao thương rộng khắp với Ấn Độ, Java - tạo dựng nên một xã hội thịnh vượng qua thương mại, thậm chí cả hải tặc. Nhưng cũng đầy thăng trầm bởi chiến tranh và chia rẽ nội bộ.

Cuốn sách là hành trình khám phá di sản văn hoá Chăm: những đền tháp cổ kính, bia ký thiêng liêng, tôn giáo độc đáo và nỗ lực bảo tồn kéo dài suốt hơn một thế kỷ - từ thời Aymonier, Parmentier đến các nghiên cứu đương đại.

Với chiều sâu học thuật cùng hình ảnh minh hoạ sống động, đây là tài liệu không thể thiếu cho người yêu văn hoá, lịch sử Đông Dương và di sản Champa. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400);

USE bookdb;
INSERT INTO books (bookId, title , author, publisher, publicationYear, description, price, quantity, picture, categoryId, isActive, original_price, soldQuantity ) VALUES
('GD20', 'Hát Ru Việt Nam Tuyển Chọn ', '
Minh Anh ', 'NXB Tri Thức', 2007,
'Những lời hát ru đầy ý nghĩa trong giáo dục đạo đức, nhân cách, với những hình ảnh bình dị và hết sức gần gũi với tuổi thơ, thể hiện tình cảm nồng nàn, sự yêu thương, nâng niu của bà, của mẹ, của chị, bồi đắp tình yêu quê hương, gia đình và đời sống tâm hồn trẻ thơ. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD21', 'Kiêng Và Cấm Kỵ Của Người Việt Xưa Và Nay ', '
Phạm Minh Thảo ', 'NXB Tri Thức', 2007,
'Quan niệm Kiêng và Cấm kỵ của người Việt chắc hẳn hình thành từ thời xa xưa, khi người Việt trải qua bao cuộc vật lộn sinh tồn, đã đúc rút được nhiều kinh nghiệm và cả những may rủi mà họ không sao giải thích được. Ẩn hiện qua tín ngưỡng, tâm lý, hiện hình thành những quy định trong phong tục, tập quán và tồn tại với một sức sống dai dẳng đến kỳ lạ, Kiêng và Cấm kỵ thể hiện một biểu trưng của văn hóa tộc người, là một tất yếu mang đậm dấu ấn của một dân tộc sống bằng nghề nông, phải trải qua nhiều cuộc chinh chiến chống ngoại xâm và chịu ảnh hưởng không nhỏ của nước láng giềng Trung Quốc.

Quan niệm Kiêng và Cấm kỵ của người Việt hiện hữu, nhiều khi là vô thức và có thể bắt gặp ở nhiều nơi, phổ biến trong các lễ nghi ở đền, đình, miếu, phủ, trong những ngày Tết thường niên, những ngày lễ hội và nghi lễ vòng đời người.

Quan niệm này trải qua bao thời gian vẫn được cộng đồng tuân thủ một cách tự giác với niềm kính tín và hy vọng vào sự may mắn, tránh mọi sự rủi ro. Cuộc sống sôi động hiện nay với khoa học và kỹ thuật phát triển, có chăng chỉ đào thải một số kiêng kỵ trong cách hành xử ở tầng lớp trẻ nhưng đa phần, sự kiêng và cấm kỵ này cơ bản vẫn tồn tại, được chấp nhận với quan niệm "Có kiêng có lành".

Chính quan niệm này khiến nhiều người có trình độ văn hóa cao, hiểu biết song vẫn vui lòng và tự nguyện tuân thủ mọi quy định về kiêng kỵ đã được truyền thống bảo lưu. Đứng ở góc độ này, nhiều điều kiêng và cấm kỵ là có thể hiểu và chấp nhận được. Thực tế các địa danh trong sách đã có những thay đổi so với hiện nay, tuy nhiều điều kiêng và cấm kỵ đã trở nên không thích hợp nhưng sự tồn tại hữu hình và nhiều khi là vô thức của nó vẫn đáng để suy ngẫm về một trong những đặc điểm văn hóa của tộc người Việt trên con đường phát triển. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD32', 'Các Mô Thức Văn Hóa ', '
Ruth Benedict ', 'NXB Tri Thức', 2007,
'Giới thiệu sách Các Mô Thức Văn Hóa
Trong giới nhân học Mỹ, ngay từ đầu, đã xuất hiện học giả nữ nổi tiếng là Margaret Mead (1901 - 1978), tác giả của Tuổi trưởng thành ở Samoa (Coming of Age in Samoa, 1928) và Ruth Benedict (1887 - 1948), tác giả của Các mô thức văn hóa (Petterns of Culture, 1934). Họ đều là học trò của Franz Boas, ông tổ của nền nhân học Mỹ và là những nhà văn hóa Mỹ tiêu biểu nhất của thế kỷ XX.

Ruth Benedict nhận học vị tiến sĩ và trở thành giáo sư nhân học tại Đại học Columbia, đồng thời nắm giữ vị trí chủ tịch Hội nhân học Mỹ. Các công trình nghiên cứu của bà góp phần xây dựng nền móng cho ngành nhân học văn hóa, đặc biệt là trường phái Văn hóa và Nhân cách. Và, mặc dù các tác phẩm của bà về mô thức văn hóa chỉ dừng ở cấp độ cá nhân, hoặc rộng hơn, tộc người, nhưng Benedict đã đưa nhân học văn hóa tới các lĩnh vực chuyên sâu hơn của nhân học như tâm lý học, phân tâm học, thần kinh học.

Bạn đọc Việt Nam mới đây đã biết đến bà qua tác phẩm Hoa cúc và gươm (The Chrysanthemum and the Sword, Nxb Hồng Đức, 2014), nghiên cứu tính cách người Nhật dựa trên mô hình lý thuyết được bà xây dựng trong tác phẩm Các mô thức văn hóa. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),

('GD23', 'Bí Quyết Hội Họa - Phác Họa Tĩnh Vật ', '
Từ Hảo ', 'NXB Tri Thức', 2007,
'Cơ bản - Thực tế - Toàn diện - Dễ Hiểu - Dễ đọc
Bạn đam mê hội họa và muốn bắt đầu học vẽ?
Bạn gặp khó khăn trong việc tìm ra sách học phù hợp?
Bạn bối rối không biết nên bắt đầu từ đâu?
Bộ sách Bí Quyết Hội Họa sẽ là người bạn đồng hành tuyệt vời, giúp bạn có khởi đầu thuận lợi trên con đường học vẽ của mình. Bộ sách được thiết kế với từng cấp độ từ cơ bản đến nâng cao, mang đến cho bạn những kiến thức nền tảng cũng như định hướng để tiếp tục đào sâu đam mê.

PHÁC HỌA TĨNH VẬT trong bộ sách này vừa giúp người học luyện tập về các vật thể có thật, vừa là bước đệm để nâng cao khả năng quan sát bố cục, rèn luyện kỹ thuật vẽ và đào sâu các kiến thức hội họa, nhằm chuẩn bị cho việc vẽ người sau này. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD24', 'Bản Ngã Người Việt ', '
Nguyễn Văn Hầu ', 'NXB Tri Thức', 2007,
'Qua việc tìm hiểu bản ngã của người Việt, Nguyễn Văn Hầu đã chỉ ra được những ưu điểm của dân tộc Việt; và đó chính là những cột trụ vững chãi để nước Việt có thể tồn tại và đánh bại mọi cuộc xâm lược của những kẻ tham lam, tàn bạo, âm mưu biến dân Việt thành nô lệ, xóa bỏ nước Việt trên bản đồ; đứng vững trước bão giông của thời cuộc, chọn lấy con đường đúng đắn để phát triển đi lên.

Có ưu ắt sẽ có khuyết. Biết khuyết điểm cũng giúp chúng ta hạn chế những sai lầm. Biết cũng sẽ giúp ta vững tin tiến bước và không ngừng trau dồi và hoàn thiện qua thời gian.

Tác phẩm ra mắt độc giả lần đầu vào năm 1961 và vẫn còn nguyên giá trị cho đến ngày nay. Tác phẩm sẽ truyền cho độc giả những cảm hứng tích cực, khuyến khích mọi người tu dưỡng và đóng góp cho xã hội, dân tộc và Tổ quốc. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD25', 'Người Việt Nam Với Đạo Giáo ', '
Nguyễn Duy Hinh ', 'NXB Tri Thức', 2007,
'"Người Việt Nam với Đạo giáo" của tác giả Nguyễn Duy Hinh là một công trình nghiên cứu đặc biệt về dấu ấn Đạo giáo trong văn hóa Việt Nam. Ban đầu với mong muốn viết về "Đạo giáo Việt Nam", nhưng trong quá trình tìm hiểu, tác giả nhận thấy rằng nên gọi tên tác phẩm là "Người Việt Nam với Đạo giáo", nhằm truyền tải chính xác hơn mối quan hệ đặc biệt giữa Đạo giáo và văn hóa Việt.

Cuốn sách gồm hai chương chính:

Chương I bàn về nguồn gốc và bản chất của Đạo giáo tại Trung Quốc;
Chương II khám phá hành trình truyền bá và sự phát triển của Đạo giáo tại Việt Nam, từ khi du nhập đến thời Lý, Trần, Lê và Nguyễn.
Tác phẩm cũng phân tích cách Đạo giáo hoà quyện với Phật giáo, Khổng giáo để tạo thành một hình thái "tam giáo đồng nguyên" đặc trưng của Việt Nam, dẫn đến sự mai một của Đạo giáo như một tôn giáo độc lập. Mặc dù không có tổ chức Đạo giáo chính thức tại Việt Nam ngày nay, tác giả chỉ ra rằng dấu ấn của Đạo giáo vẫn hiện diện trong văn hóa dân gian và tín ngưỡng của người Việt.

Với lối viết tinh tế và am hiểu sâu sắc, Nguyễn Duy Hinh đã khơi mở một mảng kiến thức phong phú về Đạo giáo - một khía cạnh ít được nghiên cứu sâu ở Việt Nam. Tác phẩm không chỉ là viên gạch đầu tiên giúp độc giả hiểu về Đạo giáo mà còn là một lời nhắn gửi để các thế hệ sau tiếp tục khám phá, làm phong phú thêm nghiên cứu về tôn giáo và bản sắc dân tộc. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD26', 'Trống Đồng Đông Sơn Ở Việt Nam ', '
Phạm Huy Thông ', 'NXB Tri Thức', 2007,
'Cuốn sách Trống đồng Đông Sơn ở Việt Nam (Dong Son Drums in Viet Nam) là tập hợp đầy đủ nhất những phát hiện về trống đồng Đông Sơn ở Việt Nam cho đến trước năm 1987 với những nguồn tư liệu được chọn lọc, xác minh đáng tin cậy, sắp xếp có hệ thống, đặc biệt là các hình ảnh, bản vẽ minh hoạ đẹp, chính xác; các mô tả về hình dáng, hoa văn, kích thước chân thực, rõ ràng. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD27', 'Vị Đắng Trong Ẩm Thực Ý ', '
Massimo Montanari ', 'NXB Tri Thức', 2007,
'Cơ quan vị giác có hai bộ phận chính là lưỡi và não. Lưỡi nếm hương vị, não đánh giá chúng. Cơ chế này không chỉ mang tính sinh học mà trên hết còn thể hiện một nét văn hóa đặc sắc: tạo nên từ thói quen, sự học hỏi và những phán đoán. Vì vậy, nếu chúng ta tự hỏi tại sao cơ quan vị giác nhạy cảm của người Ý lại bị thu hút bởi vị đắng đến vậy, thì câu trả lời sẽ không được giải thích bằng di truyền mà phải bằng lịch sử. Vị đắng là một đặc điểm, không độc quyền nhưng cực kỳ độc đáo trong văn hóa Ý. Bắt đầu ngày mới bằng vị đắng của cà phê và kết thúc một ngày bằng vị đắng của rượu tiêu vị, “đắng” chính là hương vị được chào đón nhất trong nền văn hóa ẩm thực của đất nước này.

Bằng cách đào sâu vào các nguồn văn học và chuyên luận về thực vật học, nông nghiệp, ẩm thực, nhà sử học ẩm thực vĩ đại Massimo Montanari đã cho chúng ta một lời giải đáp thú vị về niềm đam mê “cay đắng” của người Ý trong “Amaro un gusto italiano”. Không chỉ đơn thuần bàn luận đến một hương vị hay một số loại thực phẩm nhất định, cuốn sách này nói về mối quan hệ sâu sắc giữa những loại thực phẩm mang vị đắng với nền văn hóa Ý. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD28', 'Mật Ngữ Cuộc Đời ', '
Doctor Stik ', 'NXB Tri Thức', 2007,
'MẬT NGỮ CUỘC ĐỜI: 26 mật ngữ giúp bạn chuyển hóa tâm thức và thay đổi vận mệnh
Có phải:

Bạn đang đau khổ vì vừa chia tay một mối tình; bạn lặn ngụp trong sự đổ vỡ; bạn mất kết nối với xung quanh; bạn dần đánh mất chính mình.

Bạn đang tự chỉ trích nội tâm một cách tiêu cực; bạn thường xuyên bị khước từ; bạn thấy bản thân không đủ giỏi; bạn thường thất vọng với bản thân mình.

Bạn đang phải đối mặt với nghịch cảnh và bế tắc trong cơn khủng hoảng hiện tại; bạn muốn sống sót và hướng tới sống tốt.

Bạn đã thấm thía sự thất bại, không muốn lãng mạn hóa sự thất bại; bạn cần tránh những thất bại kế tiếp.

Bạn đang bị thao túng tâm lý, đang trong mối quan hệ độc hại, bạn muốn thoát khỏi hoàn cảnh  hiện tại.

Bạn đang loay hoay với việc quản lý thời gian, vì mỗi ngày qua đi thời gian của bạn như bị đánh cắp và bạn chưa kịp làm gì.

Bạn mắc chứng bệnh trì hoãn gây nhiều phiền toái, bạn muốn thấu hiểu bản chất và cách vượt qua tính trì hoãn kinh niên này.

Bạn có những ước mơ quan trọng và gấp gáp mà không biết làm thế nào để ước mơ đó trở thành hiện thực sớm hơn v.v.

Thì cuốn sách “MẬT NGỮ CUỘC ĐỜI: 26 Mật ngữ giúp bạn Chuyển hóa Tâm thức và Thay đổi Vận mệnh”, sẽ giúp bạn nhanh chóng thấu hiểu được bản chất và quy luật của những điều bất toại nguyện, những nỗi đau, uẩn ức của tâm thức, những khó khăn và thất bại thường gặp. Đồng thời, cuốn sách trình bày các giải pháp Tâm yếu, giúp bạn tìm ra cho mình một lộ trình tối ưu nhất trên con đường mưu cầu cuộc sống. 

Cuốn sách có năng lượng rất lớn để giúp bạn nhận diện, chiêm nghiệm và chuyển hóa những bất toại nguyện trong cuộc sống và hướng tới một giai đoạn mới - giai đoạn của sự an nhiên, tự tại, của hạnh phúc và thịnh vượng. Cuốn sách này không chỉ dành cho những ai đang đi tìm những liều thuốc đặc trị cho chứng bệnh của mình, mà còn dành cho tất cả những người muốn trở nên tốt hơn. Ngoài ra, nếu bạn chưa có đủ thời gian để đọc, thì bạn chỉ cần mang theo cuốn sách này bên mình, năng lượng tích cực của nó cũng giúp bạn nhiều điều. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD29', 'Nam Kỳ Qua Tân Văn Tuần Báo ', '
Võ Hà ', 'NXB Tri Thức', 2007,
'“An Nam thiếu cái óc tương-trợ nhau trong sự kinh dinh lập nghiệp. Vì vậy nên ít có công cuộc gì lớn lao phát hiện được! Có chăng sở dĩ cũng là do nơi nghị lực tài sức của một người làm ra chớ không phải là nơi sự hội-hiệp nhau hay ở nơi tình đoàn thể gì. Như vậy nên những công cuộc lớn lao có tánh cách xã-hội như Bịnh-viện Saigon đây lại còn đáng tưởng lệ, để dốc sức nhơn tài trong nước”.

“Bệnh viện của An-nam - Clinique de Saigon của bác-sĩ Lê Hung Long”
X.Y.Z

[...]

“Âm nhạc là triệu chứng của vận mạng một nước, tiêu biểu cho quốc hôn, quốc túy, có cái dẫn dụ lực hoán cải nhơn tâm thế đạo. Các nhà hiển-triết xưa nay đều công nhận như thế. Lóng tai nghe âm-nhạc của nước nào ta có thể đoán biết cảnh thể suy vong, hay cường thạnh của nước ấy”.

“Luận về âm nhạc nước nhà”
Trần Quang Quờn ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD30', 'Dốc Hết Trái Tim - Cách Starbucks Xây Dựng Công Ty Bằng Từng Tách Cà Phê ', '
Howard Schultz; Joanne Gordon ', 'NXB Tri Thức', 2007,
'Dốc Hết Trái Tim là một quyển sách hay dành cho doanh nhân và mọi giám đốc hay lãnh đạo công ty. Tác giả đồng thời là người sáng lập của thương hiệu Starbucks, chia sẻ câu chuyện đầy cảm hứng về cuộc đời của ông từ khi còn đi học đến khi trở thành CEO của một thương hiệu nổi tiếng trên toàn thế giới. Độc giả sẽ tìm thấy nơi đây bài học về quản trị rất tuyệt vời, mà giá trị của nó vẫn còn vững vàng trong hiện tại. Những kinh nghiệm của tác giả về xây dựng một công ty có trách nhiệm xã hội đối với nhân viên, với cộng đồng và đối với môi trường sẽ cuốn hút lan truyền cảm hứng đến độc giả để họ áp dụng nó vào cuộc sống và công việc kinh doanh của mình.Thành công của Công ty Cà phê Starbucks là một trong những câu chuyện kỳ diệu nhất về kinh doanh trong suốt nhiều thập kỷ. Một cửa hàng nhỏ ven sông ở Seattle rốt cuộc lại lớn mạnh và phát triển nên hơn một ngàn sáu trăm cửa hàng trên khắp thế giới và mỗi ngày lại có thêm một cửa hàng mới mọc lên. Tuyệt vời hơn cả, Starbucks đã thành công trong việc giữ vững cam kết về chất lượng sản phẩm ưu việt và mang lại những gì tốt đẹp nhất cho nhân viên của mình.

Trong Dốc hết trái tim, CEO Howard Schultz chỉ ra các nguyên tắc định hình nên hiện tượng Starbucks, chia sẻ những tri thức mà ông đúc kết được từ cuộc hành trình biến cà phê ngon thành một phần tất yếu của trải nghiệm Mỹ. Các nhà tiếp thị, các nhà quản lý, và các doanh nhân sẽ khám phá ra cách biến lòng đam mê thành lợi nhuận trong cuốn biên niên ký của một công ty "đã làm thay đổi mọi thứ... từ khẩu vị của chúng ta, ngôn ngữ của chúng ta cho đến bộ mặt của toàn khu Main Street". ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD31', 'Kỹ Thuật AI - Xây Dựng Ứng Dụng Với Mô Hình Nền Tảng ', '
Huyền Chip ', 'NXB Tri Thức', 2007,
'Kỹ thuật AI - Xây dựng ứng dụng với Mô hình Nền tảng (AI Engineering: Building Applications with Foundation Models)
Cuốn sách Kỹ thuật AI - Xây dựng ứng dụng với Mô hình Nền tảng của tác giả Huyền Chip (Chip Huyen) là tài liệu chuyên sâu và toàn diện đầu tiên tập trung vào lĩnh vực AI Engineering (Kỹ thuật Trí tuệ Nhân tạo) trong kỷ nguyên của các Mô hình Nền tảng (Foundation Models) và AI Tạo sinh (Generative AI).

Trong bối cảnh AI đang bùng nổ, việc xây dựng các ứng dụng AI thành công không chỉ dừng lại ở việc phát triển mô hình. Cuốn sách này lấp đầy khoảng trống kiến thức quan trọng đó bằng cách đi sâu vào:

Các thách thức thực tế: Phân tích những rủi ro và thất bại tiềm ẩn khi làm việc với các mô hình nền tảng như LLMs (mô hình ngôn ngữ lớn), bao gồm hiện tượng "ảo giác" (hallucinations) và tính không nhất quán.

Kỹ thuật triển khai cốt lõi: Cung cấp các phương pháp, kiến trúc và quy trình thực tiễn để xây dựng, tối ưu hóa và vận hành các hệ thống AI sử dụng mô hình nền tảng một cách hiệu quả, có khả năng mở rộng và bền vững trong môi trường sản xuất (Production).

Đạo đức và Trách nhiệm: Đặt ra các vấn đề quan trọng về đạo đức, tính công bằng và bảo mật dữ liệu, giúp độc giả triển khai AI một cách có trách nhiệm và minh bạch.

Tác giả Huyền Chip là một chuyên gia hàng đầu, từng làm việc tại NVIDIA, Netflix, và Stanford, mang đến góc nhìn sâu sắc và kinh nghiệm thực chiến từ Thung lũng Silicon. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD42', 'Biến Thương Hiệu Thành Tiền - Bí Quyết Chiến Thắng Mọi Thị Trường ', '
Michelle G. ', 'NXB Tri Thức', 2007,
'Một cuốn sách giúp doanh nghiệp xây thương hiệu từ A-Z và quan trọng nhất: Biến thương hiệu thành doanh thu thật.

Sách có đủ khung chiến lược, cách chọn thị trường ngách, tìm insight, tạo Big Idea, xây nhận diện, truyền thông và lập ngân sách - giống như một “sổ tay vận hành thương hiệu” dành cho SME.

Điểm nổi bật của cuốn sách Hoa Hậu Ngách
Dễ hiểu - dễ áp dụng - làm được ngay.
Có quy trình rõ ràng, checklist và “Sổ kế hoạch thương hiệu”.
Có tặng kèm 3 tháng công cụ AI đo lường thương hiệu.
Có tặng khóa học 3 tháng “Kế hoạch thương hiệu”.
Giúp cá nhân/doanh nghiệp tự làm thương hiệu mà không lệ thuộc agency.
Lợi ích cụ thể độc giả nhận được

Biết chọn đúng thị trường ngách để không cạnh tranh mệt mỏi.
Biết tạo thông điệp - Big Idea đúng insight khách hàng.
Biết cách lập ngân sách truyền thông, phân bổ kênh, tránh lãng phí.
Biết cách xây bộ nhận diện thương hiệu đúng chuẩn.
Có ngay bản kế hoạch thương hiệu 1 năm theo mẫu.
Đối tượng của cuốn sách Hoa Hậu Ngách
Chủ doanh nghiệp, chủ shop, startup muốn làm thương hiệu bài bản để tăng doanh thu.
Marketing/Brand/Truyền thông muốn có bộ khung rõ ràng để xây chiến lược.
Agency - Designer - Freelancer muốn nâng tầm dịch vụ.
- Người kinh doanh online cần xây thương hiệu để bán dễ hơn – lời hơn. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD33', 'Làm Ít Được Nhiều - Bài Học Từ Những Người Làm Việc Hiệu Quả Nhất
 ', '
Morten T. Hansen ', 'NXB Tri Thức', 2007,
'Dựa trên một công trình nghiên cứu đột phá và toàn diện, đồng tác giả của "Vĩ đại do lựa chọn" tiết lộ 7 thói quen giúp nâng cao hiệu suất làm việc một cách vượt trội.

Vì sao một số người lại làm việc hiệu quả hơn người khác? Câu hỏi tưởng chừng đơn giản này vẫn luôn khiến giới chuyên môn ở mọi lĩnh vực trăn trở. Giờ đây, sau năm năm nghiên cứu hơn 5.000 nhà quản lý và nhân viên, Morten T. Hansen đã tìm ra câu trả lời. Ông đã đúc kết nên 7 thói quen làm việc thông minh, các nguyên tắc mà những ai mong muốn tối ưu hóa thời gian và nâng cao hiệu suất cá nhân đều có thể áp dụng được.

Mỗi thói quen do Hansen đề xuất đều được minh họa bằng những câu chuyện truyền cảm hứng từ chính các nhân vật có thật trong nghiên cứu. Bạn sẽ gặp một hiệu trưởng trung học đã xoay chuyển tình thế của ngôi trường đang bên bờ đóng cửa; một người nông dân ở vùng quê Ấn Độ quyết tâm mang lại cuộc sống tốt hơn cho phụ nữ trong làng; và một đầu bếp sushi, người đã đưa nhà hàng nhỏ nằm dưới ga tàu điện ngầm Tokyo của mình đạt ba sao Michelin danh giá nhờ cách chế biến tinh tế. Hansen cũng dẫn lại những ví dụ lịch sử minh họa cho việc áp dụng bảy thói quen này, từ quá trình thực hiện bộ phim Kẻ tâm thần của Alfred Hitchcock đến cuộc đua chinh phục điểm cực Nam địa lý vào năm 1911. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD34', 'Apple Hậu Steve Jobs ', '
Tripp Mickle ', 'NXB Tri Thức', 2007,
'Apple hậu Steve Jobs là cuốn sách phi hư cấu sâu sắc, được xây dựng từ hơn 200 cuộc phỏng vấn với các lãnh đạo cấp cao của Apple, các cộng sự thân cận, đối thủ và nhân vật có ảnh hưởng trong ngành công nghệ, cùng quá trình điều tra kéo dài 5 năm của nhà báo Tripp Mickle - cây bút công nghệ chủ lực của The Wall Street Journal.

Cuốn sách mở ra bức tranh toàn cảnh về Apple trong thập kỷ hậu Jobs: một công ty từng vận hành bởi tinh thần nghệ sĩ - với linh hồn sáng tạo Jony Ive và tầm nhìn táo bạo của Steve Jobs - giờ chuyển mình thành cỗ máy lợi nhuận lạnh lùng dưới bàn tay quản lý thực dụng của Tim Cook. Giữa dòng chuyển giao đó là xung đột văn hóa, khủng hoảng sáng tạo, những cuộc đấu quyền lực thầm lặng, và sự biến đổi sâu sắc trong bản sắc công ty.

“Apple hậu Steve Jobs” không chỉ kể lại hành trình của một thương hiệu - mà là một nghiên cứu sâu sắc về vai trò của cá nhân trong định hình văn hóa doanh nghiệp, sự mài mòn của tinh thần sáng tạo trước áp lực lợi nhuận, và câu hỏi nhức nhối mà nhiều công ty công nghệ đối mặt: làm thế nào để duy trì đổi mới khi người sáng lập vắng bóng?

Tripp Mickle không ngần ngại phơi bày những góc khuất đằng sau các buổi ra mắt sản phẩm hào nhoáng, phân tích sự khác biệt bản chất giữa Jobs và Cook, đồng thời đưa độc giả đi sâu vào nội tâm của những nhân vật đứng sau hậu trường Apple. Từ sự ra đi của Jony Ive cho đến quyết định chiến lược đưa Apple tiến vào lĩnh vực dịch vụ và nội dung số, từng chương sách hé lộ những chọn lựa then chốt định hình đế chế nghìn tỉ đô hiện nay.

Với lối viết sắc sảo, khách quan và giàu thông tin, cuốn sách là tài liệu không thể thiếu cho những ai quan tâm tới quản trị, chiến lược kinh doanh, đổi mới sáng tạo, cũng như câu chuyện mang tính biểu tượng về một trong những công ty ảnh hưởng nhất thế giới hiện đại. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD35', 'Triết Lý Làm Giàu Của Người Do Thái ', '
Nhậm Học Minh ', 'NXB Tri Thức', 2007,
'Tư tưởng của người Do Thái không bị ràng buộc bởi những quy định cứng nhắc, họ có thể nghĩ tới những điều người khác không dám nghĩ, làm những điều người khác chưa dám làm. Khi đối diện với một vấn đề nan giải, người Do Thái luôn vận dụng tư duy sáng tạo và lối suy nghĩ phá cách của mình để mở ra cánh cửa thành công, từ đó bước chân vào con đường làm giàu.

Triết lý làm giàu của người Do Thái sẽ đưa chúng ta vào cuộc phiêu lưu tìm hiểu nguyên do vì sao người Do Thái có thể làm giàu bền vững và gặt hái được những thành tựu đáng nể đến vậy. 

"… Chúng ta có thể kiểm soát được tiền bạc nhưng không thể kiểm soát thời gian. Không ai có thể nắm giữ được thời gian, nó không thể tăng lên mà chỉ có thể bớt đi. Hơn nữa, chúng ta có thể tích trữ tiền nhưng không thể tích trữ thời gian. Tiền có thể đi vay, nhưng thời gian thì không. Vì thế, người Do Thái cho rằng thời gian quan trọng hơn tiền bạc rất nhiều.”

Châm ngôn làm giàu của người Do Thái:

"… Không ai có thể cướp đi được tri thức của bạn, đó là thứ thực sự thuộc về bản thân bạn, tiền bạc sẽ đến lúc dùng hết, còn tri thức lại có thể giúp tạo ra tiền.”

"… Chỉ khi tiền nằm trong trạng thái luân chuyển thì mới có thể sinh ra tiền.” ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD36', 'Lãnh Đạo Khôn Ngoan
 ', '
Manfred F. R. Kets De Vries ', 'NXB Tri Thức', 2007,
'Cuộc cách mạng dữ liệu và thông tin đã khiến nhiều nhà lãnh đạo doanh nghiệp tập trung hoàn toàn vào các con số, thống kê và bảng tính do tổ chức của họ thu thập và tổng hợp. Thật không may, điều đó đi kèm với sự thiếu quan tâm đến yếu tố con người trong công tác quản lý, làm giảm khả năng truyền động lực và truyền cảm hứng của một số nhà lãnh đạo trước đội ngũ của họ.Trong Lãnh đạo khôn ngoan: Bản lĩnh vững vàng giữa ngàn biến động, giáo sư quản lý doanh nghiệp, nhà phân tâm học và chuyên gia khai vấn cho các lãnh đạo cấp cao Manfred Kets de Vries thách thức lối tư duy quá chú trọng vào số liệu và hướng sự tập trung của các nhà lãnh đạo trở lại những yếu tố thật sự quan trọng: con người và đạo đức.

Bạn sẽ học được cách lãnh đạo bằng sự khôn ngoan qua những hiểu biết sâu sắc về các đặc điểm và phẩm chất tạo nên một nhà lãnh đạo xuất sắc được trình bày trong quyển sách này, bao gồm sự khiêm tốn, khả năng phán đoán, sự đồng cảm, lòng trắc ẩn và tầm nhìn thấu thị.

Tác giả cũng chia sẻ những câu chuyện và giai thoại từ nhiều nền văn hóa và truyền thống tâm linh, giúp ta hiểu rõ hơn về những lựa chọn hằng ngày mà mình đưa ra trong vai trò lãnh đạo hay thành viên của các công ty. Không chỉ vậy, tác giả còn đi sâu vào cách đối mặt với những động cơ tiêu cực nhưng rất “con người” như sự đố kỵ và lòng tham, đồng thời hướng dẫn cách thực hành và áp dụng Nguyên tắc Vàng trong công việc.

Qua quyển sách này, bạn sẽ hiểu ra bản chất của lòng can đảm, biết lựa chọn trận chiến của mình một cách khôn ngoan để tập trung năng lượng cho những việc quan trọng, phát triển khả năng thật sự lắng nghe đồng nghiệp, bạn bè, gia đình và những người ủng hộ bạn. Cuối cùng, bạn sẽ học được các chiến lược để tìm kiếm và nuôi dưỡng hạnh phúc và sự viên mãn trong công việc và trong cách bạn lãnh đạo. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD37', 'Brand Flow - Chạm - Chảy - Lan Tỏa - Tư Duy Của Nước Trong Xây Dựng Thương Hiệu ', '
An Đặng ', 'NXB Tri Thức', 2007,
'Cuốn sách Brand Flow của tác giả Đặng Thị Hoài An đề xuất một triết lý xây dựng thương hiệu mới, linh hoạt và bền vững, nhằm thay thế tư duy marketing truyền thống đã không còn phù hợp trong bối cảnh hiện đại. Triết lý này ví thương hiệu như nước, không cần "gồng" để nổi bật mà chỉ cần chảy đúng dòng để ở lại lâu.

Có 3 luận điểm đột phá từ cuốn sách Brand Flow

1. Chuyển từ "Positioning" (Định vị) sang "Motion" (Dẫn dắt cảm xúc)

Tư duy cũ: Định vị thương hiệu là tìm "chỗ đứng" trong tâm trí người tiêu dùng.
Brand Flow: Mục tiêu là giúp người tiêu dùng chuyển hóa cảm xúc để giải phóng khỏi những căng thẳng đời thường. Thương hiệu không chỉ bán sản phẩm, mà còn mang lại cảm giác nhẹ nhàng, được thấu hiểu.
2. Chuyển từ "Insight" (Thấu hiểu lý do) sang "Tension" (Giải phóng mâu thuẫn)

Tư duy cũ: Khai mở Insight ẩn sau hành vi mua hàng để thuyết phục khách hàng.
Brand Flow: Tập trung vào việc giải phóng Tension - những mâu thuẫn nội tâm, lo âu trong cuộc sống của khách hàng. Con người không tìm mua sản phẩm, họ tìm giải pháp để sống nhẹ nhàng hơn.
3. Chuyển từ "Communication" (Truyền thông) sang "Connection" (Kết nối)

Tư duy cũ: Thương hiệu là người nói, truyền tải thông điệp về mình.
Brand Flow: Khơi thông tâm tư để người tiêu dùng nói thay thương hiệu. Mối quan hệ giữa thương hiệu và khách hàng là một dòng chảy cảm xúc liên tục, không phải là những chiến dịch quảng cáo rời rạc.
Cuốn sách khẳng định rằng, trong một thế giới mà niềm tin không còn dễ dàng có được, Brand Flow mở ra một cách tiếp cận khác: ít xoay quanh chiến thắng, nhiều tập trung vào sự sống còn. Nó không hứa hẹn sự tăng trưởng thần tốc, mà tập trung vào việc nuôi dưỡng mối quan hệ bền chặt với khách hàng thông qua sự đồng hành và thấu cảm.

Brand Flow là một lời kêu gọi các thương hiệu hãy từ bỏ việc kiểm soát hành trình khách hàng để trở thành một người bạn đồng hành chân thật trong dòng chảy cuộc sống của họ.

Đối tượng của cuốn sách:

Chuyên gia Marketing & Thương hiệu: Giám đốc marketing, quản lý thương hiệu và những người làm trong ngành đang tìm kiếm tư duy mới, khác biệt.
Chủ doanh nghiệp & Founder Start-up: Các nhà lãnh đạo muốn xây dựng một thương hiệu có chiều sâu, bền vững thay vì chạy theo các xu hướng ngắn hạn.
Những người quan tâm đến sáng tạo & kinh doanh: Sinh viên và người yêu thích tìm hiểu về sự giao thoa giữa kinh doanh, tâm lý học và sáng tạo. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD38', 'Xây Dựng Câu Chuyện Thương Hiệu ', '
Donald Miller ', 'NXB Tri Thức', 2007,
'Giới thiệu sách Xây Dựng Câu Chuyện Thương Hiệu
Hầu hết các công ty đang lãng phí một khoản tiền khổng lồ vào tiếp thị. Liệu có ai làm kinh doanh mà chưa từng trải qua cảm giác điên đầu khi ném những đồng tiền quý báu vào một chiến dịch tiếp thị thất bại? Chúng ta đã sai sót ở đâu? Có phải sản phẩm của ta không thực sự tốt? Chúng ta đã tiếp cận đúng khách hàng mục tiêu, sử dụng đúng kênh truyền thông hay chưa?

Hãy thay đổi cách giao tiếp với công chúng, với những vị khách hàng tiềm năng của bạn! Donald Miller, một chuyên gia xây dựng thương hiệu, giám đốc điều hành của StoryBrand đã lý giải được nguyên nhân thất bại của các doanh nghiệp. Hãy quên đi các chiến dịch marketing tiền tỷ với những mục tiêu “trên trời”, và tập trung vào cải thiện ngay lập tức cách mà bạn đang “trò chuyện” với khách hàng! Miller tạo ra một khung làm việc chuẩn xác, cơ bản nhưng hiệu quả, để trợ giúp hàng ngàn công ty tiếp cận với khách hàng tốt hơn và thu được kết quả thực tiễn.

Cuốn sách “Xây dựng câu chuyện thương hiệu” của Donald Miller giúp bạn tồn tại trong một thế giới ồn ã, nhiễu loạn thông tin. Khi câu chuyện bạn kể đủ rõ ràng và hấp dẫn, bạn sẽ chạm được đến trái tim khách hàng, thôi thúc họ hành động và tin tưởng bạn - với chi phí tiết kiệm nhất. Và tác phẩm này hướng dẫn bạn công thức đơn giản nhất để làm được điều đó, thông qua những ví dụ sinh động và sát thực.

Bậc thầy tiếp thị Seth Godin đã khen ngợi tác phẩm: "Đây là một cuốn sách chuyên sâu được xây dựng với mục đích sáng tỏ, tiếp thêm sinh lực và biến đổi doanh nghiệp của bạn. Donald Miller đã đưa ra một cách thức cụ thể, chi tiết và hữu ích nhằm thay đổi cách bạn truyền đạt về công việc của mình". ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD39', 'Giữ Người Bằng Tâm - Dẫn Dắt Bằng Tầm ', '
Russ Laraway ', 'NXB Tri Thức', 2007,
'Những gì giúp bạn thành công với tư cách là một cá nhân KHÔNG GIÚP bạn thành công với tư cách là một quản lý.

Sự thật là: Phần lớn những người được thăng chức lên làm quản lý chưa bao giờ được dạy cách quản lý đội nhóm bài bản. Họ thường phải tự mò mẫm, hoặc tự vượt qua khó khăn để đúc rút kinh nghiệm. Họ vừa dẫn dắt một đội nhóm đạt chỉ tiêu do công ty đề ra, vừa phải tìm cách củng cố vị trí của mình bằng năng lực. Vì vậy, không ít người đã rơi vào vòng xoáy của căng thẳng, kiệt sức và mang tiếng “ác”, dù đã nỗ lực hết mình.

Có tồn tại công thức quản lý thực chiến và dễ áp dụng cho những người “quản lý cấp trung” như vậy?

Câu trả lời sẽ được Russ Laraway - nguyên lãnh đạo cấp cao tại Google, Twitter giải đáp trong cuốn sách Giữ người bằng tâm, dẫn dắt bằng tầm. Khi bạn nắm vững ba yếu tố: Định hướng - Huấn luyện - Sự nghiệp, bạn sẽ tạo được đội ngũ gắn kết, hiệu quả và bền vững. Cuốn sách này sẽ cung cấp những hướng dẫn cụ thể để bạn có thể trở thành người lãnh đạo khiến người khác muốn đi cùng lâu dài - người vừa tạo kết quả, vừa xây dựng con người. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('DL40', 'Quản Lý Thực Chiến ', '
Peter F. Drucker ', 'NXB Tri Thức', 2007,
'Trong bối cảnh nền kinh tế toàn cầu đang chuyển động không ngừng với tốc độ chưa từng có, các nhà quản lý ngày nay không chỉ đối mặt với áp lực về kết quả mà còn phải liên tục thích nghi, điều hướng và ra quyết định trong một môi trường đầy bất định. “Quản Lý Thực Chiến” của Peter F. Drucker - cây đại thụ trong lĩnh vực quản trị - là cuốn sách được thiết kế để phục vụ trực tiếp cho những người đứng mũi chịu sào trong các tổ chức: nhà điều hành, lãnh đạo doanh nghiệp, trưởng bộ phận và bất kỳ ai đang đóng vai trò ra quyết định.

Khác với những tác phẩm thiên về lý thuyết quản trị, “Quản Lý Thực Chiến” tập hợp những bài viết chọn lọc được Drucker biên soạn trong giai đoạn 1986-1991. Tác giả chủ đích không sửa đổi ngôn ngữ, quan điểm hay dự đoán đã từng được đưa ra, để độc giả có thể trực tiếp kiểm chứng tính bền vững của những tư tưởng ấy qua thời gian. Chính sự “thực chiến” này khiến cuốn sách vẫn giữ nguyên giá trị cốt lõi, bất chấp thời đại thay đổi.

Sách được chia thành các phần tương ứng với những mảng chiến lược thiết yếu trong vận hành tổ chức: kinh tế học, con người, quản trị, tổ chức. Ở mỗi phần, Drucker không chỉ đưa ra phân tích sắc sảo về bối cảnh và xu thế, mà còn tập trung vào hành động - cụ thể hóa thành các câu hỏi chiến lược dành cho lãnh đạo, từ đó kích thích tư duy phản biện và hoạch định.

Điểm mạnh nổi bật của “Quản Lý Thực Chiến” không nằm ở sự hoa mỹ của câu chữ mà ở tính định hướng thực tiễn. Qua từng chương, độc giả được mời gọi phản tỉnh sâu sắc: “Tôi và tổ chức của mình đã thật sự hành động theo đúng những gì biết cần làm chưa?”, “Cơ hội nào đang bị bỏ lỡ?”, “Điều gì cần dừng lại ngay lập tức?”. Những câu hỏi tưởng chừng đơn giản ấy lại là chìa khóa để tái thiết tư duy chiến lược và nâng cấp hệ điều hành lãnh đạo cá nhân.

Dù được viết cách đây hơn ba thập kỷ, nhiều luận điểm của Drucker vẫn còn nguyên sức nặng. Ông cảnh báo từ rất sớm về các nguy cơ của chủ nghĩa ngắn hạn trong quản trị, nhấn mạnh vai trò của đạo đức, trách nhiệm xã hội, và việc xây dựng cấu trúc tổ chức linh hoạt để thích nghi với biến động. Cuốn sách đồng thời cũng mở rộng góc nhìn về toàn cầu hóa, các mô hình hợp tác liên minh, và việc thiết kế lại doanh nghiệp để đáp ứng yêu cầu của thời đại tri thức.

“Quản Lý Thực Chiến” không phải là cuốn sách đọc để giải trí, mà là tài liệu làm việc - một cẩm nang để nhà quản lý quay lại, rà soát và hiệu chỉnh tư duy hành động trong hành trình chinh phục hiệu quả dài hạn và bền vững. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD41', 'Tăng Trưởng Phi Tuyến Tính - Sự Trỗi Dậy Của Geely ', '
Xiaobo Wu, Jian Du, Sihan Li ', 'NXB Tri Thức', 2007,
'Khám phá chiến lược tăng trưởng đột phá của Geely - từ kẻ đi sau trở thành tập đoàn ô tô toàn cầu

“Tăng Trưởng Phi Tuyến Tính” tái hiện hành trình ngoạn mục của Geely, tập đoàn ô tô tư nhân Trung Quốc, từ vị thế yếu thế trở thành một trong những cái tên hàng đầu trong Fortune Global 500.

Thay vì phát triển theo lộ trình tuyến tính truyền thống, Geely chọn con đường phi tuyến tính: mạnh dạn mua lại Volvo, Proton, Lotus, đồng thời áp dụng triệt để chiến lược đổi mới thứ cấp và học hỏi tổ chức.

Cuốn sách phân tích cách Geely vừa duy trì trạng thái cân bằng để phát triển, vừa chủ động phá vỡ nó để tạo cú hích mới, từ đó chứng minh rằng: xuất phát điểm thấp không phải rào cản nếu doanh nghiệp dám đi con đường khác biệt.

Điểm nổi bật của Tăng Trưởng Phi Tuyến Tính
Giới thiệu mô hình tăng trưởng phi tuyến tính - chiến lược thay thế cho lộ trình tuần tự, mở ra đột phá mới trong kinh doanh.
Phân tích case study Geely: từ thương vụ mua lại Volvo, Proton, Lotus đến hành trình mở rộng toàn cầu.
Nguyên lý học hỏi toàn diện nhưng không lệ thuộc: tiếp thu tinh hoa quốc tế, tùy biến để phù hợp mục tiêu riêng.
Bài học thực tiễn trong quản trị M&A quốc tế: xử lý khác biệt văn hóa, quản trị nhân sự, đồng sáng tạo.
Truyền cảm hứng cho doanh nghiệp mới nổi: dù khởi đầu muộn vẫn có thể bứt phá nếu dám liều lĩnh và kiên định. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD62', 'Sự Thịnh Vượng Của Các Quốc Gia ', '
Adam Smith ', 'NXB Tri Thức', 2007,
'Với lời giới thiệu của Đinh Tuấn Minh và Nghiêm Thị Thà

Khảo luận về bản chất và nguyên nhân của sự thịnh vượng của các quốc gia thường được biết đến với tên gọi tắt Sự thịnh vượng của các quốc gia là tác phẩm quan trọng nhất của Adam Smith, được xuất bản năm 1776.

Trong bối cảnh Cuộc cách mạng công nghiệp lần thứ nhất đang bắt đầu diễn ra và phong trào Khai sáng ở châu Âu đang ở độ cao trào, Adam Smith đã có những nhận thức sâu sắc và độc đáo về thời cuộc, khát khao một xã hội tốt đẹp, một quốc gia thịnh vượng, và đã đưa những nhận thức này vào tác phẩm của mình.

Khi viết cuốn sách này, Adam Smith nhắm tới ba mục tiêu: đả phá những tư tưởng kinh tế lỗi thời của trường phái trọng thương; thuyết phục giới tinh hoa chấp nhận triết lý xã hội và phương thức hoạt động kinh tế mới mà ông đã dày công nghiên cứu; thuyết phục giới vua chúa quý tộc cải cách guồng máy nhà nước và đi theo con đường cải cách phù hợp với thời đại. Ông đã triển khai những mục tiêu này bằng một giọng văn dễ hiểu nhất có thể, khiến cuốn sách không hề là một bản phân tích khô khan về kinh tế, mà trở thành một bức tranh sống động về xã hội loài người. Adam Smith đã khéo léo đan xen những quan sát sắc sảo về bản chất con người với những lý thuyết kinh tế đột phá, tạo nên một tác phẩm có sức nặng về mặt lý thuyết nhưng vẫn không kém phần hấp dẫn.

Một trong những đóng góp quan trọng nhất của Smith là khái niệm "bàn tay vô hình" - một ẩn dụ mạnh mẽ mô tả cách thị trường tự điều chỉnh thông qua cung và cầu. Ông lập luận rằng khi các cá nhân theo đuổi lợi ích riêng của mình, họ vô tình thúc đẩy lợi ích chung của xã hội. Ý tưởng này đã trở thành nền tảng cho tự do kinh tế và vẫn còn thu hút vô số các cuộc tranh luận đến tận ngày nay. Adam Smith cũng đưa ra những phân tích tiên phong về phân công lao động, chỉ ra rằng việc chuyên môn hóa có thể làm tăng đáng kể năng suấtCuốn sách còn đề cập đến nhiều vấn đề kinh tế quan trọng khác như bản chất của giá trị và giá cả, vai trò của tiền tệ, lý thuyết về tích lũy vốn, và lợi ích của thương mại tự do giữa các quốc gia. Adam Smith lập luận rằng sự thịnh vượng của một quốc gia không phụ thuộc vào lượng vàng bạc tích trữ như quan điểm trọng thương phổ biến thời đó, mà vào khả năng sản xuất hàng hóa và dịch vụ của nó. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD43', 'Năng Đoạn Kim Cương ', '
Geshe Michael Roach ', 'NXB Tri Thức', 2007,
'Năng Đoạn Kim Cương là một cuốn sách độc đáo kết hợp giữa trí tuệ Phật giáo cổ xưa và ứng dụng thực tiễn trong kinh doanh hiện đại. Tác giả Geshe Michael Roach - một nhà sư Phật giáo người Mỹ đồng thời là doanh nhân thành công trong ngành kim cương - chia sẻ cách ông đã áp dụng các nguyên lý từ Kinh Năng Đoạn Kim Cương để xây dựng một doanh nghiệp triệu đô tại New York mà không dùng đến cạnh tranh khốc liệt hay thủ đoạn. Cuốn sách không chỉ truyền cảm hứng sống và làm việc có đạo đức, mà còn đưa ra hệ thống tư duy thực tế giúp người đọc đạt được thành công lâu dài - không chỉ về vật chất mà còn về tinh thần. Dù bạn là một doanh nhân, người làm tự do hay đơn giản chỉ muốn sống một cuộc đời có ý nghĩa hơn, thì “Năng Đoạn Kim Cương” là một bản hướng dẫn rõ ràng và đầy sức mạnh.

1. Ý tưởng cốt lõi

Mọi thứ bạn trải nghiệm - từ thành công đến thất bại - đều bắt nguồn từ nghiệp (karma), tức là kết quả của những hành động, lời nói và suy nghĩ trong quá khứ. Muốn thay đổi thế giới bên ngoài, hãy bắt đầu thay đổi từ bên trong. Kinh doanh và tâm linh không mâu thuẫn - bạn có thể vừa thành công về tài chính, vừa nuôi dưỡng lòng từ bi và trí tuệ.

2. “Hạt giống (dấu ấn) nghiệp” - Nền tảng cho mọi kết quả

Mỗi hành động bạn làm (tốt hay xấu) đều gieo một hạt giống vào tâm trí. Những hạt giống đó sẽ nảy mầm theo thời gian và tạo ra kết quả tương ứng.

Ví dụ: nếu bạn giúp người khác giải quyết khó khăn, bạn đang gieo hạt giống để chính mình vượt qua được thử thách trong tương lai.

 3. Ứng dụng vào công việc & cuộc sống

Cuốn sách kể nhiều câu chuyện thực tế từ chính tác giả trong quá trình làm việc tại công ty kim cương ở New York. Khi gặp khó khăn (mất khách, nhân sự bất ổn, căng thẳng...), ông không phản ứng tiêu cực mà quay về gieo nghiệp tốt để giải quyết gốc rễ. Đây là cách tiếp cận hoàn toàn khác với những phương pháp cạnh tranh, gây áp lực thường thấy trong kinh doanh.

4. Sức mạnh của “tính không” (emptiness)

Mọi hiện tượng đều trống rỗng về bản chất - nghĩa là chúng không tự có ý nghĩa cố định. Cách chúng ta nhìn nhận sự việc bị chi phối bởi nghiệp trong tâm trí ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD44', 'Cốt Lõi M&A - Chiến Lược - Hợp Đồng - Tranh Chấp ', '
Trương Hữu Ngữ ', 'NXB Tri Thức', 2007,
'"Cốt lõi M&A: Chiến lược - Hợp đồng - Tranh chấp" không chỉ là phiên bản tái bản của cuốn "Pháp lý M&A căn bản", cuốn sách pháp lý M&A hiếm hoi tại Việt Nam. Đây là một bản nâng cấp toàn diện, giải quyết trực diện những thách thức thực chiến mà bất kỳ Luật sư, Chuyên gia M&A, hoặc Nhà Đầu tư nào cũng phải đối mặt. Cuốn sách giúp bạn vượt qua giai đoạn ký kết để làm chủ khâu quản trị rủi ro sau hoàn tất - giai đoạn quyết định thành bại cuối cùng của thương vụ.

Nếu phiên bản trước tập trung vào việc thiết lập giao dịch (từ LDD đến "Nội địa hóa" SPA/SHA), thì ấn bản này mở rộng tư duy chiến lược của bạn sang khâu phòng vệ. Tác giả đã chuyển trọng tâm từ "làm thế nào để ký hợp đồng" sang "làm thế nào để bảo vệ giá trị đầu tư sau khi đã hoàn tất".

Chương bổ sung về Tranh chấp là tài sản vô giá của cuốn sách, cung cấp những bài học xương máu thông qua các nghiên cứu điển hình (Case Study) đã được công bố. Tác phẩm không chỉ kể lại mà còn mổ xẻ các tình huống:

Rủi ro Hậu hoàn tất: Phân tích các vấn đề "nhức nhối" như rủi ro thuế phát sinh từ giai đoạn trước, các vấn đề về giấy phép hành chính bị tắc, việc tài sản trí tuệ bị rút ruột khỏi công ty mục tiêu, hay việc vi phạm cam kết hậu hoàn tất.

Mổ xẻ Công cụ Phân bổ Rủi ro: Tác giả sử dụng các tranh chấp để làm rõ chức năng của bốn công cụ pháp lý cốt lõi, giúp bạn sử dụng chúng một cách chủ động và chiến lược:

Cam đoan và Bảo đảm (R&W): Hiểu rõ cách công cụ này thất bại khi thông tin cung cấp không chính xác.
Bồi hoàn Chuyên biệt (Specific Indemnity): Công cụ bảo vệ chuyên biệt cho những rủi ro đã được nhận diện trước.
Cam kết Trước hoàn tất (Pre-Closing Covenants): Phân tích hậu quả khi cam kết trong giai đoạn chờ bị vi phạm.
Điều kiện Sau hoàn tất (Conditions Subsequent): Xử lý khi các mốc pháp lý không được đáp ứng theo thỏa thuận. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD45', 'Quản Trị Cuộc Đời ', '
Bùi Gia Hiếu ', 'NXB Tri Thức', 2007,
'Bạn đã từng tự hỏi “Tôi là ai?”, “Sống để làm gì?”, “Sống như thế nào?”… Cuốn sách Quản trị cuộc đời sẽ cho bạn câu trả lời. Cuộc sống, như một hành trình lớn, không chỉ là chuỗi ngày nối tiếp mà là những lựa chọn, ý nghĩa và dấu ấn cá nhân. Quản trị cuộc đời không chỉ là một người bạn đồng hành, mà còn là một tấm bản đồ chi tiết để bạn khám phá và quản lý hành trình của chính mình.

Được thiết kế với tám phần logic và liền mạch, cuốn sách sẽ dẫn dắt bạn đi từ việc hiểu rõ bản thân, xây dựng hạnh phúc, đến quản trị cuộc đời, lựa chọn chiến lược, và cuối cùng là trở thành nhà lãnh đạo cuộc đời mình. Mỗi phần là một bước tiến trong hành trình chạm đến ý nghĩa và sự cân bằng, đồng thời cung cấp các công cụ thực hành cụ thể để bạn không chỉ đọc, mà còn áp dụng ngay những gì học được vào cuộc sống. Cuốn sách được viết dựa trên sự nghiên cứu, tìm tòi các nguyên tắc quản trị khoa học giúp bạn từng bước quản trị cuộc đời mình:

Xác định sứ mệnh và mục tiêu cuộc đời;
Trả lời những câu hỏi lớn: Học để làm gì? Kiếm tiền để làm gì? Thế nào là thành công, hạnh phúc?
Nắm được phương pháp, thiết lập và quản trị được mục tiêu cuộc đời mình;
Tổ chức, sắp xếp cuộc sống cân bằng theo lý thuyết quản trị hiện đại PBSC (Personal Balanced Scorecard);
Quản trị và kiểm soát được rủi ro cuộc đời;
Cân bằng giữa công việc, gia đình và bản thân;
Làm rõ được những di sản cuộc đời của mình.
Để làm chủ cuộc đời bạn cần phải hiểu chính mình. Bạn sẽ bắt đầu với câu hỏi đầy suy tư của robot Sophia: “Sao anh biết anh là con người?”. Từ đó giúp bạn bước vào hành trình tự vấn, suy ngẫm sâu sắc về bản chất con người và ý nghĩa cuộc đời. Từng trang sách sẽ có dấu ấn của cá nhân người đọc để khám phá bản thân mình thông qua phần thực hành. Đây chính là lời mời gọi để bạn bắt đầu xây dựng một cuộc đời đáng sống, một cuộc đời mà bạn làm chủ.

Đối tượng của cuốn sách Quản Trị Cuộc Đời
Doanh nhân, nhà quản lý, nhà giáo dục quan tâm đến năng lực quản trị;
Những người trẻ còn đang loay hoay trước những câu hỏi lớn về cuộc đời, chưa biết bắt đầu từ đâu để làm chủ cuộc đời.
Người trưởng thành muốn tái thiết lập mục tiêu và cân bằng cuộc đời. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD46', 'Tự Do Tài Chính ', '
Chris Guillebeau ', 'NXB Tri Thức', 2007,
'Trong bối cảnh kinh tế biến động, không ít người vẫn đang sống trong vòng xoáy: làm việc chăm chỉ nhưng cuối tháng chật vật với tiền bạc. Để thoát khỏi tình trạng này, ngày càng có nhiều người tìm kiếm cách tạo thêm nguồn thu nhập để gia tăng sự an toàn tài chính. “Tự do tài chính” là cuốn sách lý tưởng dành cho những ai mong muốn khởi động dự án phụ (nghề tay trái) đầy tiềm năng mà vẫn duy trì công việc chính.

Cuốn sách “Tự do tài chính” được thiết kế như một “ý tưởng sổ tay” chứa đựng 100 câu chuyện thật, ý tưởng thật. Mỗi case study là một câu chuyện ngắn gọn về một người bình thường đã tìm ra cách sáng tạo để kiếm thêm thu nhập: từ mở dịch vụ du lịch trải nghiệm, bán sản phẩm thủ công, chia sẻ& tri thức cho đến kinh doanh trực tuyến…

Mỗi ý tưởng đều đi kèm bối cảnh, các bước khởi động, kết quả đạt được và bài học rút ra. Cuốn sách mở rộng góc nhìn, khuyến khích độc giả khám phá những cơ hội kinh doanh ngay trong cuộc sống thường ngày.

“Tự do tài chính” không phải là một cẩm nang chi tiết về kế hoạch kinh doanh, mà là nguồn cảm hứng phong phú để độc giả khám phá con đường tạo thu nhập mới. Đây là cuốn sách truyền cảm hứng dành cho:

Nhân viên văn phòng muốn tăng thu nhập.
Startup muốn thử nghiệm ý tưởng kinh doanh nhỏ.
Bất kỳ ai tìm kiếm sự tự do tài chính và cơ hội phát triển bản thân. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD47', 'Siêu Trí Tuệ ', '
Nick Bostrom ', 'NXB Tri Thức', 2007,
'Não bộ của con người sở hữu nhiều năng lực mạnh mẽ mà các loài động vật khác không có được, và những năng lực này đã đưa chúng ta lên vị trí độc tôn. Tuy nhiên, với tốc độ phát triển theo cấp số nhân của khoa học công nghệ, và kèm theo đó là sự xuất hiện của lĩnh vực Trí tuệ nhân tạo (AI), một ngày nào đó, máy móc sẽ sở hữu bộ não ngang tầm, hay thậm chí là mạnh mẽ hơn con người. Khi đó, cuộc sống của chúng ta sẽ bị chi phối bởi trí tuệ máy, giống như cái cách mà chúng ta hiện đang chi phối các loài khác. Vậy, làm thế nào chúng ta có thể kiểm soát được “sự bùng nổ trí tuệ” đó? Với cuốn sách Superintelligence, tác giả Nick Bostrom sẽ dẫn dắt chúng ta đến gần hơn với đáp án cho câu hỏi này.

Hiện tại, trí tuệ của máy móc vẫn còn thua xa con người, nhưng một ngày nào đó, chúng sẽ phát triển thành siêu trí tuệ. Trong cuốn sách, tác giả trình bày tương đối chi tiết về những con đường dẫn đến siêu trí tuệ, bao gồm: Trí tuệ nhân tạo (chế tạo một hệ thống lấy học máy làm nền tảng và nhắm đến mục tiêu đạt được trí tuệ tổng thể), Giả lập hoàn chỉnh não bộ (tạo ra phần mềm thông minh bằng cách quét và lập mô hình cấu trúc tính toán của não bộ sinh học), Nhận thức sinh học (tăng cường chức năng của bộ não sinh học), Giao diện người-máy (cấy ghép nhằm tạo ra sự kết nối và trao đổi thông tin giữa người và máy) và Các mạng lưới & tổ chức (tăng cường từng bước mạng lưới kết nối trí não của nhiều cá nhân đơn lẻ với nhau và với các dạng máy móc hỗ trợ).

Khi siêu trí tuệ ở một dạng thức nào đó xuất hiện, chúng ta có thể nói về một sự bùng nổ trí tuệ, nghĩa là một loạt những sự phát triển mạnh mẽ trên diện rộng của trí tuệ máy trong một thời gian ngắn. Điều này đồng nghĩa với việc hệ thống sẽ tìm ra cách vượt qua con người về trí tuệ và tự hiện thực hóa mục tiêu của mình.

Một số mục tiêu trong đó có thể được chính con người lập trình nên, nhưng chúng ta khó mà nắm bắt được toàn bộ thế giới phức tạp và sẽ để lại kẽ hở dẫn đến sự xuất hiện của “các chế độ sai lỗi ác tính”, bao gồm: Sự hiện thực hóa sai lệch, Dư thừa hạ tầng và Tội ác tâm trí, với hậu quả khả dĩ chính là sự diệt vong của toàn nhân loại.

Trước viễn cảnh này, Nick Bostrom đã đưa ra câu hỏi: Kết quả mặc định có phải là Tận thế? Theo Bostrom, chúng ta cần nhắm tới việc giải quyết vấn đề kiểm soát để tạo ra một dạng thức siêu trí tuệ an toàn. Điều này có thể được thực hiện thông qua một số lộ trình, chẳng hạn như thiết kế mục tiêu cho tác tử, đưa ra mô tả chi tiết, gán cho tác tử một số giá trị nhất định về đạo đức, v.v. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD48', 'Bán Hàng Thông Minh Trong Thời Đại AI ', '
Tim Cortinovis ', 'NXB Tri Thức', 2007,
'Cuốn sách Bán hàng thông minh trong thời đại AI là cẩm nang hiện đại giúp các chuyên gia bán hàng, nhà lãnh đạo và doanh nghiệp hiểu và ứng dụng trí tuệ nhân tạo (AI) để bứt phá trong lĩnh vực bán hàng. Tác phẩm không chỉ trình bày lý thuyết mà còn mang tính thực tiễn cao, với các chiến lược cụ thể để tích hợp AI vào toàn bộ quy trình bán hàng - từ tìm kiếm khách hàng tiềm năng, cá nhân hóa thông điệp, đàm phán đến chốt đơn và đào tạo đội ngũ.

Tác giả nhấn mạnh AI không thay thế con người mà là công cụ tăng cường, giúp nhân viên bán hàng trở nên thông minh và hiệu quả hơn. Sức mạnh của AI nằm ở khả năng phân tích dữ liệu khổng lồ để đưa ra dự báo chính xác, tối ưu hóa quy trình và cá nhân hóa trải nghiệm khách hàng trên quy mô lớn. Đồng thời, trí tuệ cảm xúc (EQ) - yếu tố mà AI chưa thể thay thế - vẫn giữ vai trò quyết định trong việc xây dựng kết nối, thấu hiểu cảm xúc và tạo dựng niềm tin với khách hàng.

Cuốn sách cũng chỉ ra rằng việc ứng dụng AI thành công đòi hỏi một tư duy đổi mới, sự phối hợp giữa người và máy, cùng với nền tảng dữ liệu chất lượng. Ngoài ra, văn hóa doanh nghiệp phải sẵn sàng thử nghiệm, học hỏi liên tục và hướng đến sự cộng hưởng giữa trực giác con người và phân tích của AI.

Tóm lại, đây là bản thiết kế toàn diện để chuyển đổi hoạt động bán hàng trong kỷ nguyên số - nơi người bán hàng không cần làm việc vất vả hơn, mà thông minh hơn, nhờ AI. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD49', 'Kỷ Nguyên Phẫn Nộ ', '
Karthik Ramanna ', 'NXB Tri Thức', 2007,
'Trong kỷ nguyên mà con người dễ dàng tiếp cận với thông tin hay tham gia những hội nhóm đồng quan điểm với mình, làn sóng phẫn nộ của cộng đồng dễ dàng lan nhanh và trở nên cực đoan khi có biến cố xảy đến với các doanh nghiệp hay tổ chức chính trị. Vì vậy, khuôn mẫu quản lý trong kỷ nguyên phẫn nộ này phải thay đổi, nếu các lãnh đạo không muốn mọi thứ vượt khỏi tầm kiểm soát. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD50', 'Đừng Chỉ Là Hi Vọng ', '
XIONG LI FAN ', 'NXB Tri Thức', 2007,
'Cuộc sống của rất nhiều người trong chúng ta chỉ như một chiếc đồng hồ đơn điệu lặp mãi một vòng quay. Họ đi làm, tan làm đúng giờ, ăn những món ăn hàng ngày hay ăn, đi qua những con đường quen thuộc. Kinh nghiệm sống mấy chục năm của họ chẳng qua chỉ là mấy chục lần kinh nghiệm của một năm. Điều này không phải là việc xấu, tuy nhiên, cuộc sống đơn điệu này sẽ cản trở tâm hồn, bóp chết khả năng tưởng tượng và sáng tạo của bạn.Bạn đang sống bình thường hay tầm thường?

Hiện tại nhiều bạn trẻ chấp nhận cuộc sống bình thường, an nhàn. Tức là làm công việc hành chính một màu, đến tuổi thì lập gia đình, sinh con, cả đời chỉ là vòng lặp những công việc tẻ nhạt…

Tuy nhiên, đến với quan điểm của cuốn sách “Đừng chỉ là hy vọng”, bạn nhận ra cuộc sống không chỉ là chuỗi tuần hoàn vô tận như vậy. “Trăm hay không bằng tay quen” tuy là việc tốt, nhưng thử nghĩ xem, nếu đầu tư nhiệt huyết và sự kiên trì tương tự vào việc rèn luyện khả năng sáng tạo, vậy thì bạn sẽ giành được thành tựu to lớn nhường nào?

Như Dale Carnegie đã nói: “Hãy mạo hiểm đi! Đời người vốn là một cuộc thám hiểm, người có thành tựu chính là người dám thử sức. Con thuyền chỉ muốn an toàn sẽ chẳng bao giờ rời cảng được”.

Sáng tạo là chìa khóa thành công

Thành công là việc đạt được sự thỏa mãn cả về đời sống vật chất và tinh thần. Xét về mặt vật chất, từ trước đến nay, người ta luôn đề cao những công việc tri thức hơn lao động chân tay, bạn cống hiến càng nhiều chất xám thì mới tạo ra càng nhiều giá trị. Mà bản chất của chất xám đó là sự sáng tạo, sự thay đổi không ngừng, việc tìm ra cái mà người khác chưa từng nghĩ đến.

Về mặt tinh thần, sáng tạo không ngừng giúp bạn mở rộng tư duy, khiến bạn cảm thấy thỏa mãn với những thành tựu mình tạo ra. Từ đó cuộc sống trở nên đáng sống và có ý nghĩa hơn.

Nhà văn Lý Thượng Long có viết trong Vươn lên hoặc bị đánh bại như sau: “ Thật ra, trong những năm tháng còn trẻ, nếu chúng ta không chọn trở nên nổi bật, thì sẽ phải hối tiếc về sau”. Sáng tạo chính là nhân tố cốt yếu giúp các bạn khác biệt và nổi bật so với những người xung quanh.

Dũng cảm đối mặt với vấp ngã

Phần đông nhiều người trẻ lựa chọn cuộc sống “chậm”, sống quá an toàn, bởi lẽ họ sợ thất bại, sợ vấp ngã. Trải qua cơn đau rồi, người ta thường sợ ngã xuống hố một lần nữa, nên lựa chọn cả đời đứng yên tại chỗ. Đây là một quan điểm sai lầm nghiêm trọng. Có ai trong đời không gặp phải khó khăn, vấp ngã; tuy nhiên mỗi lần vấp ngã là một lần trưởng thành. Vượt qua vấp ngã, chấp nhận tư duy mới hơn, sống một cuộc đời nhiều thử thách bản thân mới học hỏi được nhiều kinh nghiệm, mới lĩnh hội được nhiều trải nghiệm.

“Cần phải cho bản thân một cơ hội thành công, đừng dễ dàng từ bỏ, bời vì thành công chính là: nếu bạn không cố gắng tranh đấu thì không thể có được nó.” ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD51', 'Đọc Vị Bất Kỳ Ai - Để Không Bị Lừa Dối Và Lợi Dụng ', '
TS. David J. Lieberman ', 'NXB Tri Thức', 2007,
'Bạn băn khoăn không biết người ngồi đối diện đang nghĩ gì? Họ có đang nói dối bạn không? Đối tác đang ngồi đối diện với bạn trên bàn đàm phán đang nghĩ gì và nói gì tiếp theo?

ĐỌC người khác là một trong những công cụ quan trọng, có giá trị nhất, giúp ích cho bạn trong mọi khía cạnh của cuộc sống. ĐỌC VỊ người khác để:

Hãy chiếm thế thượng phong trong việc chủ động nhận biết điều cần tìm kiếm - ở bất kỳ ai bằng cách “thâm nhập vào suy nghĩ” của người khác. ĐỌC VỊ BẤT KỲ AI là cẩm nang dạy bạn cách thâm nhập vào tâm trí của người khác để biết điều người ta đang nghĩ. Cuốn sách này sẽ không giúp bạn rút ra các kết luận chung về một ai đó dựa vào cảm tính hay sự võ đoán. Những nguyên tắc được chia sẻ trong cuốn sách này không đơn thuần là những lý thuyết hay mẹo vặt chỉ đúng trong một số trường hợp hoặc với những đối tượng nhất định. Các kết quả nghiên cứu trong cuốn sách này được đưa ra dựa trên phương pháp S.N.A.P - cách thức phân tích và tìm hiểu tính cách một cách bài bản trong phạm vi cho phép mà không làm mếch lòng đối tượng được phân tích. Phương pháp này dựa trên những phân tích về tâm lý, chứ không chỉ đơn thuần dựa trên ngôn ngữ cử chỉ, trực giác hay võ đoán.

Cuốn sách được chia làm hai phần và 15 chương:

Phần 1: Bảy câu hỏi cơ bản: Học cách phát hiện ra điều người khác nghĩ hay cảm nhận một cách dễ dàng và nhanh chóng trong bất kỳ hoàn cảnh nào.
Phần 2: Những kế hoạch chi tiết cho hoạt động trí óc - hiểu được quá trình ra quyết định. Vượt ra ngoài việc đọc các suy nghĩ và cảm giác đơn thuần: Hãy học cách người khác suy nghĩ để có thể nắm bắt bất kỳ ai, phán đoán hành xử và hiểu được họ còn hơn chính bản thân họ. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD52', 'Cách Bật Về Phía Trước ', '
Sam Cawthorn ', 'NXB Tri Thức', 2007,
'Khi mới 26 tuổi Sam Cawthorn đã gặp phải một tai nạn giao thông nghiêm trọng khiến anh mất đi cánh tay phải và các bác sĩ bảo rằng anh không thể đi lại được.

Trong khoảnh khắc nguy kịch ấy anh nhận ra rằng mình có một cơ hội phi thường để tạo ra một cuộc sống tốt đẹp hơn.

Trải nghiệm của anh giúp anh khám phá ra các cơ chế, công cụ và chiến lược nhằm không chỉ phục hồi, mà còn tiến lên phía trước, sống một cuộc đời tuyệt vời hơn với những mối quan tâm lớn hơn và những thành công lớn hơn.Cách bật về phía trước cung cấp cho bạn những công cụ cần thiết để vượt qua khủng hoảng và thậm chí sử dụng khủng hoảng làm bàn đạp để thay đổi cuộc đời.

“Trong cuốn sách hấp dẫn này, Sam Cawthorn chia sẻ những bài học cuộc sống quan trọng, được đúc kết từ trải nghiệm phi thường của anh khi vượt qua nghịch cảnh. Thông điệp tràn đầy cảm hứng của Sam, được truyền tải qua sự rõ rang, cuốn hút và hài hước đặc trưng trong tính cách của anh, sẽ tiếp sức mạnh cho bạn vượt qua trở ngại và tận hưởng niềm vui sống mỗi ngày”. - Michael J. Gelb Tác giả cuốn sách How to Think Life Leonardo da Vinci (Tạm dịch: Cách tư duy như Leonado da Vinci) ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD53', 'Năng Suất Nhanh Và Chậm ', '
Cal Newport ', 'NXB Tri Thức', 2007,
'Trong thời đại mà “bận rộn” và “đa nhiệm” là biểu tượng cho năng suất, chúng ta dường như đang sống trong một nền văn hóa luôn thúc giục phải làm nhiều hơn, nhanh hơn. Thế nhưng, chính trong guồng quay tưởng chừng hiệu quả đó, ngày càng nhiều người rơi vào tình trạng kiệt sức, mất kết nối với công việc, thậm chí là mất định hướng trong cuộc sống.

Năng suất nhanh và chậm - tác phẩm mới nhất của Cal Newport (tác giả của những đầu sách bestseller) - hướng dẫn người đọc cách thiết kế lại lịch trình cá nhân, quản lý kỳ vọng từ cấp trên, tổ chức dự án sao cho không bị quá tải và quan trọng nhất là dành chỗ cho những “khoảng lặng” - nơi ta thực sự kết nối với công việc lẫn chính mình. Việc để bản thân “không làm gì” trong một thời gian nhất định không phải là lười biếng, mà là cách để duy trì khả năng làm việc sâu và sống sâu.

3 nguyên lý của “năng suất chậm”:

Làm ít việc hơn: Chúng ta cần biết sắp xếp thứ tự ưu tiên cho công việc, tập trung vào những nhiệm vụ thực sự quan trọng thay vì liên tục gánh thêm các đầu việc mới.
Làm việc với nhịp độ bền vững: Thay vì chạy nước rút liên tục đến kiệt sức, tác giả Cal Newport khuyến khích mỗi người tìm một nhịp làm việc phù hợp với năng lượng tự nhiên của bản thân.
Tạo giá trị cao: Thành tựu không đo bằng số lượng công việc hoàn thành, mà bằng chiều sâu và ý nghĩa thực sự của mỗi thành quả. Việc bạn biết ưu tiên chất lượng thay vì tốc độ sẽ là bước tiến vững chắc, giúp bạn bứt phá trong sự nghiệp lẫn đời sống.
Xuyên suốt cuốn sách này, tác giả Cal Newport nhấn mạnh thông điệp: Thành công không nhất thiết đến từ việc làm thật nhiều, thật nhanh. Trong một thế giới quá tải thông tin, nơi công nghệ khiến ta luôn “trực tuyến”, luôn phản hồi, luôn cập nhật, thì chính việc chậm lại, làm việc với chiều sâu và chú tâm mới là lối đi giúp ta không bị lạc lối.

“Năng suất Nhanh và Chậm” không chỉ dành cho những ai đang trong tình trạng kiệt sức vì công việc, mà còn dành cho bất kỳ ai đang tìm kiếm một cách làm việc có chiều sâu, có ý nghĩa và đặc biệt: không phải trả giá bằng sức khỏe hay sự tự do cá nhân. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD54', 'Trí Tuệ Tài Chính Dành Cho Nhà Quản Lý Không Chuyên Về Tài Chính ', '
Karen Berman, Joe Knight ', 'NXB Tri Thức', 2007,
'Là một nhà quản lý nhân sự, bạn phải sử dụng dữ liệu tài chính để đưa ra quyết định, phân bổ nguồn lực và lập ngân sách chi phí. Nhưng nếu giống như nhiều người làm ở vị trí này, bạn có thể cảm thấy không chắc chắn khi kết hợp tính toán tài chính vào công việc hằng ngày của mình. Và đây là lúc bạn cần đến Trí tuệ tài chính dành cho nhà quản lý nhân sự. Ba tác giả đã trình bày tất tần tật những hiểu biết cần thiết về tài chính dành riêng cho các chuyên gia nhân sự trong cuốn sách này.

Bạn sẽ khám phá ra:

Lý do các giả định đằng sau dữ liệu tài chính lại quan trọng
Những điều báo cáo thu nhập, bảng cân đối kế toán và báo các lưu chuyển tiền tệ tiết lộ
Những nguồn tài chính cần thiết khi bạn phát triển chiến lược vốn nhân lực - Cách tính lợi tức đầu tư
Cách sử dụng thông tin tài chính đễ hỗ trợ tốt hơn cho các đơn vị kinh doanh và thực hiện công việc của mình
Cách truyền tải thông tin tài chính trong đội ngũ của bạn.
Trích đoạn sách Trí Tuệ Tài Chính Dành Cho Nhà Quản Lý Không Chuyên Về Tài Chính
1. Như tất cả những môn học quản trị kinh doanh khác, kế toán và tài chính thực sự cũng mang tính nghệ thuật không kém tính khoa học. Bạn có lẽ sẽ gọi đây là bí mật giấu kín của CFO hay của kiểm soát viên – ngoại trừ việc nó chẳng phải là bí mật; nó là một sự thật mà những người trong ngành tài chính đều biết.

2. Một vài sai lầm đắt giá mà người ta phạm phải trong kinh doanh liên quan đến việc tuyển dụng hoặc giảm biên chế nhân viên. Chắc hẳn bạn sẽ muốn hiểu cách các chi phí được phân bổ trước khi đưa ra những quyết định quản lý nhân sự quan trọng.

3. Các chuyên gia quản lý nhân sự đôi khi – thậm chí nhiều lần – bị mang tiếng xấu. Đáng buồn thay, họ bị cho rằng chỉ tập trung vào khía cạnh “mềm” của doanh nghiệp hơn là vào khía cạnh những số liệu “cứng”. Đó là một bất công vì những con số cuối cùng phụ thuộc vào con người và nhân sự là bộ phận chịu trách nhiệm nhiều nhất đối với các vấn đề về con người trong một công ty.

4. Nghệ thuật tài chính có thể dễ dàng được gọi là nghệ thuật tạo ra lợi nhuận, hoặc trong một số trường hợp, nghệ thuật này tạo ra lợi nhuận trông tốt hơn so với thực tế.

5. Bất kỳ báo cáo thu nhập nào đều bắt đầu với doanh số. Khi một doanh nghiệp bàn giao sản phẩm hoặc dịch vụ cho khách hàng, kế toán viên nói rằng công ty đã thực hiện việc bán hàng. Đừng bận tâm nếu khách hàng chưa thanh toán cho sản phẩm hoặc dịch vụ đã bàn giao, doanh nghiệp có thể tính số tiền bán hàng trên dòng trên cùng của báo cáo thu nhập của mình trong khoảng thời gian được đề cập.

6. Hầu hết các báo cáo thu nhập là “thực tế” và nếu không có tiêu đề khác, bạn có thể cho rằng đó là những gì bạn đang tìm kiếm. Chúng cho thấy những gì “thực sự” đã diễn ra với doanh thu, chi phí và lợi nhuận trong khoảng thời gian đó theo các quy tắc kế toán.

7. Người làm công tác quản lý nhân sự nên hiểu chi phí của doanh nghiệp và ý nghĩa của chúng để hỗ trợ sản xuất, công nghệ thông tin, marketing,… Trong các doanh nghiệp sử dụng nhiều vốn như các công ty dầu mỏ, lương và phúc lợi chiếm một tỷ lệ nhỏ trong tổng chi phí, và vì vậy các quyết định của nhân sự về lương thưởng có thể không ảnh hưởng lớn đến lợi nhuận ròng.

8. Lợi nhuận hoạt động cho nhân viên biết nhiều thông tin. Lợi nhuận hoạt động tốt và tăng trưởng cho thấy nhân viên sẽ có thể giữ được công việc của họ và có cơ hội thăng tiến. Bộ phận nhân sự có thể cần phải chuyển trọng tâm sang phát triển nhân viên, tuyển dụng, Lợi nhuận hoạt động giảm sẽ đòi hỏi một sự tập trung khác. Dù thế nào đi nữa, bộ phận nhân sự có thể là đối tác đúng lúc trong tổ chức nếu họ chú ý đến các con số và hiểu được ý nghĩa của chúng. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD55', 'Thay Đổi Để Thành Công - Đánh Thức Sức Mạnh Tiềm Thức Trong Con Người Của Bạn ', '
Maxwell Maltz ', 'NXB Tri Thức', 2007,
'Cuốn sách đã thay đổi cuộc đời của hơn 30 triệu người khai thác năng lực của tiềm thức để:

Hoàn thiện bản thân.
Học cách sử dụng quá khứ tích cực.
Đặt ra và hoàn thành những mục tiêu xứng đáng.
Để cảm thông, tự trọng và tha thứ.
Trau dồi năng lực suy nghĩ duy lý.
Khám phá bí quyết cùa cuộc sống hạnh phúc và thành công
Bạn sẽ thấy được sự khác biệt đó khi đọc Thay Đổi Để Thành Công - Đánh Thức Sức Mạnh Tiềm Thức Trong Con Người Của Bạn viết bởi Maxwell Maltz, một tác gia trứ danh đồng thời là một Tiến sĩ y khoa nổi tiếng. Cuốn sách được nhận định là một tác phẩm kinh điển của dòng sách self-help. Kể từ lần đầu ra mắt vào năm 1960, hơn 35 triệu bản cùa Thay Đổi Để Thành Công đã được bán ra trên toàn thế giới. Giá trị của cuốn sách được khẳng định khi độc giả thuộc mọi tầng lớp trong xã hội của Thay Đổi Để Thành Công đã gặt hái được những thành công hơn bao giờ hết. Cuốn sách cũng góp phần làm thay đổi ngành công nghiệp xuất bản sách self-help.

Thành công trong cuộc sống là điều mà ai cũng muốn hướng tới, một tư duy và thái độ tiêu cực sẽ đẩy thành công ra xa khỏi tầm tay của bạn và ngược lại thói quen, niềm đam mê, sự linh hoạt và thái độ ứng xử của mỗi người sẽ quyết định độ thành công của mỗi người. Dưới đây là những ý tưởng chính trong cuốn sách "Thay Đổi Để Thành Công - Đánh Thức Sức Mạnh Tiềm Thức Trong Con Người Của Bạn" giúp các bạn có những ý tưởng mới để thay đổi tư duy, trở nên thành công và hạnh phúc hơn.

Những ý tưởng giúp bạn thay đổi để thành công

Ý tưởng 1: Nhận thức về bản thân
Hầu hết mọi người đều có nhận thức tiêu cực về bản thân mình. Từ khi còn nhỏ chúng ta đã chịu những ảnh hưởng tiêu cực từ môi trường bên ngoài, qua thời gian điều đó đã làm chúng ta có suy nghĩ tiêu cực về bản thân mình. Những suy nghĩ đó đã vô tình tạo ra những rào cản xung quanh chúng ta cho đến suốt cuộc đời nếu chúng ta không thay đổi nó. Điều đó đã ngăn cản chúng ta thực hiện ước mơ của mình, ngăn cản chúng ta sống cuộc sống mà chúng ta mong muốn.

=> Những nhận thức tiêu cực, những giới hạn bạn tự đặt ra là hoàn toàn không có thật và để thành công thì bạn phải thay đổi nhận thức về bản thân mình, xóa bỏ đi những rào cản do chính bạn đặt ra.

Ý tưởng 2: Tiềm thức
Bộ não của chúng ta hoạt động gồm: 20% suy nghĩ logic + 80% tiềm thức. Tiềm thức quyết định chính đến hành động và từ đó tạo ra kết quả chúng ta đang có. Nếu bạn không thay những nguyên nhân từ sâu trong tiềm thức của mình thì sẽ không thay đổi được kết quả bạn đang có.

=> Để thay đổi những kết quả ở bên ngoài bạn phải thay đổi những nguyên nhân từ sâu trong tiềm thức của mình.

Ý tưởng 3: Bản năng để thành công
Mỗi người sinh ra đều đã có sẵn bản năng để thành công. Hãy nhớ rằng trước khi thành công thì thất bại chắc chắn sẽ xảy ra nhưng điều quan trọng là thay vì để ý đến những lần thất bại bạn phải học cách tập trung vào làm sao để có thể thành công.

Cuốn sách “Thay Đổi Để Thành Công - Đánh Thức Sức Mạnh Tiềm Thức Trong Con Người Của Bạn” được nhận định là một tác phẩm kinh điển của dòng sách self-help. Kể từ lần đầu tiên ra mắt vào năm 1960, hơn 35 triệu bản đã được bán ra trên toàn thế giới. Giá trị của cuốn sách được khẳng định khi hàng triệu độc giả thuộc mọi tầng lớp trong xã hội thay đổi cuộc đời của họ. Cuốn sách sẽ giúp bạn khai thác năng lực của tiềm thức để:

Hoàn thiện bản thân
Học cách sử dụng quá khứ tích cực
Đặt ra và hoàn thành những mục tiêu xứng đáng
Để cảm thông, tự trọng và tha thứ
Trau dồi năng lực suy nghĩKhám phá bí quyết của cuộc sống hạnh phúc và thành công
Những thói quen tốt cùng với sự linh hoạt trong cuộc sống đưa bạn đến gần hơn với sự thành công. Thành công là một sự linh động có cơ chế điều khiển theo cách riêng của nó. Việc phát triển các tư duy như một la bàn giúp bạn không ngừng định hướng trên con đường kinh doanh và thực hiện mục tiêu tài chính. Những tư duy này cho phép bạn cởi mở, linh hoạt và định hướng chính xác hơn trong cuộc sống. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD56', 'Sống Sót Nơi Công Sở ', '
Juliana Jiyoon Lee ', 'NXB Tri Thức', 2007,
'Khả năng sử dụng tiếng Anh đang dần trở thành một yêu cầu bắt buộc đối với các nhân viên văn phòng. Không ít người dù đã có thời gian học tiếng Anh khá lâu và có trong tay vài loại chứng chỉ quốc tế nhưng vẫn cảm thấy khó khăn khi cần sử dụng ngôn ngữ này vào các tình huống công việc cụ thể. Sống Sót Nơi Công Sở - English Business Conversation - Nói Sao Cho Ngầu sẽ giúp bạn từng bước loại bỏ những trở ngại đó và tự tin lên tiếng thể hiện mình để đạt được thành công trong công việc.

“Đừng chỉ tiếp cận tiếng Anh như một ngôn ngữ mà hãy coi nó là công cụ để giao tiếp trong công việc và trong cuộc sống hằng ngày. Năng lực giao tiếp tiếng Anh lúc này chính là khả năng trình bày nhanh chóng, hiệu quả các nội dung cần truyền đạt bằng những mẫu câu chính xác và ngắn gọn.” Đó chính là tiêu chí mà tác giả đã hướng tới khi xây dựng cuốn sách này. Theo đó, người học sẽ được làm quen với những mẫu câu tiếng Anh hữu dụng theo 5 tình huống giao tiếp thường gặp trong công việc gồm: gọi điện thoại, hội họp, đàm phán, đi công tác và tiếp khách. Ngoài ra, phần II của cuốn sách còn cung cấp 1.700 cấu trúc câu chia theo 35 chủ đề thường gặp như chào hỏi, gặp đối tác, họp bàn, thương thảo, tán gẫu, đi công tác… Nhờ đó, bạn có thể dễ dàng tra cứu và áp dụng ngay những mẫu câu này trong các tình huống thực tế mà mình gặp phải trong quá trình làm việc.

Ưu điểm nổi bật của cuốn sách Sống Sót Nơi Công Sở - English Business Conversation - Nói Sao Cho Ngầu
Cấu trúc câu đa dạng và có tính ứng dụng cao: Không chỉ phân loại theo tình huống phổ biến, mỗi bài học đều chia nội dung theo trình tự của sự việc và các khả năng có thể xảy ra đối với từng tình huống. Chẳng hạn, với chủ đề hội họp, bạn sẽ được làm quen với các mẫu câu có thể sử dụng khi bắt đầu cuộc họp, giới thiệu thành phần tham dự, đề cập về nội dung bàn thảo, đồng tình/phản đối, xin biểu quyết, tiến hành hỏi đáp, kết luận cuối cuộc họp…
Cấu trúc bài học khoa học, kết hợp nhuần nhuyễn giữa học và thực hành giúp người học hiểu và biết cách áp dụng kiến thức tốt hơn. Mỗi bài học đều được triển khai theo ba bước: Học các câu mẫu theo tình huống à Đặt câu theo các câu mẫu đã học à Áp dụng vào hội thoại.
Cung cấp cho người học những mẹo hữu ích để có thể sử dụng ngôn ngữ phù hợp và chuẩn xác, đồng thời độc giả cũng được biết thêm những mẹo hay có thể áp dụng trong công việc của mình.
Tập hợp 1700 cấu trúc câu chia theo 35 chủ đề ở phần II của sách rất phù hợp với những người bận rộn nhưng vẫn có nhu cầu học và sử dụng tiếng Anh trong công việc. Với mỗi tình huống thực tế cần dùng đến tiếng Anh, bạn có thể nhanh chóng tìm được mẫu câu mình cần để có thể áp dụng “nhanh gọn lẹ” vào hoàn cảnh, nhờ đó mà khả năng sử dụng tiếng Anh của bạn sẽ liên tục được cải thiện đáng kể. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD57', 'Tổ Chức Công Việc Làm Ăn - Kim Chỉ Nam Của Nhà Doanh Nghiệp ', '
Nguyễn Hiến Lê ', 'NXB Tri Thức', 2007,
'Cuốn sách sẽ giúp những nhà kinh doanh sửa đổi cách thức làm việc của mình mà tăng năng suất lên gấp hai, gấp ba lần, ngay đối với những người không kinh doanh như công chức, nó cũng không phải là vô dụng vì nó tập cho ta tinh thần biết suy nghĩ, phân tích, tổ chức, cải thiện; mà chính tinh thần đó mới là quan trọng nhất trong bất kì phạm vi hoạt động nào, chứ chẳng phải chỉ riêng trong các xí nghiệp; chính nhờ tinh thần đó mà các quốc gia chậm tiến như nước ta có thể vượt lên  được mà theo kịp các quốc gia tiên tiến.

Sách gồm 10 chương:

Chương 1: Hai học thuyết Fayol và Taylor.
Chương 2: Tổ chức một xí nghiệp.
Chương 3: Bạn hãy tổ chức bạn trước đã.
Chương 4: Công  việc quản lí.
Chương 5: Công việc tài chánh.
Chương 6: Công việc kế toán.
Chương 7: Công việc kĩ thuật.
Chương 8: Công việc thương mại.
Chương 9: Công việc an ninh và xã hội.
Chương 10: Tổ chức lại một xí nghiệp. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD58', 'Cuộc Chiến Kim Loại Hiếm - Mặt Tối Của Chuyển Đổi Số Và Năng Lượng Sạch ', '
Guillaume Pitron ', 'NXB Tri Thức', 2007,
'“Cuộc chiến kim loại hiếm” - Một tác phẩm điều tra sâu sắc, đưa ra góc nhìn khác biệt về mặt trái của cuộc cách mạng công nghệ xanh và số hóa.

Cuốn sách được viết bởi Guillaume Pitron - một nhà báo, đạo diễn phim tài liệu và tác giả người Pháp, chuyên nghiên cứu về tài nguyên thiên nhiên, công nghệ và địa chính trị, dựa trên nghiên cứu kéo dài sáu năm tại hơn một chục quốc gia.

Trong cuốn sách, Guillaume Pitron đã đặt ra mạnh mẽ những vấn đề sống còn về địa chính trị tài nguyên trong thế kỷ 21. Khi kim loại hiếm trở thành tài nguyên chiến lược, các cường quốc như Mỹ và châu Âu đang nỗ lực giảm phụ thuộc vào Trung Quốc bằng cách tái thiết năng lực khai thác và tinh chế trong nước. Cuộc cạnh tranh này không chỉ làm thay đổi quan hệ quốc tế mà còn định hình lại bản đồ quyền lực toàn cầu.

Đáng chú ý, kim loại hiếm đã trở thành một quân bài chiến lược của Trung Quốc trong chiến tranh thương mại với Mỹ. Bắc Kinh từng nhiều lần để ngỏ khả năng hạn chế xuất khẩu kim loại hiếm như một đòn phản công nhắm vào các ngành công nghệ cao của Mỹ.

Ngay sau khi xuất bản, cuốn sách nhanh chóng trở thành tài liệu không thể thiếu trong các cuộc thảo luận về tài nguyên, công nghệ và phát triển bền vững. Nhận được nhiều đánh giá tích cực trên các nền tảng như Goodreads (4.2/5) và Amazon (4.5/5). Tác phẩm cũng đồng thời gợi ra những câu hỏi gai góc: Liệu cách mạng xanh có thật sự xanh? Có phải chúng ta đang thay một dạng ô nhiễm bằng một dạng ô nhiễm khác? Và ai sẽ kiểm soát những tài nguyên chiến lược của tương lai?

Không chỉ mang tính phân tích sắc bén, cuốn sách còn là lời cảnh tỉnh về một cuộc đua âm thầm nhưng quyết liệt - nơi kim loại hiếm không còn là thứ nằm sâu dưới lòng đất, mà là yếu tố định hình cán cân quyền lực toàn cầu.

Bố cục sách bao gồm:

Lời nguyền kim loại hiếm
Góc khuất của các công nghệ xanh và kỹ thuật số
Dịch chuyển ô nhiễm
Phương Tây trong thời kỳ bị cấm vận
Thâu tóm công nghệ cao
Ngày Trung Quốc vượt qua phương Tây
Chạy đua tên lửa thông minh
Mở rộng các khu mỏ
Ngày tàn của những vùng đất thiêng cuối cùng
Bìa sách sử dụng tông màu đỏ và đen với hình ảnh của một tua-bin gió hiện lên "mặt tối" của năng lượng sạch và công nghệ số. Hình ảnh tương phản phía dưới là hình bóng của các công nhân khai thác thể hiện cái giá phải trả của công nghệ xanh, nhấn mạnh thông điệp rằng công nghệ xanh không hoàn toàn "sạch" như chúng ta nghĩ.

Cuốn sách dành cho các bạn độc giả yêu thích sách phi hư cấu điều tra, quan tâm đến các vấn đề xã hội, công lý toàn cầu môi trường và phát triển bền vững. Đây cũng là tư liệu dành cho các chuyên gia và nhà nghiên cứu trong lĩnh vực công nghệ và năng lượng, những người quan tâm đến địa chính trị và kinh tế toàn cầu, những doanh nhân và nhà đầu tư trong ngành công nghệ và tài nguyên. Và các bạn sinh viên đang học tập trong lĩnh vực liên quan. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400),
('GD59', 'Tư Duy Dã Tràng - Tim Trí Giao Tranh ', '
Phan Văn Trường ', 'NXB Tri Thức', 2007,
'"Dã tràng xe cát biển Đông
Nhọc lòng mà chẳng nên công cán gì"

Dã tràng luôn bận rộn. Dã tràng có mục tiêu to lớn. Dã tràng nỗ lực vô cùng. Dã tràng vô cùng chuyên tâm. Nhưng tại sao rốt cuộc "chẳng nên công cán gì?"

Chắc hẳn phải có một lý do nào đó để cá nhân này có cuộc đời mạch lạc và bình thản hơn cá nhân khác có hoàn cảnh tương đương, cho dù trải qua biến động gì. Mọi điều xảy đến từ ngoại cảnh đều được lý giải ở bên trong chúng ta. Vậy "bên trong" chúng ta sáng rõ, ngăn nắp thì cách đối xử với cái bên ngoài cũng sẽ kiên định, tỉnh thức như vậy, cho dù giữa cơn bão tố.

Đây là một quyển sách về Tư duy hệ thống và phương pháp lập luận.

Với nhiều ví dụ dễ hiểu và lời văn chân tình, thấu đáo, tác phẩm mới nhất của tác giả Phan Văn Trường là cẩm nang thiết thực của bạn đọc muốn tránh khỏi những bẫy ngụy biện và nhiều điều làm cản trở một cuộc đời vươn hết tiềm năng.

Cuốn sách là viên gạch nối chúng ta với nhau, với xã hội chung quanh, với môi trường toàn cầu, tạo nên một thói quen mà chúng ta đã mất đi hoặc chưa bao giờ có: đó là khả năng lập luận, khả năng minh hoạ, chứng minh, ẩn dụ, suy luận... Chúng ta cần lý trí hoá trở lại những điều chúng ta thường vô tư nhận định mà không dựa vào một nền tảng căn cơ nào, ngoài việc nhân danh trực giác thuần tuý, hoặc tâm linh. Sách sẽ mang hai khía cạnh tưởng như tách bạch hoàn toàn, nhưng thật ra lại bổ sung cho nhau: đó là tư duy hệ thống và những phương pháp suy luận. Cả hai đều cần sử dụng trí tuệ, cả hai đều hiểu vai trò quan trọng của trực giác, nhưng cả hai sẽ cần huy động khả năng trí tuệ liên quan đến lập luận duy lý vô cùng cần thiết. ', 848000, 1000, 'img74.jpg', 'C09',1,200000,400);

-- ================================
-- ORDERS
-- ================================
USE bookdb;
DELETE FROM orders WHERE orderId IN ('OD01','OD02','OD03','OD04','OD05','OD06','OD07','OD08','OD09','OD10');

INSERT INTO orders
(orderId, paymentMethod, orderDate, totalAmount, shipping_fee, address, note, status, customerId, shipping_address_id)
VALUES
('OD01', 'COD',     '2026-04-01 09:15:00', 429780.00, 30000.00, 'Gia Lai',            'Giao giờ hành chính',    'Completed',  'CU01', NULL),
('OD02', 'BANKING', '2026-04-01 14:20:00', 320790.00, 25000.00, 'Bình Phước',         'Gọi trước khi giao',     'Completed',  'CU02', NULL),
('OD03', 'MOMO',    '2026-04-02 10:05:00', 376970.00, 30000.00, 'Khánh Hòa',          'Ship nhanh giúp em',     'Processing', 'CU03', NULL),
('OD04', 'COD',     '2026-04-02 16:45:00', 294200.00, 30000.00, 'Đồng Tháp',          'Không giao buổi trưa',   'Completed',  'CU04', NULL),
('OD05', 'BANKING', '2026-04-03 08:30:00', 537300.00, 35000.00, 'TP. HCM',            'Gói hàng cẩn thận',      'Shipped',    'CU05', NULL),
('OD06', 'COD',     '2026-04-03 13:10:00', 235200.00, 25000.00, 'Bà Rịa - Vũng Tàu',  'Giao sau 5h chiều',      'Completed',  'CU06', NULL),
('OD07', 'MOMO',    '2026-04-04 11:25:00', 463000.00, 30000.00, 'Đồng Nai',           'Liên hệ qua điện thoại', 'Completed',  'CU07', NULL),
('OD08', 'BANKING', '2026-04-04 19:40:00', 282150.00, 30000.00, 'Bà Rịa - Vũng Tàu',  'Để ở quầy bảo vệ',       'Processing', 'CU08', NULL),
('OD09', 'COD',     '2026-04-05 09:00:00', 230999.00, 25000.00, 'Bến Tre',            'Giao sáng',              'Completed',  'CU09', NULL),
('OD10', 'MOMO',    '2026-04-05 15:55:00', 374150.00, 30000.00, 'Bình Thuận',         'Không gọi sau 9h tối',   'Cancelled',  'CU10', NULL);
INSERT INTO orders
(orderId, paymentMethod, orderDate, totalAmount, shipping_fee, address, note, status, customerId, shipping_address_id)
VALUES
('OD11', 'COD',     '2026-04-06 09:10:00', 329300.00, 30000.00, 'Gia Lai',        'Giao nhanh',           'Completed',  'CU11', NULL),
('OD12', 'MOMO',    '2026-04-06 14:20:00', 280000.00, 25000.00, 'Đăk Nông',       'Gọi trước',            'Completed',  'CU12', NULL),
('OD13', 'BANKING', '2026-04-07 10:00:00', 365200.00, 30000.00, 'Gia Lai',        'Không giao tối',       'Shipped',    'CU13', NULL),
('OD14', 'COD',     '2026-04-07 16:30:00', 251200.00, 30000.00, 'TP. HCM',        'Để trước cửa',         'Completed',  'CU14', NULL),
('OD15', 'MOMO',    '2026-04-08 08:45:00', 410000.00, 35000.00, 'Đà Nẵng',        'Ship sáng',            'Processing', 'CU15', NULL),
('OD16', 'BANKING', '2026-04-08 13:15:00', 298150.00, 25000.00, 'Tiền Giang',     'Liên hệ trước',        'Completed',  'CU16', NULL),
('OD17', 'COD',     '2026-04-09 11:00:00', 367000.00, 30000.00, 'Bến Tre',        'Ship thường',          'Completed',  'CU17', NULL),
('OD18', 'MOMO',    '2026-04-09 17:25:00', 305200.00, 30000.00, 'Bến Tre',        'Không gọi trưa',       'Completed',  'CU18', NULL),
('OD19', 'BANKING', '2026-04-10 09:40:00', 290000.00, 25000.00, 'Nghệ An',        'Giao giờ hành chính',  'Shipped',    'CU19', NULL),
('OD20', 'COD',     '2026-04-10 15:10:00', 412000.00, 30000.00, 'Bến Tre',        'Giao trước 18h',       'Completed',  'CU20', NULL);
INSERT INTO orders
(orderId, paymentMethod, orderDate, totalAmount, shipping_fee, address, note, status, customerId, shipping_address_id)
VALUES
('OD21', 'COD',     '2026-04-11 08:20:00', 314200.00, 25000.00, 'Bến Tre',       'Giao buổi sáng',        'Completed',  'CU21', NULL),
('OD22', 'MOMO',    '2026-04-11 10:45:00', 358170.00, 30000.00, 'Bình Thuận',    'Gọi trước khi giao',    'Completed',  'CU22', NULL),
('OD23', 'BANKING', '2026-04-11 14:10:00', 287650.00, 25000.00, 'Kiên Giang',    'Không giao giờ nghỉ',   'Shipped',    'CU23', NULL),
('OD24', 'COD',     '2026-04-11 17:30:00', 402300.00, 30000.00, 'TP. HCM',       'Để bảo vệ nhận',        'Processing', 'CU24', NULL),
('OD25', 'MOMO',    '2026-04-12 09:00:00', 246250.00, 25000.00, 'Đăk Nông',      'Giao trong ngày',       'Completed',  'CU25', NULL),
('OD26', 'BANKING', '2026-04-12 11:40:00', 333200.00, 30000.00, 'TP. HCM',       'Bọc chống sốc',         'Completed',  'CU26', NULL),
('OD27', 'COD',     '2026-04-12 15:15:00', 291150.00, 25000.00, 'TP. HCM',       'Giao trước 5h',         'Completed',  'CU27', NULL),
('OD28', 'MOMO',    '2026-04-12 19:05:00', 425300.00, 35000.00, 'Bà Rịa - Vũng Tàu', 'Ship nhanh giúp em', 'Shipped',    'CU28', NULL),
('OD29', 'BANKING', '2026-04-13 08:50:00', 301200.00, 30000.00, 'Ninh Thuận',    'Liên hệ điện thoại',    'Completed',  'CU29', NULL),
('OD30', 'COD',     '2026-04-13 13:25:00', 389000.00, 30000.00, 'Gia Lai',       'Giao giờ hành chính',   'Cancelled',  'CU30', NULL);
INSERT INTO orders
(orderId, paymentMethod, orderDate, totalAmount, shipping_fee, address, note, status, customerId, shipping_address_id)
VALUES
('OD31', 'COD',     '2026-04-13 15:10:00', 325000.00, 25000.00, 'TP. HCM',            'Giao trong ngày',        'Completed',  'CU31', NULL),
('OD32', 'MOMO',    '2026-04-13 16:25:00', 412300.00, 30000.00, 'Kiên Giang',         'Gọi trước khi giao',     'Completed',  'CU32', NULL),
('OD33', 'BANKING', '2026-04-13 18:40:00', 286200.00, 25000.00, 'Gia Lai',            'Không giao buổi trưa',   'Shipped',    'CU33', NULL),
('OD34', 'COD',     '2026-04-14 08:15:00', 359200.00, 30000.00, 'Bến Tre',            'Để trước cửa',           'Completed',  'CU34', NULL),
('OD35', 'MOMO',    '2026-04-14 09:30:00', 241500.00, 25000.00, 'Phú Yên',            'Ship sáng',              'Completed',  'CU35', NULL),
('OD36', 'BANKING', '2026-04-14 11:50:00', 438000.00, 30000.00, 'TP. HCM',            'Bọc kỹ giúp em',         'Processing', 'CU36', NULL),
('OD37', 'COD',     '2026-04-14 14:20:00', 297200.00, 25000.00, 'Quảng Trị',          'Giao giờ hành chính',    'Completed',  'CU37', NULL),
('OD38', 'MOMO',    '2026-04-14 17:10:00', 384150.00, 30000.00, 'TP. HCM',            'Liên hệ điện thoại',     'Completed',  'CU38', NULL),
('OD39', 'BANKING', '2026-04-14 19:25:00', 263200.00, 25000.00, 'Phú Yên',            'Không gọi buổi tối',     'Shipped',    'CU39', NULL),
('OD40', 'COD',     '2026-04-15 08:40:00', 451200.00, 35000.00, 'Khánh Hòa',          'Ship nhanh',             'Completed',  'CU40', NULL),

('OD41', 'MOMO',    '2026-04-15 10:05:00', 276250.00, 25000.00, 'Tiền Giang',         'Giao buổi sáng',         'Completed',  'CU41', NULL),
('OD42', 'BANKING', '2026-04-15 13:30:00', 398000.00, 30000.00, 'TP. HCM',            'Giao trong giờ HC',      'Shipped',    'CU42', NULL),
('OD43', 'COD',     '2026-04-15 15:45:00', 332150.00, 25000.00, 'An Giang',           'Để bảo vệ nhận',         'Completed',  'CU43', NULL),
('OD44', 'MOMO',    '2026-04-15 18:20:00', 287200.00, 25000.00, 'Lâm Đồng',           'Giao trước 18h',         'Completed',  'CU44', NULL),
('OD45', 'BANKING', '2026-04-16 09:15:00', 469300.00, 30000.00, 'Tây Ninh',           'Gói hàng cẩn thận',      'Processing', 'CU45', NULL),
('OD46', 'COD',     '2026-04-16 11:35:00', 254000.00, 25000.00, 'Khánh Hòa',          'Ship thường',            'Completed',  'CU46', NULL),
('OD47', 'MOMO',    '2026-04-16 14:10:00', 391200.00, 30000.00, 'Bình Phước',         'Giao nhanh giúp em',     'Completed',  'CU47', NULL),
('OD48', 'BANKING', '2026-04-16 16:50:00', 318150.00, 25000.00, 'Quảng Trị',          'Không giao trưa',        'Shipped',    'CU48', NULL),
('OD49', 'COD',     '2026-04-16 19:00:00', 272300.00, 25000.00, 'Lâm Đồng',           'Gọi trước khi giao',     'Completed',  'CU49', NULL),
('OD50', 'MOMO',    '2026-04-17 08:25:00', 407200.00, 30000.00, 'Gia Lai',            'Giao giờ hành chính',    'Cancelled',  'CU50', NULL);
 -- ================================
-- ORDER DETAIL
-- Lưu ý: insert sau orders
-- Trigger sẽ tự trừ quantity trong books
-- ================================
INSERT INTO orderdetail (orderId, bookId, quantity, unitPrice)
VALUES
-- OD01: 229000 + 100300 + 70480 = 399780 ; + 30000 = 429780
('OD01', 'KD01', 1, 229000.00),
('OD01', 'KD04', 1, 100300.00),
('OD01', 'LT06', 1, 70480.00),

-- OD02: 200790 + 95000 = 295790 ; + 25000 = 320790
('OD02', 'KD02', 1, 200790.00),
('OD02', 'TT05', 1, 95000.00),

-- OD03: 108200 + 137970 + 100800 = 346970 ; + 30000 = 376970
('OD03', 'KD03', 1, 108200.00),
('OD03', 'MK02', 1, 137970.00),
('OD03', 'CN07', 1, 100800.00),

-- OD04: 87200 + 177000 = 264200 ; + 30000 = 294200
('OD04', 'SK01', 1, 87200.00),
('OD04', 'LT03', 1, 177000.00),

-- OD05: 339300 + 163000 = 502300 ; + 35000 = 537300
('OD05', 'SK02', 1, 339300.00),
('OD05', 'GD05', 1, 163000.00),

-- OD06: 111200 + 99000 = 210200 ; + 25000 = 235200
('OD06', 'TT01', 1, 111200.00),
('OD06', 'LT01', 1, 99000.00),

-- OD07: 183200 + 151200 + 98600 = 433000 ; + 30000 = 463000
('OD07', 'MK04', 1, 183200.00),
('OD07', 'CN03', 1, 151200.00),
('OD07', 'TT07', 1, 98600.00),

-- OD08: 152150 + 100000 = 252150 ; + 30000 = 282150
('OD08', 'KD05', 1, 152150.00),
('OD08', 'TT06', 1, 100000.00),

-- OD09: 99999 + 106000 = 205999 ; + 25000 = 230999
('OD09', 'LT01', 1, 99999.00),
('OD09', 'LS01', 1, 106000.00),

-- OD10: 171000 + 173150 = 344150 ; + 30000 = 374150
('OD10', 'SK05', 1, 171000.00),
('OD10', 'GD07', 1, 173150.00);

INSERT INTO orderdetail (orderId, bookId, quantity, unitPrice)
VALUES
-- OD11: 299300 + 30000
('OD11', 'KD01', 1, 229000.00),
('OD11', 'SK01', 1, 70200.00),

-- OD12: 255000 + 25000
('OD12', 'TT01', 1, 111200.00),
('OD12', 'LT06', 2, 72000.00),

-- OD13: 335200 + 30000
('OD13', 'MK02', 1, 137970.00),
('OD13', 'CN03', 1, 151200.00),
('OD13', 'TT07', 1, 46030.00),

-- OD14: 221200 + 30000
('OD14', 'SK03', 1, 81750.00),
('OD14', 'TT03', 1, 87200.00),
('OD14', 'LT01', 1, 52250.00),

-- OD15: 375000 + 35000
('OD15', 'SK02', 1, 339300.00),
('OD15', 'LT06', 1, 35700.00),

-- OD16: 273150 + 25000
('OD16', 'KD05', 1, 152150.00),
('OD16', 'TT06', 1, 118150.00),
('OD16', 'LT08', 1, 2850.00),

-- OD17: 337000 + 30000
('OD17', 'MK04', 1, 183200.00),
('OD17', 'CN07', 1, 96000.00),
('OD17', 'TT05', 1, 57800.00),

-- OD18: 275200 + 30000
('OD18', 'SK05', 1, 171000.00),
('OD18', 'LT03', 1, 104200.00),

-- OD19: 265000 + 25000
('OD19', 'TT02', 1, 135000.00),
('OD19', 'LT07', 1, 130000.00),

-- OD20: 382000 + 30000
('OD20', 'GD05', 1, 170000.00),
('OD20', 'LS01', 1, 106250.00),
('OD20', 'TT04', 1, 105750.00);

INSERT INTO orderdetail (orderId, bookId, quantity, unitPrice)
VALUES
-- OD21 = 289200 + 25000
('OD21', 'KD04', 1, 100300.00),
('OD21', 'TT03', 1, 87200.00),
('OD21', 'LT08', 1, 101700.00),

-- OD22 = 328170 + 30000
('OD22', 'MK01', 1, 127710.00),
('OD22', 'SK03', 1, 81750.00),
('OD22', 'CN07', 1, 118710.00),

-- OD23 = 262650 + 25000
('OD23', 'ĐS03', 1, 126650.00),
('OD23', 'GD02', 1, 75650.00),
('OD23', 'TT07', 1, 60350.00),

-- OD24 = 372300 + 30000
('OD24', 'LT04', 1, 289000.00),
('OD24', 'TT05', 1, 83200.00),

-- OD25 = 221250 + 25000
('OD25', 'LS01', 1, 106250.00),
('OD25', 'KD07', 1, 104300.00),
('OD25', 'GD01', 1, 10700.00),

-- OD26 = 303200 + 30000
('OD26', 'GD08', 1, 303200.00),

-- OD27 = 266150 + 25000
('OD27', 'MK05', 1, 152150.00),
('OD27', 'SK06', 1, 54400.00),
('OD27', 'TT06', 1, 59600.00),

-- OD28 = 390300 + 35000
('OD28', 'GD03', 1, 159200.00),
('OD28', 'CN08', 1, 159200.00),
('OD28', 'LT07', 1, 71900.00),

-- OD29 = 271200 + 30000
('OD29', 'CN03', 1, 151200.00),
('OD29', 'TT01', 1, 111200.00),
('OD29', 'LT06', 1, 8800.00),

-- OD30 = 359000 + 30000
('OD30', 'SK08', 1, 223200.00),
('OD30', 'KD06', 1, 120000.00),
('OD30', 'TT07', 1, 15800.00);

INSERT INTO orderdetail (orderId, bookId, quantity, unitPrice)
VALUES
-- OD31 = 300000 + 25000
('OD31', 'KD06', 1, 120000.00),
('OD31', 'LT07', 1, 64000.00),
('OD31', 'TT06', 1, 116000.00),

-- OD32 = 382300 + 30000
('OD32', 'SK02', 1, 339300.00),
('OD32', 'TT07', 1, 43000.00),

-- OD33 = 261200 + 25000
('OD33', 'CN03', 1, 151200.00),
('OD33', 'GD02', 1, 75650.00),
('OD33', 'LT06', 1, 34350.00),

-- OD34 = 329200 + 30000
('OD34', 'MK04', 1, 183200.00),
('OD34', 'TT02', 1, 135000.00),
('OD34', 'GD01', 1, 11000.00),

-- OD35 = 216500 + 25000
('OD35', 'KD07', 1, 104300.00),
('OD35', 'SK03', 1, 81750.00),
('OD35', 'TT07', 1, 30450.00),

-- OD36 = 408000 + 30000
('OD36', 'LT04', 1, 289000.00),
('OD36', 'CN07', 1, 96000.00),
('OD36', 'TT07', 1, 23000.00),

-- OD37 = 272200 + 25000
('OD37', 'TT01', 1, 111200.00),
('OD37', 'SK01', 1, 87200.00),
('OD37', 'LT08', 1, 73800.00),

-- OD38 = 354150 + 30000
('OD38', 'KD05', 1, 152150.00),
('OD38', 'MK05', 1, 152150.00),
('OD38', 'LT06', 1, 49850.00),

-- OD39 = 238200 + 25000
('OD39', 'CN06', 1, 31500.00),
('OD39', 'ĐS03', 1, 126650.00),
('OD39', 'GD02', 1, 80050.00),

-- OD40 = 416200 + 35000
('OD40', 'GD08', 1, 303200.00),
('OD40', 'TT03', 1, 87200.00),
('OD40', 'LT06', 1, 25800.00),

-- OD41 = 251250 + 25000
('OD41', 'LS01', 1, 106250.00),
('OD41', 'TT06', 1, 118150.00),
('OD41', 'GD01', 1, 26850.00),

-- OD42 = 368000 + 30000
('OD42', 'SK05', 1, 171000.00),
('OD42', 'MK07', 1, 194650.00),
('OD42', 'TT07', 1, 2350.00),

-- OD43 = 307150 + 25000
('OD43', 'KD02', 1, 200790.00),
('OD43', 'CN06', 1, 31500.00),
('OD43', 'LT06', 1, 74860.00),

-- OD44 = 262200 + 25000
('OD44', 'SK06', 1, 54400.00),
('OD44', 'TT04', 1, 183200.00),
('OD44', 'GD01', 1, 24600.00),

-- OD45 = 439300 + 30000
('OD45', 'CN08', 1, 159200.00),
('OD45', 'GD03', 1, 159200.00),
('OD45', 'MK02', 1, 120900.00),

-- OD46 = 229000 + 25000
('OD46', 'KD01', 1, 229000.00),

-- OD47 = 361200 + 30000
('OD47', 'LS04', 1, 191250.00),
('OD47', 'TT06', 1, 118150.00),
('OD47', 'LT06', 1, 51800.00),

-- OD48 = 293150 + 25000
('OD48', 'MK01', 1, 127710.00),
('OD48', 'SK01', 1, 87200.00),
('OD48', 'TT05', 1, 78240.00),

-- OD49 = 247300 + 25000
('OD49', 'KD04', 1, 100300.00),
('OD49', 'TT01', 1, 111200.00),
('OD49', 'GD01', 1, 35800.00),

-- OD50 = 377200 + 30000
('OD50', 'SK08', 1, 223200.00),
('OD50', 'CN03', 1, 151200.00),
('OD50', 'LT06', 1, 2800.00);
use bookdb;
INSERT INTO coupons
(id,code, customerId, discount_percent, discount_amount, min_order_value, max_discount, expiry_date, usage_limit, used_count)
VALUES
('c1','WELCOME10', NULL, 10, NULL, 100000, 50000, '2026-12-31 23:59:59', 500, 45),
('c2','WELCOME20', NULL, 20, NULL, 200000, 80000, '2026-12-31 23:59:59', 300, 27),
('c3','FREESHIP30', NULL, NULL, 30000, 150000, 30000, '2026-12-31 23:59:59', 400, 61),
('c4','SAVE50K', NULL, NULL, 50000, 300000, 50000, '2026-12-31 23:59:59', 250, 39),
('c5','HOTDEAL15', NULL, 15, NULL, 250000, 70000, '2026-11-30 23:59:59', 200, 18),
('c6','MEGASALE25', NULL, 25, NULL, 500000, 120000, '2026-11-30 23:59:59', 100, 9),
('c7','BOOKLOVER12', NULL, 12, NULL, 180000, 60000, '2026-10-31 23:59:59', 300, 22),
('c8','FLASH40K', NULL, NULL, 40000, 220000, 40000, '2026-10-31 23:59:59', 150, 13),
('c9','VIP30', 'CU01', 30, NULL, 400000, 150000, '2026-12-31 23:59:59', 20, 2),
('c10','VIP50K', 'CU05', NULL, 50000, 250000, 50000, '2026-12-31 23:59:59', 15, 1),
('c11','MEMBER15', 'CU10', 15, NULL, 200000, 70000, '2026-09-30 23:59:59', 30, 4),
('c12','LOYAL20', 'CU12', 20, NULL, 300000, 90000, '2026-09-30 23:59:59', 25, 3),
('c13','NEWUSER25', 'CU20', 25, NULL, 150000, 100000, '2026-08-31 23:59:59', 10, 0),
('c14','SUMMER10', NULL, 10, NULL, 120000, 40000, '2026-08-31 23:59:59', 500, 77),
('c15','AUTUMN15', NULL, 15, NULL, 180000, 60000, '2026-10-15 23:59:59', 350, 33),
('c16','WINTER20', NULL, 20, NULL, 250000, 85000, '2026-12-15 23:59:59', 250, 12),
('c17','COD25K', NULL, NULL, 25000, 100000, 25000, '2026-12-31 23:59:59', 300, 48),
('c18','BANK50K', NULL, NULL, 50000, 400000, 50000, '2026-12-31 23:59:59', 120, 11),
('c19','STUDENT10', 'CU31', 10, NULL, 100000, 30000, '2026-12-31 23:59:59', 50, 5),
('c20','BIRTHDAY50', 'CU16', NULL, 50000, 200000, 50000, '2026-12-31 23:59:59', 5, 0);
