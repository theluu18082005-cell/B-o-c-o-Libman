package vn.ptit.libman;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import vn.ptit.libman.dao.*;
import vn.ptit.libman.model.*;

import java.net.*;
import java.net.http.*;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;
import java.util.regex.Pattern;

import static org.junit.jupiter.api.Assertions.*;

class LibManTest {
    @TempDir Path temp;

    @Test void coversQueriesAndCardRollback() throws Exception {
        assertTrue(Database0.isDemo(), "Chỉ chạy kiểm thử trên DB demo.");
        var dao = new DocumentStatisticsDAO0();
        var loans = new LoanDAO0();
        DateRange0 august = new DateRange0(LocalDate.parse("2026-08-01"), LocalDate.parse("2026-08-31"));
        var result = dao.getDocumentBorrowingStatistics(august);
        assertEquals(List.of("TL001", "TL002", "TL003"), result.stream().map(DocumentStatistics0::documentCode).toList());
        assertEquals(List.of(3,2,1), result.stream().map(DocumentStatistics0::borrowCount).toList());
        long docId = result.get(0).documentId();
        var history = loans.getDocumentBorrowingHistory(docId, august);
        assertEquals(List.of("PM001","PM008","PM015"), history.loans().stream().map(Loan0::loanCode).toList());
        var detail = loans.getLoanDetails("PM008", docId, august);
        assertEquals(List.of("BTL001","BTL002","BTL010"), detail.lines().stream().map(Loan0.Line::copyCode).toList());
        assertTrue(detail.lines().stream().allMatch(Loan0.Line::returned));
        var only = new DateRange0(LocalDate.parse("2026-08-12"), LocalDate.parse("2026-08-12"));
        assertEquals(List.of("TL001", "TL002"),
            dao.getDocumentBorrowingStatistics(only).stream().map(DocumentStatistics0::documentCode).toList());
        assertNull(loans.getLoanDetails("PM015", docId, only));
        assertTrue(dao.getDocumentBorrowingStatistics(new DateRange0(
            LocalDate.parse("2025-01-01"), LocalDate.parse("2025-01-31"))).isEmpty());

        var readers = new ReaderDAO0();
        var cards = new LibraryCardDAO0();
        var original = readers.getReaderInformation(3);
        var form = new Reader0.Form("Lê Minh Cường", "2004-08-19", "Địa chỉ mới", "0902234567",
                                    "cuong@example.com", "Sinh viên");
        try (var c = Database0.open(); var s = c.createStatement()) {
            s.execute("""
                INSERT INTO tblLibraryCard0 (cardNumber, cardType, registrationDate, expirationDate, status, tblReader0id)
                VALUES ('TBD003', N'Sinh viên', CAST('2026-01-01' AS DATE), CAST('2027-01-01' AS DATE), N'Đang hoạt động', 2)
                """);
        }
        try {
            assertThrows(java.sql.SQLException.class, () -> cards.registerLibraryCard(3, form));
            assertEquals(original.address(), readers.getReaderInformation(3).address());
            assertTrue(cards.getLibraryCard(3).isEmpty());
        } finally {
            try (var c = Database0.open(); var s = c.createStatement()) {
                s.executeUpdate("DELETE FROM tblLibraryCard0 WHERE tblReader0id=2 AND cardNumber='TBD003'");
            }
        }
        assertEquals("TBD003", cards.registerLibraryCard(3, form).cardNumber());
        assertEquals("Địa chỉ mới", readers.getReaderInformation(3).address());
        assertThrows(LibraryCardDAO0.ExistingCard.class, () -> cards.registerLibraryCard(3, form));
    }

    @Test void rendersJspAndRunsTwoModulesOverHttp() throws Exception {
        assertTrue(Database0.isDemo(), "Chỉ chạy kiểm thử trên DB demo.");
        var server = DemoServer0.start(0, temp);
        try {
            String base = "http://localhost:" + server.getConnector().getLocalPort() + "/libman";
            var reader = client();
            assertEquals(303, get(reader, base + "/reader/card").statusCode());
            login(reader, base, "bandoc");
            assertEquals(403, get(reader, base + "/manager").statusCode());
            var card = get(reader, base + "/reader/card");
            assertEquals(200, card.statusCode(), card.body());
            assertTrue(card.body().contains("Nguyễn Văn An"));
            assertTrue(card.body().contains("Chọn loại thẻ"));
            String data = "csrf=" + token(card.body()) + "&fullName=" + encode("Nguyễn Văn An")
                + "&dateOfBirth=2005-05-15&address=" + encode("Hà Đông, Hà Nội")
                + "&phoneNumber=0912345678&email=an.nguyen%40example.com&cardType=" + encode("Sinh viên");
            assertEquals(403, post(reader, base + "/reader/card", data.replaceFirst("csrf=[^&]+", "csrf=sai")).statusCode());
            var bad = post(reader, base + "/reader/card", data.replace("0912345678", "123"));
            assertTrue(bad.body().contains("Nhập số điện thoại hợp lệ"));
            var response = post(reader, base + "/reader/card", data);
            assertEquals(303, response.statusCode(), response.body());
            assertTrue(get(reader, base + "/reader/card").body().contains("Đăng kí thẻ bạn đọc thành công"));
            assertTrue(post(reader, base + "/reader/card", data).body().contains("Bạn đọc đã có thẻ"));

            var manager = client();
            login(manager, base, "quanly");
            assertEquals(403, get(manager, base + "/reader/card").statusCode());
            assertTrue(get(manager, base + "/manager/reports").body().contains("Chọn báo cáo"));
            assertTrue(get(manager, base + "/manager/statistics?from=2026-08-20&to=2026-08-01")
                .body().contains("Ngày bắt đầu không được lớn hơn ngày kết thúc"));
            String dates = "from=2026-08-01&to=2026-08-31";
            var stats = get(manager, base + "/manager/statistics?" + dates);
            assertEquals(200, stats.statusCode(), stats.body());
            assertTrue(stats.body().contains("Lập trình hướng đối tượng"));
            var history = get(manager, base + "/manager/history?document=1&" + dates);
            assertEquals(200, history.statusCode(), history.body());
            assertTrue(history.body().contains("3 lần mượn"));
            var detail = get(manager, base + "/manager/loan?document=1&loan=PM008&" + dates);
            assertEquals(200, detail.statusCode(), detail.body());
            assertTrue(detail.body().contains("BTL010"));
            assertTrue(detail.body().contains("Đã trả"));
        } finally {
            server.stop();
            server.destroy();
        }
    }

    private static HttpClient client() {
        return HttpClient.newBuilder().cookieHandler(new CookieManager(null, CookiePolicy.ACCEPT_ALL)).build();
    }

    private static HttpResponse<String> get(HttpClient c, String uri) throws Exception {
        return c.send(HttpRequest.newBuilder(URI.create(uri)).build(), HttpResponse.BodyHandlers.ofString());
    }

    private static HttpResponse<String> post(HttpClient c, String uri, String form) throws Exception {
        return c.send(HttpRequest.newBuilder(URI.create(uri))
            .header("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
            .POST(HttpRequest.BodyPublishers.ofString(form)).build(), HttpResponse.BodyHandlers.ofString());
    }

    private static String token(String body) {
        var matcher = Pattern.compile("name=\"csrf\" value=\"([^\"]+)\"").matcher(body);
        assertTrue(matcher.find(), body);
        return matcher.group(1);
    }

    private static void login(HttpClient client, String base, String user) throws Exception {
        String csrf = token(get(client, base + "/login").body());
        var r = post(client, base + "/login",
            "csrf=" + csrf + "&username=" + user + "&password=" + encode("LibManDemo!2026"));
        assertEquals(303, r.statusCode(), r.body());
    }

    private static String encode(String s) { return URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8); }
}
