package vn.ptit.libman;

import vn.ptit.libman.dao.Database0;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

final class LocalMySqlSetup0 {
    private static final String SCHEMA = "libman_b23dccn520";
    private static final String SERVER = "jdbc:mysql://localhost:3306/";
    private static final String TARGET = SERVER + SCHEMA;
    private static final Path SCRIPT = Path.of("sql", "mysql", "libman_mysql.sql");

    private LocalMySqlSetup0() {}

    static void runIfRequested() throws IOException, SQLException, ClassNotFoundException {
        if (!"1".equals(System.getenv("LIBMAN_MYSQL_SETUP"))) return;

        String url = System.getenv("LIBMAN_DB_URL");
        if (url == null || !(url.equals(TARGET) || url.startsWith(TARGET + "?"))) {
            throw new IllegalArgumentException("Automatic setup is limited to the local LibMan schema on port 3306.");
        }
        if (isReady()) {
            System.out.println("MySQL schema already ready: " + SCHEMA);
            return;
        }

        String user = System.getenv("LIBMAN_DB_USER");
        String password = System.getenv("LIBMAN_DB_PASSWORD");
        if (user == null || password == null) {
            throw new IllegalArgumentException("Missing the MySQL username or password.");
        }
        Class.forName("com.mysql.cj.jdbc.Driver");
        String serverUrl = SERVER + url.substring(TARGET.length());
        System.out.println("Setting up MySQL schema: " + SCHEMA);
        try (Connection connection = DriverManager.getConnection(serverUrl, user, password)) {
            executeScript(connection, SCRIPT);
        }
        if (!isReady()) throw new SQLException("LibMan schema or demo accounts are missing after setup.");
    }

    private static boolean isReady() throws SQLException {
        String check = """
            SELECT (
                SELECT COUNT(*) FROM information_schema.tables
                WHERE table_schema = DATABASE() AND LOWER(table_name) IN (
                    'tblmember0', 'tblemployee0', 'tblreader0', 'tblmanager0', 'tbllibrarian0',
                    'tbllibrarycard0', 'tbldocument0', 'tblloan0', 'tblreturnreceipt0', 'tblsupplier0',
                    'tblimportreceipt0', 'tblimportdetail0', 'tbldocumentcopy0', 'tblloandetail0',
                    'tblreturndetail0'
                )
            ), (
                SELECT COUNT(*) FROM tblMember0 WHERE username IN ('bandoc', 'quanly')
            )
            """;
        try (var db = Database0.open();
             var statement = db.prepareStatement(check);
             var rows = statement.executeQuery()) {
            return rows.next() && rows.getInt(1) == 15 && rows.getInt(2) == 2;
        } catch (SQLException e) {
            if (e.getErrorCode() == 1049 || e.getErrorCode() == 1146) return false;
            throw e;
        }
    }

    // This bundled script uses one semicolon-terminated statement at a time,
    // with SQL comments on separate lines and no semicolons inside literals.
    private static void executeScript(Connection db, Path script) throws IOException, SQLException {
        try (var input = Files.newBufferedReader(script, StandardCharsets.UTF_8);
             var statement = db.createStatement()) {
            var sql = new StringBuilder();
            int number = 0;
            for (String line; (line = input.readLine()) != null;) {
                String trimmed = line.strip();
                if (trimmed.isEmpty() || trimmed.startsWith("--")) continue;
                sql.append(line).append('\n');
                if (trimmed.endsWith(";")) {
                    try {
                        statement.execute(sql.toString());
                    } catch (SQLException e) {
                        throw new SQLException("MySQL setup stopped at statement " + (number + 1) + ".",
                            e.getSQLState(), e.getErrorCode(), e);
                    }
                    sql.setLength(0);
                    number++;
                }
            }
            if (!sql.toString().isBlank()) throw new IOException("MySQL script ends with an incomplete statement.");
        }
    }
}
