package vn.ptit.libman.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public final class Html0 {
    private Html0() {}
    public static String e(Object value) {
        if (value == null) return "";
        return value.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
    }

    public static String date(LocalDate value) {
        return value == null ? "" : value.format(DateTimeFormatter.ofPattern("dd/MM/uuuu"));
    }

    public static String query(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
