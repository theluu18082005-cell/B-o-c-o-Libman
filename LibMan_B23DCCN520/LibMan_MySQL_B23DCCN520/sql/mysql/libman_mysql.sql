-- LibMan B23DCCN520: khởi tạo cấu trúc và dữ liệu mẫu cho MySQL 8.0.
-- Chọn Local instance MySQL80 trong Workbench, mở tệp này và chạy toàn bộ.
CREATE DATABASE IF NOT EXISTS libman_b23dccn520
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE libman_b23dccn520;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS tblMember0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `fullName` VARCHAR(100) NOT NULL,
    `dateOfBirth` DATE NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `email` VARCHAR(254) NOT NULL,
    `phoneNumber` VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblEmployee0 (
    `tblMember0id` BIGINT NOT NULL PRIMARY KEY,
    `position` VARCHAR(100) NOT NULL,
    FOREIGN KEY (`tblMember0id`) REFERENCES tblMember0 (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblReader0 (
    `tblMember0id` BIGINT NOT NULL PRIMARY KEY,
    `readerCode` VARCHAR(50) NOT NULL UNIQUE,
    `readerType` VARCHAR(50) NOT NULL,
    FOREIGN KEY (`tblMember0id`) REFERENCES tblMember0 (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblManager0 (
    `tblEmployee0id` BIGINT NOT NULL PRIMARY KEY,
    FOREIGN KEY (`tblEmployee0id`) REFERENCES tblEmployee0 (`tblMember0id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblLibrarian0 (
    `tblEmployee0id` BIGINT NOT NULL PRIMARY KEY,
    FOREIGN KEY (`tblEmployee0id`) REFERENCES tblEmployee0 (`tblMember0id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblLibraryCard0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cardNumber` VARCHAR(50) NOT NULL UNIQUE,
    `cardType` VARCHAR(50) NOT NULL,
    `registrationDate` DATE NOT NULL,
    `expirationDate` DATE NOT NULL,
    `status` VARCHAR(50) NOT NULL,
    `tblReader0id` BIGINT NOT NULL UNIQUE,
    FOREIGN KEY (`tblReader0id`) REFERENCES tblReader0 (`tblMember0id`),
    CHECK (expirationDate >= registrationDate)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblDocument0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `documentCode` VARCHAR(50) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `documentType` VARCHAR(50) NOT NULL,
    `author` VARCHAR(255) NOT NULL,
    `publisher` VARCHAR(255) NOT NULL,
    `publicationYear` INT NOT NULL,
    `description` VARCHAR(1000) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblLoan0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `loanCode` VARCHAR(50) NOT NULL UNIQUE,
    `loanDate` DATE NOT NULL,
    `tblReader0id` BIGINT NOT NULL,
    `tblLibrarian0id` BIGINT NOT NULL,
    FOREIGN KEY (`tblReader0id`) REFERENCES tblReader0 (`tblMember0id`),
    FOREIGN KEY (`tblLibrarian0id`) REFERENCES tblLibrarian0 (`tblEmployee0id`),
    KEY IX_Loan0_loanDate (loanDate, id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblReturnReceipt0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `returnReceiptCode` VARCHAR(50) NOT NULL UNIQUE,
    `returnDate` DATE NOT NULL,
    `tblReader0id` BIGINT NOT NULL,
    `tblLibrarian0id` BIGINT NOT NULL,
    FOREIGN KEY (`tblReader0id`) REFERENCES tblReader0 (`tblMember0id`),
    FOREIGN KEY (`tblLibrarian0id`) REFERENCES tblLibrarian0 (`tblEmployee0id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblSupplier0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `supplierCode` VARCHAR(50) NOT NULL UNIQUE,
    `supplierName` VARCHAR(255) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `email` VARCHAR(254) NOT NULL,
    `phoneNumber` VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblImportReceipt0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `importReceiptCode` VARCHAR(50) NOT NULL UNIQUE,
    `importDate` DATE NOT NULL,
    `tblSupplier0id` BIGINT NOT NULL,
    `tblLibrarian0id` BIGINT NOT NULL,
    FOREIGN KEY (`tblSupplier0id`) REFERENCES tblSupplier0 (`id`),
    FOREIGN KEY (`tblLibrarian0id`) REFERENCES tblLibrarian0 (`tblEmployee0id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblImportDetail0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `quantity` INT NOT NULL,
    `unitPrice` DECIMAL(18,2) NOT NULL,
    `tblImportReceipt0id` BIGINT NOT NULL,
    `tblDocument0id` BIGINT NOT NULL,
    FOREIGN KEY (`tblImportReceipt0id`) REFERENCES tblImportReceipt0 (`id`),
    FOREIGN KEY (`tblDocument0id`) REFERENCES tblDocument0 (`id`),
    UNIQUE (`tblImportReceipt0id`, `tblDocument0id`),
    CHECK (quantity > 0 AND unitPrice >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblDocumentCopy0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `copyCode` VARCHAR(50) NOT NULL UNIQUE,
    `condition` VARCHAR(255) NOT NULL,
    `circulationStatus` VARCHAR(50) NOT NULL,
    `tblImportDetail0id` BIGINT NOT NULL,
    FOREIGN KEY (`tblImportDetail0id`) REFERENCES tblImportDetail0 (`id`),
    KEY IX_DocumentCopy0_import (tblImportDetail0id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblLoanDetail0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `dueDate` DATE NOT NULL,
    `conditionOnLoan` VARCHAR(255) NOT NULL,
    `tblLoan0id` BIGINT NOT NULL,
    `tblDocumentCopy0id` BIGINT NOT NULL,
    FOREIGN KEY (`tblLoan0id`) REFERENCES tblLoan0 (`id`),
    FOREIGN KEY (`tblDocumentCopy0id`) REFERENCES tblDocumentCopy0 (`id`),
    UNIQUE (`tblLoan0id`, `tblDocumentCopy0id`),
    KEY IX_LoanDetail0_copy (tblDocumentCopy0id, tblLoan0id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tblReturnDetail0 (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `conditionOnReturn` VARCHAR(255) NOT NULL,
    `tblReturnReceipt0id` BIGINT NOT NULL,
    `tblLoanDetail0id` BIGINT NOT NULL UNIQUE,
    FOREIGN KEY (`tblReturnReceipt0id`) REFERENCES tblReturnReceipt0 (`id`),
    FOREIGN KEY (`tblLoanDetail0id`) REFERENCES tblLoanDetail0 (`id`)
) ENGINE=InnoDB;

-- Các khóa ngoại trong dữ liệu mẫu được tra theo mã nghiệp vụ.
-- Chạy lại không ghi đè hồ sơ đã chỉnh sửa, không xóa thẻ đã tạo.
START TRANSACTION;

INSERT INTO tblMember0 (`username`, `password`, `fullName`, `dateOfBirth`, `address`, `email`, `phoneNumber`)
VALUES ('bandoc', 'pbkdf2$210000$a6VSb3JxGHl66P2fcGzlbA==$HqLWK/VreBNMeA7Od4nNiflA1Qa5WpF8/Uy6zh6PwKk=', 'Nguyễn Văn An', CAST('2005-05-15' AS DATE), 'Hà Đông, Hà Nội', 'an.nguyen@example.com', '0912345678')
ON DUPLICATE KEY UPDATE `id` = tblMember0.`id`;
INSERT INTO tblMember0 (`username`, `password`, `fullName`, `dateOfBirth`, `address`, `email`, `phoneNumber`)
VALUES ('bandoc2', 'pbkdf2$210000$OreamdMhL1aNCl1dY5RA1g==$SY/HPsv29IiS0NWx7gW9ECI6/iSlojJnU9AzpC7Frtg=', 'Trần Thị Bình', CAST('2005-02-18' AS DATE), 'Thanh Xuân, Hà Nội', 'binh@example.com', '0901234567')
ON DUPLICATE KEY UPDATE `id` = tblMember0.`id`;
INSERT INTO tblMember0 (`username`, `password`, `fullName`, `dateOfBirth`, `address`, `email`, `phoneNumber`)
VALUES ('bandoc3', 'pbkdf2$210000$vL6rS7ePAa+ghzsI3jx6EA==$KCXXCIfQH3/rBP5DxTCpCTxzL3u0eDnNzN6D5S5Aczs=', 'Lê Minh Cường', CAST('2004-08-19' AS DATE), 'Cầu Giấy, Hà Nội', 'cuong@example.com', '0902234567')
ON DUPLICATE KEY UPDATE `id` = tblMember0.`id`;
INSERT INTO tblMember0 (`username`, `password`, `fullName`, `dateOfBirth`, `address`, `email`, `phoneNumber`)
VALUES ('quanly', 'pbkdf2$210000$jTCMV8hOqJa4YcBy4Fb0Tg==$q6nmQd+cZTZXdBL8pLv5KEkoh0EJnsYjMqaMnCJ17wM=', 'Đỗ Thu Hà', CAST('1990-06-12' AS DATE), 'Đống Đa, Hà Nội', 'ha@example.com', '0903234567')
ON DUPLICATE KEY UPDATE `id` = tblMember0.`id`;
INSERT INTO tblMember0 (`username`, `password`, `fullName`, `dateOfBirth`, `address`, `email`, `phoneNumber`)
VALUES ('thuthu', 'pbkdf2$210000$bMTiocbZv/A+BHod6jV/5A==$Q9C2IagKMW+C4X3nBlxc8iJxArkYDwlpHJyNegjpEnw=', 'Phạm Văn Nam', CAST('1994-12-12' AS DATE), 'Hoàng Mai, Hà Nội', 'nam@example.com', '0904234567')
ON DUPLICATE KEY UPDATE `id` = tblMember0.`id`;

INSERT INTO tblReader0 (`tblMember0id`, `readerCode`, `readerType`)
VALUES ((SELECT `id` FROM tblMember0 WHERE `username` = 'bandoc'), 'BD001', 'Sinh viên')
ON DUPLICATE KEY UPDATE `tblMember0id` = tblReader0.`tblMember0id`;
INSERT INTO tblReader0 (`tblMember0id`, `readerCode`, `readerType`)
VALUES ((SELECT `id` FROM tblMember0 WHERE `username` = 'bandoc2'), 'BD002', 'Sinh viên')
ON DUPLICATE KEY UPDATE `tblMember0id` = tblReader0.`tblMember0id`;
INSERT INTO tblReader0 (`tblMember0id`, `readerCode`, `readerType`)
VALUES ((SELECT `id` FROM tblMember0 WHERE `username` = 'bandoc3'), 'BD003', 'Sinh viên')
ON DUPLICATE KEY UPDATE `tblMember0id` = tblReader0.`tblMember0id`;

INSERT INTO tblEmployee0 (`tblMember0id`, `position`)
VALUES ((SELECT `id` FROM tblMember0 WHERE `username` = 'quanly'), 'Quản lí')
ON DUPLICATE KEY UPDATE `tblMember0id` = tblEmployee0.`tblMember0id`;
INSERT INTO tblEmployee0 (`tblMember0id`, `position`)
VALUES ((SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu'), 'Thủ thư')
ON DUPLICATE KEY UPDATE `tblMember0id` = tblEmployee0.`tblMember0id`;

INSERT INTO tblManager0 (`tblEmployee0id`)
VALUES ((SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'quanly')))
ON DUPLICATE KEY UPDATE `tblEmployee0id` = tblManager0.`tblEmployee0id`;

INSERT INTO tblLibrarian0 (`tblEmployee0id`)
VALUES ((SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu')))
ON DUPLICATE KEY UPDATE `tblEmployee0id` = tblLibrarian0.`tblEmployee0id`;

INSERT INTO tblSupplier0 (`supplierCode`, `supplierName`, `address`, `email`, `phoneNumber`)
VALUES ('NCC001', 'Nhà sách Tri Thức', 'Hà Nội', 'contact@example.com', '0241234567')
ON DUPLICATE KEY UPDATE `id` = tblSupplier0.`id`;

INSERT INTO tblDocument0 (`documentCode`, `title`, `documentType`, `author`, `publisher`, `publicationYear`, `description`)
VALUES ('TL001', 'Lập trình hướng đối tượng', 'Giáo trình', 'Nguyễn Văn Hùng', 'NXB Giáo dục', 2024, NULL)
ON DUPLICATE KEY UPDATE `id` = tblDocument0.`id`;
INSERT INTO tblDocument0 (`documentCode`, `title`, `documentType`, `author`, `publisher`, `publicationYear`, `description`)
VALUES ('TL002', 'Cơ sở dữ liệu', 'Giáo trình', 'Trần Minh Đức', 'NXB Giáo dục', 2025, NULL)
ON DUPLICATE KEY UPDATE `id` = tblDocument0.`id`;
INSERT INTO tblDocument0 (`documentCode`, `title`, `documentType`, `author`, `publisher`, `publicationYear`, `description`)
VALUES ('TL003', 'Mạng máy tính', 'Sách', 'Lê Thu Hà', 'NXB Thông tin', 2023, NULL)
ON DUPLICATE KEY UPDATE `id` = tblDocument0.`id`;
INSERT INTO tblDocument0 (`documentCode`, `title`, `documentType`, `author`, `publisher`, `publicationYear`, `description`)
VALUES ('TL004', 'Nhập môn lập trình', 'Sách', 'Vũ Anh Tú', 'NXB Thông tin', 2023, NULL)
ON DUPLICATE KEY UPDATE `id` = tblDocument0.`id`;

INSERT INTO tblImportReceipt0 (`importReceiptCode`, `importDate`, `tblSupplier0id`, `tblLibrarian0id`)
VALUES ('PN001', CAST('2026-07-02' AS DATE), (SELECT `id` FROM tblSupplier0 WHERE `supplierCode` = 'NCC001'), (SELECT `tblEmployee0id` FROM tblLibrarian0 WHERE `tblEmployee0id` = (SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu'))))
ON DUPLICATE KEY UPDATE `id` = tblImportReceipt0.`id`;

INSERT INTO tblImportDetail0 (`quantity`, `unitPrice`, `tblImportReceipt0id`, `tblDocument0id`)
VALUES (4, 75000, (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001'), (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL001'))
ON DUPLICATE KEY UPDATE `id` = tblImportDetail0.`id`;
INSERT INTO tblImportDetail0 (`quantity`, `unitPrice`, `tblImportReceipt0id`, `tblDocument0id`)
VALUES (2, 88000, (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001'), (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL002'))
ON DUPLICATE KEY UPDATE `id` = tblImportDetail0.`id`;
INSERT INTO tblImportDetail0 (`quantity`, `unitPrice`, `tblImportReceipt0id`, `tblDocument0id`)
VALUES (1, 90000, (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001'), (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL003'))
ON DUPLICATE KEY UPDATE `id` = tblImportDetail0.`id`;
INSERT INTO tblImportDetail0 (`quantity`, `unitPrice`, `tblImportReceipt0id`, `tblDocument0id`)
VALUES (1, 60000, (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001'), (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL004'))
ON DUPLICATE KEY UPDATE `id` = tblImportDetail0.`id`;

INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL001', 'Tốt', 'Có sẵn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL001')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;
INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL002', 'Tốt', 'Có sẵn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL001')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;
INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL003', 'Tốt', 'Có sẵn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL001')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;
INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL004', 'Tốt', 'Đang mượn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL001')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;
INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL005', 'Tốt', 'Có sẵn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL002')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;
INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL010', 'Tốt', 'Có sẵn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL002')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;
INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL006', 'Tốt', 'Đang mượn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL003')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;
INSERT INTO tblDocumentCopy0 (`copyCode`, `condition`, `circulationStatus`, `tblImportDetail0id`)
VALUES ('BTL007', 'Tốt', 'Có sẵn', (SELECT `id` FROM tblImportDetail0 WHERE `tblImportReceipt0id` = (SELECT `id` FROM tblImportReceipt0 WHERE `importReceiptCode` = 'PN001') AND `tblDocument0id` = (SELECT `id` FROM tblDocument0 WHERE `documentCode` = 'TL004')))
ON DUPLICATE KEY UPDATE `id` = tblDocumentCopy0.`id`;

INSERT INTO tblLoan0 (`loanCode`, `loanDate`, `tblReader0id`, `tblLibrarian0id`)
VALUES ('PM001', CAST('2026-08-03' AS DATE), (SELECT `tblMember0id` FROM tblReader0 WHERE `readerCode` = 'BD001'), (SELECT `tblEmployee0id` FROM tblLibrarian0 WHERE `tblEmployee0id` = (SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu'))))
ON DUPLICATE KEY UPDATE `id` = tblLoan0.`id`;
INSERT INTO tblLoan0 (`loanCode`, `loanDate`, `tblReader0id`, `tblLibrarian0id`)
VALUES ('PM008', CAST('2026-08-12' AS DATE), (SELECT `tblMember0id` FROM tblReader0 WHERE `readerCode` = 'BD002'), (SELECT `tblEmployee0id` FROM tblLibrarian0 WHERE `tblEmployee0id` = (SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu'))))
ON DUPLICATE KEY UPDATE `id` = tblLoan0.`id`;
INSERT INTO tblLoan0 (`loanCode`, `loanDate`, `tblReader0id`, `tblLibrarian0id`)
VALUES ('PM015', CAST('2026-08-25' AS DATE), (SELECT `tblMember0id` FROM tblReader0 WHERE `readerCode` = 'BD003'), (SELECT `tblEmployee0id` FROM tblLibrarian0 WHERE `tblEmployee0id` = (SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu'))))
ON DUPLICATE KEY UPDATE `id` = tblLoan0.`id`;

INSERT INTO tblLoanDetail0 (`dueDate`, `conditionOnLoan`, `tblLoan0id`, `tblDocumentCopy0id`)
VALUES (CAST('2026-08-17' AS DATE), 'Tốt', (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM001'), (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL003'))
ON DUPLICATE KEY UPDATE `id` = tblLoanDetail0.`id`;
INSERT INTO tblLoanDetail0 (`dueDate`, `conditionOnLoan`, `tblLoan0id`, `tblDocumentCopy0id`)
VALUES (CAST('2026-08-17' AS DATE), 'Tốt', (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM001'), (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL005'))
ON DUPLICATE KEY UPDATE `id` = tblLoanDetail0.`id`;
INSERT INTO tblLoanDetail0 (`dueDate`, `conditionOnLoan`, `tblLoan0id`, `tblDocumentCopy0id`)
VALUES (CAST('2026-08-26' AS DATE), 'Tốt', (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM008'), (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL001'))
ON DUPLICATE KEY UPDATE `id` = tblLoanDetail0.`id`;
INSERT INTO tblLoanDetail0 (`dueDate`, `conditionOnLoan`, `tblLoan0id`, `tblDocumentCopy0id`)
VALUES (CAST('2026-08-26' AS DATE), 'Tốt', (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM008'), (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL002'))
ON DUPLICATE KEY UPDATE `id` = tblLoanDetail0.`id`;
INSERT INTO tblLoanDetail0 (`dueDate`, `conditionOnLoan`, `tblLoan0id`, `tblDocumentCopy0id`)
VALUES (CAST('2026-08-29' AS DATE), 'Tốt', (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM008'), (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL010'))
ON DUPLICATE KEY UPDATE `id` = tblLoanDetail0.`id`;
INSERT INTO tblLoanDetail0 (`dueDate`, `conditionOnLoan`, `tblLoan0id`, `tblDocumentCopy0id`)
VALUES (CAST('2026-09-08' AS DATE), 'Tốt', (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM015'), (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL004'))
ON DUPLICATE KEY UPDATE `id` = tblLoanDetail0.`id`;
INSERT INTO tblLoanDetail0 (`dueDate`, `conditionOnLoan`, `tblLoan0id`, `tblDocumentCopy0id`)
VALUES (CAST('2026-09-08' AS DATE), 'Tốt', (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM015'), (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL006'))
ON DUPLICATE KEY UPDATE `id` = tblLoanDetail0.`id`;

INSERT INTO tblReturnReceipt0 (`returnReceiptCode`, `returnDate`, `tblReader0id`, `tblLibrarian0id`)
VALUES ('PT001', CAST('2026-08-15' AS DATE), (SELECT `tblMember0id` FROM tblReader0 WHERE `readerCode` = 'BD001'), (SELECT `tblEmployee0id` FROM tblLibrarian0 WHERE `tblEmployee0id` = (SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu'))))
ON DUPLICATE KEY UPDATE `id` = tblReturnReceipt0.`id`;
INSERT INTO tblReturnReceipt0 (`returnReceiptCode`, `returnDate`, `tblReader0id`, `tblLibrarian0id`)
VALUES ('PT008', CAST('2026-08-24' AS DATE), (SELECT `tblMember0id` FROM tblReader0 WHERE `readerCode` = 'BD002'), (SELECT `tblEmployee0id` FROM tblLibrarian0 WHERE `tblEmployee0id` = (SELECT `tblMember0id` FROM tblEmployee0 WHERE `tblMember0id` = (SELECT `id` FROM tblMember0 WHERE `username` = 'thuthu'))))
ON DUPLICATE KEY UPDATE `id` = tblReturnReceipt0.`id`;

INSERT INTO tblReturnDetail0 (`conditionOnReturn`, `tblReturnReceipt0id`, `tblLoanDetail0id`)
VALUES ('Tốt', (SELECT `id` FROM tblReturnReceipt0 WHERE `returnReceiptCode` = 'PT001'), (SELECT `id` FROM tblLoanDetail0 WHERE `tblLoan0id` = (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM001') AND `tblDocumentCopy0id` = (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL003')))
ON DUPLICATE KEY UPDATE `id` = tblReturnDetail0.`id`;
INSERT INTO tblReturnDetail0 (`conditionOnReturn`, `tblReturnReceipt0id`, `tblLoanDetail0id`)
VALUES ('Tốt', (SELECT `id` FROM tblReturnReceipt0 WHERE `returnReceiptCode` = 'PT001'), (SELECT `id` FROM tblLoanDetail0 WHERE `tblLoan0id` = (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM001') AND `tblDocumentCopy0id` = (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL005')))
ON DUPLICATE KEY UPDATE `id` = tblReturnDetail0.`id`;
INSERT INTO tblReturnDetail0 (`conditionOnReturn`, `tblReturnReceipt0id`, `tblLoanDetail0id`)
VALUES ('Tốt', (SELECT `id` FROM tblReturnReceipt0 WHERE `returnReceiptCode` = 'PT008'), (SELECT `id` FROM tblLoanDetail0 WHERE `tblLoan0id` = (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM008') AND `tblDocumentCopy0id` = (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL001')))
ON DUPLICATE KEY UPDATE `id` = tblReturnDetail0.`id`;
INSERT INTO tblReturnDetail0 (`conditionOnReturn`, `tblReturnReceipt0id`, `tblLoanDetail0id`)
VALUES ('Tốt', (SELECT `id` FROM tblReturnReceipt0 WHERE `returnReceiptCode` = 'PT008'), (SELECT `id` FROM tblLoanDetail0 WHERE `tblLoan0id` = (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM008') AND `tblDocumentCopy0id` = (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL002')))
ON DUPLICATE KEY UPDATE `id` = tblReturnDetail0.`id`;
INSERT INTO tblReturnDetail0 (`conditionOnReturn`, `tblReturnReceipt0id`, `tblLoanDetail0id`)
VALUES ('Tốt', (SELECT `id` FROM tblReturnReceipt0 WHERE `returnReceiptCode` = 'PT008'), (SELECT `id` FROM tblLoanDetail0 WHERE `tblLoan0id` = (SELECT `id` FROM tblLoan0 WHERE `loanCode` = 'PM008') AND `tblDocumentCopy0id` = (SELECT `id` FROM tblDocumentCopy0 WHERE `copyCode` = 'BTL010')))
ON DUPLICATE KEY UPDATE `id` = tblReturnDetail0.`id`;

COMMIT;

SELECT COUNT(*) AS so_tai_khoan_mau FROM tblMember0 WHERE username IN ('bandoc', 'quanly');
