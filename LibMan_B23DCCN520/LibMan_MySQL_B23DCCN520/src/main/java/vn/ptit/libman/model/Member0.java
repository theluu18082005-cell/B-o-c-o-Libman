package vn.ptit.libman.model;

public record Member0(long id, String fullName, Role role) {
    public enum Role { READER, MANAGER }
}
