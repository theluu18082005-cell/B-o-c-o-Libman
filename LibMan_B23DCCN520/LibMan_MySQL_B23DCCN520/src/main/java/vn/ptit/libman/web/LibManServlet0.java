package vn.ptit.libman.web;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import vn.ptit.libman.dao.*;
import vn.ptit.libman.model.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.*;

public final class LibManServlet0 extends HttpServlet {
    private final MemberDAO0 members = new MemberDAO0();
    private final ReaderDAO0 readers = new ReaderDAO0();
    private final LibraryCardDAO0 cards = new LibraryCardDAO0();
    private final DocumentStatisticsDAO0 stats = new DocumentStatisticsDAO0();
    private final LoanDAO0 loans = new LoanDAO0();

    @Override protected void service(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding(StandardCharsets.UTF_8.name());
        res.setCharacterEncoding(StandardCharsets.UTF_8.name());
        res.setHeader("Cache-Control", "no-store");
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setHeader("Referrer-Policy", "same-origin");
        req.setAttribute("demo", Database0.isDemo());
        super.service(req, res);
    }

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String path = req.getServletPath();
        Member0 member = member(req);
        if (path.equals("/login")) {
            if (member != null) redirect(req, res, home(member));
            else view(req, res, "LoginView0", "Đăng nhập");
            return;
        }
        if (path.equals("/logout")) {
            res.sendError(405);
            return;
        }
        if (!authorize(req, res, path, member)) return;
        try {
            switch (path) {
                case "/reader" -> view(req, res, "ReaderHomeView0", "Trang chủ bạn đọc");
                case "/reader/card" -> card(req, res, member);
                case "/manager" -> view(req, res, "ManagerHomeView0", "Trang chủ nhân viên quản lí");
                case "/manager/reports" -> view(req, res, "ReportSelectionView0", "Chọn báo cáo");
                case "/manager/statistics" -> statistics(req, res);
                case "/manager/history" -> history(req, res);
                case "/manager/loan" -> loan(req, res);
                default -> res.sendError(404);
            }
        } catch (SQLException e) {
            getServletContext().log("Không tải được dữ liệu: " + path, e);
            if (path.equals("/reader/card")) {
                req.setAttribute("message", "Không mở được biểu mẫu. Bạn có thể chọn lại chức năng từ trang chủ.");
                view(req, res, "ReaderHomeView0", "Trang chủ bạn đọc");
            } else {
                res.sendError(503, "Không tải được dữ liệu.");
            }
        }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String path = req.getServletPath();
        Member0 member = member(req);
        if (!path.equals("/login") && !authorize(req, res, path, member)) return;
        if (!validToken(req)) { res.sendError(403, "Phiên biểu mẫu đã hết hạn. Hãy tải lại trang."); return; }
        switch (path) {
            case "/login" -> login(req, res);
            case "/logout" -> {
                req.getSession().invalidate();
                redirect(req, res, "/login");
            }
            case "/reader/card" -> register(req, res, member);
            default -> res.sendError(405);
        }
    }

    private void login(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String username = param(req, "username");
        req.setAttribute("username", username);
        try {
            Member0 account = members.authenticate(username, req.getParameter("password"));
            if (account != null) {
                req.getSession().invalidate();
                req.getSession(true).setAttribute("member", account);
                redirect(req, res, home(account));
                return;
            }
            req.setAttribute("message", "Tên đăng nhập hoặc mật khẩu không đúng.");
        } catch (SQLException e) {
            getServletContext().log("Lỗi đăng nhập", e);
            req.setAttribute("message", "Không kết nối được cơ sở dữ liệu. Vui lòng thử lại.");
        }
        view(req, res, "LoginView0", "Đăng nhập");
    }

    private void card(HttpServletRequest req, HttpServletResponse res, Member0 member)
            throws SQLException, ServletException, IOException {
        Reader0 reader = readers.getReaderInformation(member.id());
        if (reader == null) { res.sendError(404); return; }
        req.setAttribute("reader", reader);
        req.setAttribute("form", new Reader0.Form(reader.fullName(), reader.dateOfBirth().toString(),
                            reader.address(), reader.phoneNumber(), reader.email(), ""));
        req.setAttribute("card", cards.getLibraryCard(member.id()).orElse(null));
        HttpSession session = req.getSession();
        if (Boolean.TRUE.equals(session.getAttribute("cardCreated"))) {
            session.removeAttribute("cardCreated");
            req.setAttribute("created", true);
        }
        view(req, res, "LibraryCardRegistrationView0", "Đăng kí làm thẻ bạn đọc");
    }

    private void register(HttpServletRequest req, HttpServletResponse res, Member0 member)
            throws ServletException, IOException {
        var form = new Reader0.Form(param(req, "fullName"), param(req, "dateOfBirth"), param(req, "address"),
                                   param(req, "phoneNumber"), param(req, "email"), param(req, "cardType"));
        req.setAttribute("form", form);
        try {
            if (cards.getLibraryCard(member.id()).isPresent()) throw new LibraryCardDAO0.ExistingCard();
            var errors = readers.validateReaderInformation(form);
            if (errors.isEmpty()) {
                cards.registerLibraryCard(member.id(), form);
                HttpSession session = req.getSession();
                session.setAttribute("member", new Member0(member.id(), form.fullName(), member.role()));
                session.setAttribute("cardCreated", true);
                redirect(req, res, "/reader/card");
                return;
            }
            req.setAttribute("errors", errors);
            req.setAttribute("message", "Vui lòng kiểm tra các mục bên dưới.");
        } catch (LibraryCardDAO0.ExistingCard e) {
            req.setAttribute("message", e.getMessage());
            req.setAttribute("existingCard", true);
        } catch (SQLException e) {
            getServletContext().log("Không lưu được hồ sơ và thẻ", e);
            req.setAttribute("message", "Đăng kí thất bại. Vui lòng thử lại.");
        }
        view(req, res, "LibraryCardRegistrationView0", "Đăng kí làm thẻ bạn đọc");
    }

    private void statistics(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String from = param(req, "from"), to = param(req, "to");
        req.setAttribute("from", from);
        req.setAttribute("to", to);
        if ("history".equals(req.getParameter("error")))
            req.setAttribute("message", "Không tải được lịch sử mượn. Vui lòng chọn lại tài liệu.");
        if (req.getParameter("from") != null || req.getParameter("to") != null) {
            var errors = DateRange0.validateDateRange(from, to);
            req.setAttribute("errors", errors);
            if (errors.isEmpty()) {
                DateRange0 range = range(from, to);
                try {
                    req.setAttribute("items", stats.getDocumentBorrowingStatistics(range));
                    req.setAttribute("range", range);
                } catch (SQLException e) {
                    getServletContext().log("Không tải được thống kê", e);
                    req.setAttribute("message", "Không tải được thống kê. Vui lòng thử lại.");
                }
            }
        }
        view(req, res, "DocumentStatisticsView0", "Thống kê tài liệu theo số lần mượn");
    }

    private void history(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String from = param(req, "from"), to = param(req, "to");
        DateRange0 range = range(from, to);
        long id = documentId(req);
        if (range == null || id <= 0) { res.sendError(400); return; }
        try {
            Loan0.History result = loans.getDocumentBorrowingHistory(id, range);
            if (result != null) {
                req.setAttribute("range", range);
                req.setAttribute("history", result);
                if ("loan".equals(req.getParameter("error")))
                    req.setAttribute("message", "Không tải được chi tiết phiếu. Vui lòng chọn lại lần mượn.");
                view(req, res, "DocumentBorrowingHistoryView0", "Lịch sử mượn tài liệu");
                return;
            }
        } catch (SQLException e) { getServletContext().log("Không tải được lịch sử", e); }
        redirect(req, res, "/manager/statistics" + dates(range) + "&error=history");
    }

    private void loan(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        DateRange0 range = range(param(req, "from"), param(req, "to"));
        long id = documentId(req);
        String code = param(req, "loan");
        if (range == null || id <= 0 || code.isEmpty() || code.length() > 50) { res.sendError(400); return; }
        try {
            Loan0.Detail result = loans.getLoanDetails(code, id, range);
            if (result != null) {
                req.setAttribute("range", range);
                req.setAttribute("documentId", id);
                req.setAttribute("detail", result);
                view(req, res, "LoanDetailsView0", "Chi tiết phiếu mượn");
                return;
            }
        } catch (SQLException e) { getServletContext().log("Không tải được phiếu mượn", e); }
        redirect(req, res, "/manager/history" + dates(range) + "&document=" + id + "&error=loan");
    }

    private static Member0 member(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Member0)session.getAttribute("member");
    }

    private static boolean authorize(HttpServletRequest req, HttpServletResponse res, String path, Member0 member)
            throws IOException {
        if (member == null) { redirect(req, res, "/login"); return false; }
        if (path.startsWith("/reader") && member.role() != Member0.Role.READER ||
            path.startsWith("/manager") && member.role() != Member0.Role.MANAGER) {
            res.sendError(403);
            return false;
        }
        return true;
    }

    private static String home(Member0 member) {
        return member.role() == Member0.Role.MANAGER ? "/manager" : "/reader";
    }

    private static String param(HttpServletRequest req, String name) {
        String s = req.getParameter(name);
        return s == null ? "" : s.strip();
    }

    private static long documentId(HttpServletRequest req) {
        try { return Long.parseLong(param(req, "document")); }
        catch (NumberFormatException e) { return -1; }
    }

    private static DateRange0 range(String from, String to) {
        return DateRange0.validateDateRange(from, to).isEmpty() ? new DateRange0(LocalDate.parse(from), LocalDate.parse(to)) : null;
    }

    private static String dates(DateRange0 range) {
        return "?from=" + range.from() + "&to=" + range.to();
    }

    private static boolean validToken(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute("csrf");
        String actual = req.getParameter("csrf");
        return expected != null && actual != null && MessageDigest.isEqual(
            expected.getBytes(StandardCharsets.UTF_8), actual.getBytes(StandardCharsets.UTF_8));
    }

    private static void view(HttpServletRequest req, HttpServletResponse res, String name, String title)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        synchronized (session) {
            if (session.getAttribute("csrf") == null) session.setAttribute("csrf", UUID.randomUUID().toString());
        }
        req.setAttribute("title", title);
        req.getRequestDispatcher("/WEB-INF/views/" + name + ".jsp").forward(req, res);
    }

    private static void redirect(HttpServletRequest req, HttpServletResponse res, String to) {
        res.setStatus(HttpServletResponse.SC_SEE_OTHER);
        res.setHeader("Location", req.getContextPath() + to);
    }
}
