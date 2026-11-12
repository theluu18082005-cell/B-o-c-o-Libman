package vn.ptit.libman.dao;

import vn.ptit.libman.model.*;
import java.sql.*;
import java.util.*;

public final class LoanDAO0 {
    private static final String LOAN_HEADER = """
        SELECT l.id, l.loanCode, l.loanDate, r.readerCode, reader.fullName, librarian.fullName
        FROM tblLoan0 l
        JOIN tblReader0 r ON r.tblMember0id = l.tblReader0id
        JOIN tblMember0 reader ON reader.id = r.tblMember0id
        JOIN tblLibrarian0 lib ON lib.tblEmployee0id = l.tblLibrarian0id
        JOIN tblMember0 librarian ON librarian.id = lib.tblEmployee0id
        """;
    private static final String HAS_DOCUMENT = """
        EXISTS (
            SELECT 1 FROM tblLoanDetail0 ld
            JOIN tblDocumentCopy0 dc ON dc.id = ld.tblDocumentCopy0id
            JOIN tblImportDetail0 im ON im.id = dc.tblImportDetail0id
            WHERE ld.tblLoan0id = l.id AND im.tblDocument0id = ?
        )
        """;

    public Loan0.History getDocumentBorrowingHistory(long documentId, DateRange0 range) throws SQLException {
        String meta = "SELECT documentCode, title, documentType FROM tblDocument0 WHERE id = ?";
        String sql = LOAN_HEADER + " WHERE l.loanDate BETWEEN ? AND ? AND " + HAS_DOCUMENT
            + " ORDER BY l.loanDate, l.loanCode";
        try (Connection c = Database0.open(); PreparedStatement document = c.prepareStatement(meta);
             PreparedStatement p = c.prepareStatement(sql)) {
            document.setLong(1, documentId);
            String code, title, type;
            try (ResultSet row = document.executeQuery()) {
                if (!row.next()) return null;
                code = row.getString(1);
                title = row.getString(2);
                type = row.getString(3);
            }
            dates(p, range);
            p.setLong(3, documentId);
            try (ResultSet rows = p.executeQuery()) {
                var loans = new ArrayList<Loan0>();
                while (rows.next()) loans.add(loan(rows));
                return loans.isEmpty() ? null : new Loan0.History(documentId, code, title, type, List.copyOf(loans));
            }
        }
    }

    public Loan0.Detail getLoanDetails(String loanCode, long documentId, DateRange0 range) throws SQLException {
        String header = LOAN_HEADER + " WHERE l.loanDate BETWEEN ? AND ? AND " + HAS_DOCUMENT + " AND l.loanCode = ?";
        String lines = """
            SELECT dc.copyCode, d.documentCode, d.title, ld.dueDate, ld.conditionOnLoan,
                   CASE WHEN ret.id IS NULL THEN 0 ELSE 1 END
            FROM tblLoanDetail0 ld
            JOIN tblDocumentCopy0 dc ON dc.id = ld.tblDocumentCopy0id
            JOIN tblImportDetail0 im ON im.id = dc.tblImportDetail0id
            JOIN tblDocument0 d ON d.id = im.tblDocument0id
            LEFT JOIN tblReturnDetail0 ret ON ret.tblLoanDetail0id = ld.id
            WHERE ld.tblLoan0id = ?
            ORDER BY ld.id
            """;
        try (Connection c = Database0.open(); PreparedStatement p = c.prepareStatement(header);
             PreparedStatement q = c.prepareStatement(lines)) {
            dates(p, range);
            p.setLong(3, documentId);
            p.setString(4, loanCode);
            Loan0 loan;
            try (ResultSet r = p.executeQuery()) {
                if (!r.next()) return null;
                loan = loan(r);
            }
            q.setLong(1, loan.id());
            try (ResultSet r = q.executeQuery()) {
                var items = new ArrayList<Loan0.Line>();
                while (r.next()) items.add(new Loan0.Line(r.getString(1), r.getString(2), r.getString(3),
                    r.getDate(4).toLocalDate(), r.getString(5), r.getInt(6) == 1));
                return new Loan0.Detail(loan, List.copyOf(items));
            }
        }
    }

    private static void dates(PreparedStatement p, DateRange0 range) throws SQLException {
        p.setDate(1, java.sql.Date.valueOf(range.from()));
        p.setDate(2, java.sql.Date.valueOf(range.to()));
    }

    private static Loan0 loan(ResultSet r) throws SQLException {
        return new Loan0(r.getLong(1), r.getString(2), r.getDate(3).toLocalDate(),
                         r.getString(4), r.getString(5), r.getString(6));
    }
}
