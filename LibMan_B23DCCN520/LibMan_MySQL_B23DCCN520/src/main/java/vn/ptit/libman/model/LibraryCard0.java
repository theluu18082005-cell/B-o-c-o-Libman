package vn.ptit.libman.model;

import java.time.LocalDate;

public record LibraryCard0(String cardNumber, String cardType, LocalDate registrationDate,
                           LocalDate expirationDate, String status) {
    public static final String STUDENT = "Sinh viên";
    public static final String STANDARD = "Phổ thông";
}
