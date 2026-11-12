package vn.ptit.libman.model;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;

public record DateRange0(LocalDate from, LocalDate to) {
    public DateRange0 {
        if (from == null || to == null || from.isAfter(to)) {
            throw new IllegalArgumentException("Khoảng ngày không hợp lệ.");
        }
    }

    public static Map<String,String> validateDateRange(String from, String to) {
        var errors = new LinkedHashMap<String,String>();
        LocalDate a = parse(from), b = parse(to);
        if (a == null) errors.put("from", "Vui lòng nhập ngày bắt đầu hợp lệ.");
        if (b == null) errors.put("to", "Vui lòng nhập ngày kết thúc hợp lệ.");
        if (a != null && b != null && a.isAfter(b)) {
            errors.put("from", "Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }
        return errors;
    }

    private static LocalDate parse(String value) {
        if (value == null || !value.matches("[0-9]{4}-[0-9]{2}-[0-9]{2}")) return null;
        try {
            LocalDate date = LocalDate.parse(value);
            return date.getYear() >= 1 ? date : null;
        } catch (java.time.DateTimeException e) {
            return null;
        }
    }
}
