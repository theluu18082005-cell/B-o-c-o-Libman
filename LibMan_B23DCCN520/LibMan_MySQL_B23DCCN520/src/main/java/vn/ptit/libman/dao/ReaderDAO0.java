package vn.ptit.libman.dao;

import vn.ptit.libman.model.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public final class ReaderDAO0 {
    public Reader0 getReaderInformation(long readerId) throws SQLException {
        String sql = """
            SELECT r.readerCode, m.fullName, m.dateOfBirth, m.address, m.phoneNumber, m.email
            FROM tblReader0 r JOIN tblMember0 m ON m.id = r.tblMember0id
            WHERE r.tblMember0id = ?
            """;
        try (Connection c = Database0.open(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setLong(1, readerId);
            try (ResultSet r = p.executeQuery()) {
                if (!r.next()) return null;
                return new Reader0(readerId, r.getString("readerCode"), r.getString("fullName"),
                    r.getDate("dateOfBirth").toLocalDate(), r.getString("address"),
                    r.getString("phoneNumber"), r.getString("email"));
            }
        }
    }

    public Map<String,String> validateReaderInformation(Reader0.Form f) {
        var errors = new LinkedHashMap<String,String>();
        if (f.fullName().isBlank() || f.fullName().length() > 100)
            errors.put("fullName", "Họ tên là bắt buộc và tối đa 100 kí tự.");
        LocalDate birth = null;
        if (f.dateOfBirth().matches("[0-9]{4}-[0-9]{2}-[0-9]{2}")) {
            try { birth = LocalDate.parse(f.dateOfBirth()); }
            catch (java.time.DateTimeException ignored) {}
        }
        if (birth == null || birth.getYear() < 1 || birth.isAfter(LocalDate.now()))
            errors.put("dateOfBirth", "Ngày sinh không hợp lệ hoặc ở trong tương lai.");
        if (f.address().isBlank() || f.address().length() > 255)
            errors.put("address", "Địa chỉ là bắt buộc và tối đa 255 kí tự.");
        if (!f.phoneNumber().matches("(?:0[0-9]{9,10}|\\+84[0-9]{9,10})"))
            errors.put("phoneNumber", "Nhập số điện thoại hợp lệ, ví dụ 0912345678.");
        if (f.email().length() > 254 || !f.email().matches("[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\\.[A-Za-z0-9-]+)+"))
            errors.put("email", "Nhập email hợp lệ, ví dụ ban@example.com.");
        if (!LibraryCard0.STUDENT.equals(f.cardType()) && !LibraryCard0.STANDARD.equals(f.cardType()))
            errors.put("cardType", "Vui lòng chọn loại thẻ.");
        return errors;
    }

    void updateReaderInformation(Connection c, long readerId, Reader0.Form f) throws SQLException {
        String sql = """
            UPDATE tblMember0 SET fullName = ?, dateOfBirth = ?, address = ?, phoneNumber = ?, email = ?
            WHERE id = ? AND EXISTS (SELECT 1 FROM tblReader0 WHERE tblMember0id = ?)
            """;
        try (PreparedStatement p = c.prepareStatement(sql)) {
            Database0.setUnicode(p, 1, f.fullName());
            p.setDate(2, java.sql.Date.valueOf(f.dateOfBirth()));
            Database0.setUnicode(p, 3, f.address());
            p.setString(4, f.phoneNumber());
            p.setString(5, f.email());
            p.setLong(6, readerId);
            p.setLong(7, readerId);
            if (p.executeUpdate() != 1) throw new SQLException("Không tìm thấy bạn đọc.");
        }
    }
}
