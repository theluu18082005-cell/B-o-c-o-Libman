# LibMan — B23DCCN520

Bộ mã nguồn cho hai module trong báo cáo: **Đăng kí làm thẻ bạn đọc** và **Thống kê tài liệu theo số lần mượn**. Dự án dùng Java 17+, Jakarta Servlet, JSP, JDBC và Maven. Có thể kết nối MySQL 8.0 hoặc SQL Server; chế độ demo dùng H2 trong bộ nhớ.

## Chạy LibMan với MySQL trên Windows

1. Giải nén ZIP và mở thư mục `LibMan_MySQL_B23DCCN520` có `pom.xml`. Dừng LibMan cũ nếu đang chiếm cổng 8080. Đảm bảo kết nối **Local instance MySQL80** trong Workbench mở được.
2. Nhấp đúp **`RUN_LIBMAN_MYSQL.cmd`**, hoặc ở PowerShell trong thư mục này chạy `.\RUN_LIBMAN_MYSQL.cmd`. Bộ chạy tìm Maven trong PATH hoặc bản Maven 3.10.0 đã giải nén trong thư mục TEMP. Dự án cần JDK 17 trở lên.
3. Nhập mật khẩu MySQL của tài khoản `root` khi được hỏi. Lần đầu bộ chạy dùng `sql/mysql/libman_mysql.sql` để tạo schema riêng và dữ liệu mẫu trên MySQL. Nếu schema và tài khoản mẫu đã có, ứng dụng dùng lại dữ liệu hiện tại.
4. Khi cửa sổ hiện `MySQL OK: libman_b23dccn520` và địa chỉ của LibMan, giữ cửa sổ đó mở và vào [trang đăng nhập](http://localhost:8080/libman/login). Tài khoản web: `bandoc` hoặc `quanly`, mật khẩu chung `LibManDemo!2026`.

Trong Workbench, bấm làm mới **SCHEMAS** để thấy kho `libman_b23dccn520`. Dữ liệu đăng ký thẻ được lưu trong kho này. File SQL trong project dùng để tạo lại cấu trúc và dữ liệu mẫu.

Nếu máy chưa có Maven, tải bản Binary ZIP từ [Apache Maven](https://maven.apache.org/download.cgi), giải nén và thêm thư mục `bin` vào PATH. Nếu đã tải Maven 3.10.0 theo hướng dẫn trước, bộ chạy dùng lại bản đó.

## Cài MySQL thủ công nếu không dùng bộ chạy

1. Trong MySQL Workbench, mở **Local instance MySQL80** ở `localhost:3306`.
2. Chọn **File → Open SQL Script**, mở `sql/mysql/libman_mysql.sql` trong project. Bỏ chọn đoạn văn bản nếu có, rồi bấm **tia sét đầu tiên** trên thanh của tab SQL để chạy toàn bộ. Script tạo cơ sở dữ liệu riêng `libman_b23dccn520`, 15 bảng và dữ liệu mẫu. Kết quả cuối `so_tai_khoan_mau = 2` xác nhận hai tài khoản mẫu đã có.
3. Trong VS Code, dừng LibMan cũ bằng **Ctrl+C**. Ở Terminal PowerShell tại thư mục có `pom.xml`, nhập các lệnh dưới đây. Khi Terminal hỏi, nhập mật khẩu MySQL của tài khoản `root` (mật khẩu không hiện khi gõ).

```powershell
$env:LIBMAN_DB_URL = 'jdbc:mysql://localhost:3306/libman_b23dccn520?characterEncoding=UTF-8&sslMode=PREFERRED&allowPublicKeyRetrieval=true'
$env:LIBMAN_DB_USER = 'root'
$pw = Read-Host 'Mat khau root MySQL' -AsSecureString
$env:LIBMAN_DB_PASSWORD = [System.Net.NetworkCredential]::new('', $pw).Password
mvn test-compile exec:java
```

Nếu đang dùng Maven giải nén từ lần chạy trước và lệnh `mvn` chưa có trong PATH, thay dòng cuối bằng:

```powershell
& "$env:TEMP\apache-maven-3.10.0\bin\mvn.cmd" test-compile exec:java
```

Khi thấy `MySQL OK: libman_b23dccn520`, giữ Terminal chạy và mở [trang đăng nhập LibMan](http://localhost:8080/libman/login). Đăng nhập trang web bằng `bandoc` hoặc `quanly`, mật khẩu chung `LibManDemo!2026`. Tài khoản MySQL chỉ dùng để kết nối cơ sở dữ liệu.

URL mẫu dành cho MySQL chạy ngay trên máy này. Để kiểm tra thẻ đã lưu, trong Workbench chạy `SELECT * FROM libman_b23dccn520.tblLibraryCard0;`. Dữ liệu MySQL vẫn còn khi dừng LibMan. Chạy lại script không xóa dữ liệu đã lưu hoặc ghi đè hồ sơ. Sau khi dừng app có thể xóa mật khẩu khỏi Terminal bằng `Remove-Item Env:LIBMAN_DB_PASSWORD`, hoặc đóng Terminal.

## Chạy demo để chụp giao diện

1. Giải nén và mở thư mục có `pom.xml` trong NetBeans (File → Open Project), hoặc mở PowerShell ở thư mục đó.
2. Cài JDK 17 trở lên và Maven, kiểm tra bằng `java -version` và `mvn -version`. Lần đầu Maven cần tải các thư viện.
3. Chạy lệnh dưới đây. Lệnh này tự khởi động Tomcat nên không cần cài Tomcat riêng.

```powershell
mvn test-compile exec:java
```

4. Mở [http://localhost:8080/libman/login](http://localhost:8080/libman/login).

| Vai trò | Tài khoản | Mật khẩu demo |
|---|---|---|
| Bạn đọc | `bandoc` | `LibManDemo!2026` |
| Nhân viên quản lí | `quanly` | `LibManDemo!2026` |

- **Module 1:** Đăng nhập bằng `bandoc` → chọn **Đăng kí làm thẻ bạn đọc** → kiểm tra hồ sơ được điền sẵn → chọn **Sinh viên** → bấm **Thêm**. Giao diện hiển thị thẻ **TBD001**. Mở lại chức năng sẽ thấy thẻ đã tạo. Dừng và chạy lại demo để bắt đầu từ trạng thái chưa có thẻ.
- **Module 2:** Đăng xuất rồi đăng nhập bằng `quanly` → **Xem báo cáo** → **Thống kê tài liệu theo số lần mượn**. Nhập **01/08/2026–31/08/2026**. Kết quả mẫu: TL001 = 3, TL002 = 2, TL003 = 1. Mở **Lập trình hướng đối tượng** rồi chọn **PM008** để xem cả ba bản BTL001, BTL002 và BTL010.
- Nếu cổng 8080 đã được sử dụng, thêm `"-Dlibman.port=8081"` vào lệnh và mở cổng 8081.

## Kết nối SQL Server (tuỳ chọn)

1. Trong SSMS, tạo một cơ sở dữ liệu mới, ví dụ `LibMan0`, rồi chọn nó trong ô Database của cửa sổ truy vấn.
2. Mở và chạy lần lượt hai tệp `src/main/resources/sql/01_schema.sql` và `src/main/resources/sql/02_seed.sql`. Tệp dữ liệu mẫu được thiết kế cho cơ sở dữ liệu mới khởi tạo, chỉ chạy một lần. Lưu tệp ở UTF-8 để giữ nguyên tiếng Việt.
3. Bật kết nối TCP/IP của instance SQL Server và xác nhận cổng đang dùng. Đặt các biến môi trường trong **cùng cửa sổ PowerShell** trước khi chạy ứng dụng. Thay tên đăng nhập, mật khẩu và cổng theo SQL Server của bạn.

```powershell
$env:LIBMAN_DB_URL = 'jdbc:sqlserver://localhost:1433;databaseName=LibMan0;encrypt=true;trustServerCertificate=true'
$env:LIBMAN_DB_USER = 'tai_khoan_sql_cua_ban'
$env:LIBMAN_DB_PASSWORD = 'mat_khau_sql_cua_ban'
mvn test-compile exec:java
```

Ví dụ chấp nhận chứng chỉ tự ký để chạy SQL Server cục bộ. Dữ liệu lưu qua chế độ SQL Server được giữ khi khởi động lại. Để quay về H2, dừng ứng dụng và xóa các biến trên, ví dụ `Remove-Item Env:LIBMAN_DB_URL`.

## Các phần dùng để viết Chương 4 Cài đặt

| Nội dung | Mã nguồn |
|---|---|
| Tổ chức dự án, dữ liệu mẫu và kết nối | `pom.xml`, `sql/mysql/libman_mysql.sql`, `src/main/resources/sql`, `dao/Database0.java` |
| Đăng nhập và phân quyền | `dao/MemberDAO0.java`, `web/LibManServlet0.java`, `LoginView0.jsp` |
| Đăng kí thẻ | `dao/ReaderDAO0.java`, `dao/LibraryCardDAO0.java`, `ReaderHomeView0.jsp`, `LibraryCardRegistrationView0.jsp`; thao tác Thêm do servlet xử lí |
| Thống kê và xem phiếu | `dao/DocumentStatisticsDAO0.java`, `dao/LoanDAO0.java`, năm trang JSP từ `ManagerHomeView0.jsp` đến `LoanDetailsView0.jsp` |
| Kiểm thử | `src/test/java/vn/ptit/libman/LibManTest.java` |

Các gói Java ở `src/main/java/vn/ptit/libman`; giao diện ở `src/main/webapp/WEB-INF/views`; CSS ở `src/main/webapp/assets`. SQL dùng 15 bảng và tên khóa ngoại kiểu `tblReader0id` như sơ đồ.

Khi tạo thẻ, cập nhật hồ sơ và thêm thẻ chạy trong một giao dịch. Cột `tblReader0id` duy nhất ngăn tạo thêm thẻ cho cùng bạn đọc. Ngày đăng kí lấy ngày hiện tại; bản demo đặt thời hạn một năm cho thẻ Sinh viên theo ví dụ trong báo cáo và sáu tháng cho thẻ Phổ thông. Hai báo cáo còn lại hiện trên màn chọn báo cáo nhưng không thuộc phạm vi cài đặt.

Thống kê lọc theo ngày lập phiếu, gồm cả hai ngày biên và tài liệu đã trả. Mỗi phiếu chỉ tính một lần cho một đầu tài liệu. Lịch sử giữ cùng khoảng ngày; chi tiết phiếu hiển thị tất cả bản trong phiếu, kể cả bản thuộc đầu tài liệu khác.

## Kiểm thử và đóng gói

Chạy kiểm thử trên H2: mở PowerShell chưa đặt `LIBMAN_DB_URL` và chạy `mvn test`. Bộ kiểm thử có các ca kiểm tra đăng nhập và quyền truy cập, tạo thẻ, lỗi nhập, trùng thẻ, hoàn tác khi lỗi lưu, lọc theo ngày và xem toàn bộ chi tiết phiếu.

Đóng gói: `mvn package` tạo `target/libman.war`. Có thể đưa WAR vào thư mục `webapps` của Tomcat 10.1 chạy bằng JDK 17 trở lên. Nếu đóng gói trong môi trường đã đặt `LIBMAN_DB_URL`, dùng `mvn -DskipTests package` để kiểm thử không chạy với dữ liệu thật.

## Đối chiếu giao diện với báo cáo

Xem [bảng đối chiếu](docs/DOI_CHIEU_GIAO_DIEN.md) và các biểu đồ thiết kế trong `docs/plantuml`. Tên GD trên thanh tiêu đề là tên lớp biên ở pha phân tích; JSP tương ứng là phần hiện thực giao diện trong dự án. Trên trang bạn đọc, Tìm kiếm tài liệu được liệt kê theo đề; mượn và trả được thực hiện trực tiếp tại quầy. Hai báo cáo ngoài module thống kê tài liệu chỉ xuất hiện trong danh sách theo đề.
