-- tạo database
CREATE DATABASE railway_db;
-- kết nối tới database
\c railway_db;
--tạo Schema
CREATE SCHEMA railway;
-- chọn Schema mặc định
SET search_path TO railway;
-- tạo bảng quản lí khách hàng

CREATE TABLE railway.quanLyKhachHang (
    maHK VARCHAR(20) PRIMARY KEY,
    hoTen VARCHAR(100) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    sdt VARCHAR(15) NOT NULL UNIQUE,
    cccd VARCHAR(12) NOT NULL UNIQUE

);
-- tạo bảng quản lí đoàn tàu
CREATE TABLE railway.quanLyDoanTau (
  maTau VARCHAR(20) PRIMARY KEY,
  tenTau VARCHAR(50) NOT NULL,
  loaiTau VARCHAR(50) NOT NULL,
  tongSoGhe INT NOT NULL CHECK(tongSoGhe > 0)
);
-- tạo bảng quản lí vé
CREATE TABLE railway.quanLyVe (
    maVe VARCHAR(20) PRIMARY KEY,
    maHK VARCHAR(20) NOT NULL,
    maTau VARCHAR(20) NOT NULL,
    ngayKhoiHanh DATE NOT NULL,
    soGhe VARCHAR(10) NOT NULL,
    giaVe NUMERIC(12,2) NOT NULL CHECK(giaVe > 0),
    UNIQUE (maTau, ngayKhoiHanh,soGhe),
    FOREIGN KEY (maHK) REFERENCES railway.quanLyKhachHang(maHK),
    FOREIGN KEY (maTau) REFERENCES railway.quanLyDoanTau(maTau)
);
-- tạo bảng quản lí giao dịch
CREATE TABLE railway.quanLyGiaoDich (
    maGiaoDich VARCHAR(20) PRIMARY KEY,
    maVe VARCHAR(20) NOT NULL UNIQUE,
    phuongThucThanhToan VARCHAR(20) NOT NULL,
    ngayThanhToan DATE NOT NULL,
    soTien NUMERIC(12,2) NOT NULL CHECK(soTien > 0),
    FOREIGN KEY (maVe) REFERENCES railway.quanLyVe(maVe)
);

INSERT INTO railway.quanLyKhachHang
(maHK, hoTen, email, sdt, cccd)
VALUES
    ('P001','Nguyen Van An','an.nguyen@example.com','912345678','1234567890'),
    ('P002','Tran Thi Binh','binh.tran@example.com','923456789','2345678901'),
    ('P003','Le Minh Chau','chau.le@example.com','934567890','3456789012'),
    ('P004','Pham Quoc Dat','dat.pham@example.com','945678901','4567890123'),
    ('P005','Vo Thanh Em','em.vo@example.com','956789012','5678901234');

SELECT *
FROM railway.quanLyKhachHang;

INSERT INTO railway.quanLyDoanTau
(matau, tentau, loaitau, tongsoghe)
VALUES
    ('T001','Tau Thong Nhat 1','SE',500),
    ('T002','Tau Thong Nhat 2','TN',450),
    ('T003','Tau Sai Gon - Hue','SE',400),
    ('T004','Tau Ha Noi - Lao Cai','TN',350),
    ('T005','Tau Da Nang Express','SE',300);

SELECT *
FROM railway.quanLyDoanTau;

INSERT INTO railway.quanLyVe
(mave, mahk, matau, ngaykhoihanh, soghe, giave)
VALUES
    ('TK001','P001','T001','2025-06-10','A01',850000),
    ('TK002','P002','T002','2025-06-11','B05',650000),
    ('TK003','P003','T003','2025-06-12','C10',720000),
    ('TK004','P004','T004','2025-06-13','D12',500000),
    ('TK005','P005','T005','2025-06-14','E08',900000);

SELECT *
FROM railway.quanLyVe;

INSERT INTO railway.quanLyGiaoDich
(magiaodich, mave, phuongthucthanhtoan, ngaythanhtoan, sotien)
VALUES
    ('TR001','TK001','Credit Card','2025-01-06',850000),
    ('TR002','TK002','Cash','2025-02-06',650000),
    ('TR003','TK003','Bank Transfer','2025-03-06',720000),
    ('TR004','TK004','E-Wallet','2025-04-06',500000),
    ('TR005','TK005','Credit Card','2025-05-06',900000);

SELECT *
FROM railway.quanLyGiaoDich;


-- cập nhật giá vé
UPDATE railway.quanLyVe v
SET giaVe = giaVe * 0.85
FROM railway.quanLyGiaoDich gd
WHERE v.maVe = gd.maVe
AND gd.ngayThanhToan < '2025-05-01';
-- kiểm tra kết
SELECT
    maVe,
    giaVe
FROM railway.quanLyVe
ORDER BY maVe;

-- khách p001 hủy vé nên xoá hết các data liên quan

DELETE FROM railway.quanlygiaodich
WHERE maVe IN (
    SELECT maVe
    FROM railway.quanLyVe
    WHERE maHK = 'P001'
);
DELETE FROM railway.quanLyVe
WHERE maHK='P001';

-- báo cáo vé đã thanh toán
-- sắp xếp theo ngày khởi hành mới nhất
SELECT
    v.maVe,
    v.maHK,
    dt.tenTau,
    v.ngayKhoiHanh,
    v.giaVe
FROM railway.quanLyVe v
INNER JOIN railway.quanLyDoanTau dt
ON v.maTau = dt.maTau
INNER JOIN railway.quanLyGiaoDich gd
ON v.maVe = gd.maVe
ORDER BY v.ngayKhoiHanh DESC;

-- tìm khách hàng quên mã HK

SELECT
    maHK,
    hoTen,
    sdt
FROM railway.quanLyKhachHang
WHERE sdt LIKE '091%';

-- hiển thị vé trên màn hình

SELECT
    kh.maHK,
    kh.hoTen,
    v.ngayKhoiHanh
FROM railway.quanLyKhachHang kh
INNER JOIN railway.quanLyVe v
ON kh.maHK = v.maHK
ORDER BY kh.maHK
LIMIT 3
OFFSET 2;

-- Báo cáo & phân tích nghiệp vụ
-- xuất hóa đơn thanh toán

SELECT
    v.maHK,
    kh.hoTen,
    dt.tenTau,
    v.giaVe + COALESCE(gd.soTien,0) AS tongTien
FROM railway.quanLyVe v
INNER JOIN railway.quanLyKhachHang kh
ON v.mahk = kh.mahk
INNER JOIN railway.quanLyDoanTau dt
ON dt.matau = v.matau
LEFT JOIN railway.quanLyGiaoDich gd
ON v.maVe = gd.maVe;

-- Tính KPI & Thưởng doanh thu

SELECT
    dt.maTau,
    dt.tenTau,
    COUNT(v.maVe) AS tongSoVeBanDuoc,
    SUM(v.giaVe) AS tongDoanhThu
FROM railway.quanLyDoanTau dt
INNER JOIN railway.quanLyVe v
ON v.maTau = dt.maTau
GROUP BY dt.maTau, dt.tenTau
HAVING COUNT(v.maVe) >= 3;


-- Thanh tra giao dịch
SELECT
    v.maVe,
    v.maHK,
    v.ngayKhoiHanh
FROM railway.quanLyVe v
LEFT JOIN railway.quanLyGiaoDich gd
    ON v.maVe = gd.maVe
WHERE gd.maVe IS NULL;

-- Phân tích chuyên sâu

SELECT
    kh.maHK,
    kh.hoTen,
    kh.sdt,
    SUM(gd.soTien) AS tongTienThanhToan
FROM railway.quanLyKhachHang kh
INNER JOIN railway.quanLyVe v
ON v.maHK = kh.mahk
INNER JOIN railway.quanlygiaodich gd
ON v.maVe = gd.maVe
GROUP BY kh.maHK, kh.hoTen, kh.sdt
HAVING SUM(gd.soTien) > 200000
ORDER BY kh.maHK ASC;

--  View: Vé sắp khởi hành – vw_UpcomingTrips

CREATE VIEW railway.vw_UpcomingTrips AS
SELECT
    kh.hoTen,
    dt.tenTau,
    v.soGhe,
    v.giaVe,
    v.ngayKhoiHanh
FROM railway.quanLyVe v
INNER JOIN railway.quanLyKhachHang kh
ON v.maHK = kh.maHK
INNER JOIN railway.quanLyDoanTau dt
ON v.maTau = dt.maTau
WHERE v.ngayKhoiHanh > CURRENT_DATE
ORDER BY v.ngayKhoiHanh ASC;

SELECT *
FROM railway.vw_UpcomingTrips;

--  View: Vé giá trị cao – vw_HighValueTickets
CREATE VIEW railway.vw_HighValueTickets AS
SELECT
    kh.hoTen,
    dt.tenTau,
    v.soGhe,
    v.giaVe
FROM railway.quanLyVe v
INNER JOIN railway.quanLyKhachHang kh
ON v.maHK = kh.maHK
INNER JOIN railway.quanLyDoanTau dt
ON v.maTau = dt.maTau
WHERE v.giaVe > 500000
ORDER BY v.giaVe DESC;

SELECT *
FROM railway.vw_HighValueTickets;

-- Trigger: Kiểm tra ngày khởi hành – tg_check_ticket_date

-- tạo function để kiểm tra
CREATE OR REPLACE FUNCTION railway.fn_check_ticket_date()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.ngayKhoiHanh < CURRENT_DATE THEN
        RAISE EXCEPTION
        'Ngay khoi hanh khong duoc nho hon ngay hien tai';
    END IF;

    RETURN NEW;

end;
$$ LANGUAGE plpgsql;

-- tạo trigger để tự động kiểm tra
CREATE TRIGGER tg_check_ticket_date
BEFORE INSERT
ON railway.quanLyVe
FOR EACH ROW
EXECUTE FUNCTION railway.fn_check_ticket_date();

-- Trigger: Cập nhật số ghế còn trống – tg_update_seats
-- tạo function
CREATE OR REPLACE FUNCTION railway.fn_update_seats()
RETURNS TRIGGER
AS $$
BEGIN
    UPDATE railway.quanLyDoanTau
    SET tongSoGhe = tongSoGhe -1
    WHERE maTau = NEW.maTau;

    RETURN NEW;


end;

$$ language plpgsql;

-- tạo trigger
CREATE TRIGGER tg_update_seats
AFTER INSERT
ON railway.quanLyVe
FOR EACH ROW
EXECUTE FUNCTION railway.fn_update_seats();

-- Procedure: Thêm hành khách – sp_add_passenger
CREATE OR REPLACE PROCEDURE railway.sp_add_passenger(
    p_maHK VARCHAR(20),
    p_hoTen VARCHAR(100),
    p_email VARCHAR(50),
    p_sdt VARCHAR(15),
    p_cccd VARCHAR(12)
)
language plpgsql
AS $$
BEGIN
    INSERT INTO railway.quanLyKhachHang
    (mahk, hoten, email, sdt, cccd)
    VALUES
    (p_maHK,p_hoTen,p_email,p_sdt,p_cccd);
end;
$$;

CALL railway.sp_add_passenger(
        'P006',
        'Nguyen Van B',
        'b@gmail.com',
        '0912345678',
        '123456789999'
     );

SELECT *
FROM railway.quanLyKhachHang;

-- Procedure: Hủy vé – sp_cancel_ticket

CREATE OR REPLACE PROCEDURE railway.sp_cancel_ticket(
    p_maVe VARCHAR(20)
)
language plpgsql
AS $$
BEGIN
    DELETE FROM railway.quanLyGiaoDich
    WHERE maVe = p_maVe;

    DELETE FROM railway.quanLyVe
    WHERE maVe = p_maVe;

END;
$$;

CALL railway.sp_cancel_ticket('TK001');

SELECT *
FROM railway.quanLyVe;

DROP TABLE railway.quanLyGiaoDich;
DROP TABLE railway.quanLyVe;
DROP TABLE railway.quanLyDoanTau;
DROP TABLE railway.quanLyKhachHang;


