package vn.ptit.libman.dao;

import vn.ptit.libman.model.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public final class LibraryCardDAO0 {
    private final ReaderDAO0 readers = new ReaderDAO0();

    public static final class ExistingCard extends Exception {
        public ExistingCard() { super("Bạn đọc đã có thẻ, không thể đăng kí thêm."); }
    }

    public Optional<LibraryCard0> getLibraryCard(long readerId) throws SQLException {
        try (Connection c = Database0.open()) { return getLibraryCard(c, readerId); }
    }

    private Optional<LibraryCard0> getLibraryCard(Connection c, long readerId) throws SQLException {
        String sql = """
            SELECT cardNumber, cardType, registrationDate, expirationDate, status
            FROM tblLibraryCard0 WHERE tblReader0id = ?
            """;
        try (PreparedStatement p = c.prepareStatement(sql)) {
            p.setLong(1, readerId);
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? Optional.of(new LibraryCard0(r.getString(1), r.getString(2),
                    r.getDate(3).toLocalDate(), r.getDate(4).toLocalDate(), r.getString(5))) : Optional.empty();
            }
        }
    }

    public LibraryCard0 registerLibraryCard(long readerId, Reader0.Form form) throws ExistingCard, SQLException {
        if (!readers.validateReaderInformation(form).isEmpty()) throw new IllegalArgumentException("Hồ sơ không hợp lệ.");
        LocalDate today = LocalDate.now();
        LocalDate expiration = LibraryCard0.STUDENT.equals(form.cardType()) ? today.plusYears(1) : today.plusMonths(6);
        LibraryCard0 card = new LibraryCard0(String.format(Locale.ROOT, "TBD%03d", readerId), form.cardType(),
                                             today, expiration, "Đang hoạt động");
        try (Connection c = Database0.open()) {
            c.setAutoCommit(false);
            try {
                if (getLibraryCard(c, readerId).isPresent()) throw new ExistingCard();
                readers.updateReaderInformation(c, readerId, form);
                String sql = """
                    INSERT INTO tblLibraryCard0
                        (cardNumber, cardType, registrationDate, expirationDate, status, tblReader0id)
                    VALUES (?, ?, ?, ?, ?, ?)
                    """;
                try (PreparedStatement p = c.prepareStatement(sql)) {
                    p.setString(1, card.cardNumber());
                    Database0.setUnicode(p, 2, card.cardType());
                    p.setDate(3, java.sql.Date.valueOf(card.registrationDate()));
                    p.setDate(4, java.sql.Date.valueOf(card.expirationDate()));
                    Database0.setUnicode(p, 5, card.status());
                    p.setLong(6, readerId);
                    if (p.executeUpdate() != 1) throw new SQLException("Không tạo được thẻ.");
                }
                c.commit();
                return card;
            } catch (ExistingCard ex) {
                c.rollback();
                throw ex;
            } catch (SQLException ex) {
                try { c.rollback(); }
                catch (SQLException rollback) { ex.addSuppressed(rollback); throw ex; }
                if (ex.getSQLState() != null && ex.getSQLState().startsWith("23")
                        && getLibraryCard(c, readerId).isPresent()) throw new ExistingCard();
                throw ex;
            }
        }
    }
}
