package vn.ptit.libman.dao;

import vn.ptit.libman.model.*;
import java.sql.*;
import java.util.*;

public final class DocumentStatisticsDAO0 {
    public List<DocumentStatistics0> getDocumentBorrowingStatistics(DateRange0 range) throws SQLException {
        String sql = """
            SELECT d.id, d.documentCode, d.title, d.documentType, d.author,
                   COUNT(DISTINCT l.id) AS borrowCount
            FROM tblLoan0 l
            JOIN tblLoanDetail0 ld ON ld.tblLoan0id = l.id
            JOIN tblDocumentCopy0 dc ON dc.id = ld.tblDocumentCopy0id
            JOIN tblImportDetail0 im ON im.id = dc.tblImportDetail0id
            JOIN tblDocument0 d ON d.id = im.tblDocument0id
            WHERE l.loanDate BETWEEN ? AND ?
            GROUP BY d.id, d.documentCode, d.title, d.documentType, d.author
            ORDER BY borrowCount DESC, d.documentCode ASC
            """;
        try (Connection c = Database0.open(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setDate(1, java.sql.Date.valueOf(range.from()));
            p.setDate(2, java.sql.Date.valueOf(range.to()));
            try (ResultSet r = p.executeQuery()) {
                var items = new ArrayList<DocumentStatistics0>();
                while (r.next()) items.add(new DocumentStatistics0(r.getLong(1), r.getString(2), r.getString(3),
                                                                   r.getString(4), r.getString(5), r.getInt(6)));
                return List.copyOf(items);
            }
        }
    }
}
