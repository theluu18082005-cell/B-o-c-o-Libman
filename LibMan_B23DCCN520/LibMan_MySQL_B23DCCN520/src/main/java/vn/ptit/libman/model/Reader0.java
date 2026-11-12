package vn.ptit.libman.model;

import java.time.LocalDate;

public record Reader0(long id, String readerCode, String fullName, LocalDate dateOfBirth,
                      String address, String phoneNumber, String email) {
    public record Form(String fullName, String dateOfBirth, String address,
                       String phoneNumber, String email, String cardType) {}
}
