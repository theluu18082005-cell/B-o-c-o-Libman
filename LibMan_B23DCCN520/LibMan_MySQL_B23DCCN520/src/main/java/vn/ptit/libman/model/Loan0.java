package vn.ptit.libman.model;

import java.time.LocalDate;
import java.util.List;

public record Loan0(long id, String loanCode, LocalDate loanDate, String readerCode,
                    String readerName, String librarianName) {
    public record Line(String copyCode, String documentCode, String title, LocalDate dueDate,
                       String conditionOnLoan, boolean returned) {}
    public record Detail(Loan0 loan, List<Line> lines) {}
    public record History(long documentId, String documentCode, String title,
                          String documentType, List<Loan0> loans) {}
}
