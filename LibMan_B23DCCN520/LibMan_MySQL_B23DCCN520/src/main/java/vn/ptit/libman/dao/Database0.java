package vn.ptit.libman.dao;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.UUID;

public final class Database0 {
    private static final String URL = setting("LIBMAN_DB_URL");
    private static final String DEMO_URL = "jdbc:h2:mem:libman_" + UUID.randomUUID().toString().replace("-", "")
        + ";MODE=MSSQLServer;DATABASE_TO_UPPER=FALSE;CASE_INSENSITIVE_IDENTIFIERS=TRUE;DB_CLOSE_DELAY=-1";
    private static boolean initialized;

    private Database0() {}

    private static String setting(String key) {
        String value = System.getProperty(key);
        return value == null ? System.getenv(key) : value;
    }

    public static boolean isDemo() { return URL == null || URL.isBlank(); }
    public static boolean isMySql() { return URL != null && URL.startsWith("jdbc:mysql:"); }

    static void setUnicode(PreparedStatement statement, int index, String value) throws SQLException {
        if (isMySql()) statement.setString(index, value);
        else statement.setNString(index, value);
    }

    public static Connection open() throws SQLException {
        if (isDemo()) {
            initDemo();
            return DriverManager.getConnection(DEMO_URL, "sa", "");
        }
        if (isMySql()) loadDriver("com.mysql.cj.jdbc.Driver");
        else if (URL.startsWith("jdbc:sqlserver:")) loadDriver("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        else throw new SQLException("LIBMAN_DB_URL phải bắt đầu bằng jdbc:mysql: hoặc jdbc:sqlserver:.");
        String user = setting("LIBMAN_DB_USER"), pass = setting("LIBMAN_DB_PASSWORD");
        if (user == null || pass == null) {
            throw new SQLException("Thiếu LIBMAN_DB_USER hoặc LIBMAN_DB_PASSWORD.");
        }
        return DriverManager.getConnection(URL, user, pass);
    }

    private static void loadDriver(String name) throws SQLException {
        try { Class.forName(name); }
        catch (ClassNotFoundException ex) { throw new SQLException("Thiếu trình điều khiển JDBC.", ex); }
    }

    private static synchronized void initDemo() throws SQLException {
        if (initialized) return;
        loadDriver("org.h2.Driver");
        try (Connection conn = DriverManager.getConnection(DEMO_URL, "sa", "")) {
            try {
                script(conn, "/sql/01_schema.sql");
                script(conn, "/sql/02_seed.sql");
                initialized = true;
            } catch (SQLException | IOException ex) {
                try (Statement statement = conn.createStatement()) { statement.execute("DROP ALL OBJECTS"); }
                catch (SQLException cleanup) { ex.addSuppressed(cleanup); }
                throw new SQLException("Không khởi tạo được dữ liệu demo.", ex);
            }
        }
    }

    private static void script(Connection conn, String path) throws SQLException, IOException {
        try (InputStream input = Database0.class.getResourceAsStream(path)) {
            if (input == null) throw new FileNotFoundException(path);
            String sql = new String(input.readAllBytes(), StandardCharsets.UTF_8)
                .replaceAll("(?m)^\\s*--[^\\r\\n]*", "");
            try (Statement statement = conn.createStatement()) {
                for (String query : sql.split(";")) {
                    if (!query.isBlank()) statement.execute(query);
                }
            }
        }
    }
}
