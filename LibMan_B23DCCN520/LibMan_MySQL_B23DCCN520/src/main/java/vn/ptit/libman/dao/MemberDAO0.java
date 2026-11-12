package vn.ptit.libman.dao;

import vn.ptit.libman.model.Member0;
import java.sql.*;
import java.security.*;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public final class MemberDAO0 {
    public Member0 authenticate(String username, String password) throws SQLException {
        if (username == null || password == null || username.isBlank()
                || username.length() > 50 || password.length() > 128) return null;
        String sql = """
            SELECT m.id, m.fullName, m.%s AS passwordHash, r.tblMember0id AS readerId,
                   g.tblEmployee0id AS managerId
            FROM tblMember0 m
            LEFT JOIN tblReader0 r ON r.tblMember0id = m.id
            LEFT JOIN tblManager0 g ON g.tblEmployee0id = m.id
            WHERE m.username = ?
            """.formatted(Database0.isMySql() ? "`password`" : "[password]");
        try (Connection c = Database0.open(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, username.trim());
            try (ResultSet r = p.executeQuery()) {
                if (!r.next() || !matches(password, r.getString("passwordHash"))) return null;
                var role = r.getObject("managerId") != null ? Member0.Role.MANAGER
                         : r.getObject("readerId") != null ? Member0.Role.READER : null;
                return role == null ? null : new Member0(r.getLong("id"), r.getString("fullName"), role);
            }
        }
    }

    static boolean matches(String password, String encoded) throws SQLException {
        if (encoded == null) return false;
        String[] p = encoded.split("\\$", -1);
        if (p.length != 4 || !"pbkdf2".equals(p[0])) return false;
        try {
            int rounds = Integer.parseInt(p[1]);
            if (rounds < 100_000 || rounds > 1_000_000) return false;
            Base64.Decoder b64 = Base64.getDecoder();
            byte[] salt = b64.decode(p[2]), expected = b64.decode(p[3]);
            if (salt.length < 16 || expected.length != 32) return false;
            var spec = new PBEKeySpec(password.toCharArray(), salt, rounds, 256);
            try {
                byte[] derived = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
                return MessageDigest.isEqual(derived, expected);
            } finally { spec.clearPassword(); }
        } catch (IllegalArgumentException ex) {
            return false;
        } catch (GeneralSecurityException ex) {
            throw new SQLException("Không xác thực được mật khẩu.", ex);
        }
    }
}
