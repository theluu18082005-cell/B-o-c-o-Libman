# Đối chiếu giao diện LibMan

Các tệp JSP nằm trong `src/main/webapp/WEB-INF/views`; lớp Servlet trong `src/main/java/vn/ptit/libman/web`; DAO và lớp dữ liệu nằm trong các gói `dao` và `model`.

| Giao diện hoặc thao tác | Pha phân tích trong báo cáo | Mã nguồn và dữ liệu |
|---|---|---|
| Đăng nhập | Tiền điều kiện ở 2.6.1–2.6.2, use case đăng nhập ở Hình 2.2–2.3 | `LoginView0.jsp` → POST `/login` → `LibManServlet0.login()` → `MemberDAO0.authenticate()`; về trang chủ theo vai trò. |
| Trang chủ bạn đọc | `GDReaderHome0`, Hình 2.5/2.7/2.8; kịch bản 2.0 bước 1–2 | `ReaderHomeView0.jsp`; liên kết đăng kí trong `head.jspf` → GET `/reader/card` → `card()`. Mục tìm kiếm hiển thị “Chưa cài đặt”; mượn/trả hiển thị “Tại quầy”, đúng phân công trong đề và use case tổng quan. |
| Biểu mẫu đăng kí | `GDLibraryCardRegistration0`, 2.8.1; bước 3–4 | `LibraryCardRegistrationView0.jsp`. `card()` dùng ID trong phiên gọi `ReaderDAO0.getReaderInformation()`. Họ tên, ngày sinh, địa chỉ, điện thoại, email: `Reader0.Form` / `tblMember0`. Hai loại thẻ: hằng `LibraryCard0.STUDENT`, `STANDARD`. Hủy: GET `/reader`, không gửi biểu mẫu. |
| Thêm và hiện thẻ | Hình 2.8, bước 5–8; nhánh lỗi 2.6.1 | POST `/reader/card` → `register()` → `getLibraryCard()`, `validateReaderInformation()`, `LibraryCardDAO0.registerLibraryCard()`. DAO cập nhật hồ sơ và lưu thẻ cùng giao dịch; servlet chuyển về GET `/reader/card`. JSP hiển thị thông báo, số thẻ, họ tên, loại, hai ngày và trạng thái từ `LibraryCard0` và hồ sơ. |
| Trang chủ quản lí và Chọn báo cáo | `GDManagerHome0` → `GDReportSelection0`, Hình 2.6/2.9/2.10; bước 1–4 | `ManagerHomeView0.jsp` và `head.jspf` → GET `/manager/reports` → `ReportSelectionView0.jsp`. Ba loại có trong đề; chỉ thống kê tài liệu liên kết GET `/manager/statistics`. |
| Ngày bắt đầu, ngày kết thúc, Xem thống kê | `GDDocumentStatistics0`, Hình 2.10, bước 5–10 | `DocumentStatisticsView0.jsp` gửi `from`, `to` → `statistics()` → `DateRange0.validateDateRange()` → `DocumentStatisticsDAO0.getDocumentBorrowingStatistics()`. `DocumentStatistics0` cấp mã, tên, loại, tác giả, số lần; STT do JSP đánh số. SQL đếm phiếu khác nhau theo đầu tài liệu và ngày lập phiếu. |
| Chọn tên tài liệu và xem lịch sử | `GDDocumentBorrowingHistory0`, Hình 2.10, bước 11–16 | Liên kết tên tài liệu → GET `/manager/history?document=…&from=…&to=…` → `history()` → `LoanDAO0.getDocumentBorrowingHistory()` → `DocumentBorrowingHistoryView0.jsp`. `Loan0.History` cho thông tin đầu tài liệu, danh sách; `Loan0` cho mã phiếu, ngày mượn, mã và tên bạn đọc. |
| Chọn mã phiếu và xem chi tiết | `GDLoanDetails0`, Hình 2.10, bước 17–22 | Liên kết mã phiếu → GET `/manager/loan?document=…&from=…&to=…&loan=…` → `loan()` → `LoanDAO0.getLoanDetails()` → `LoanDetailsView0.jsp`. `Loan0.Detail` gồm thông tin phiếu và các `Loan0.Line`: mã bản, mã/tên tài liệu, hạn trả, tình trạng khi mượn và trạng thái trả (tra `tblReturnDetail0`). |
| Quay lại | Các ngoại lệ 2.6.2, 2.8.2 và Hình 2.9 | Link cuối JSP: chi tiết → lịch sử mang `document/from/to`; lịch sử → thống kê mang `from/to`; thống kê → chọn báo cáo; chọn báo cáo → trang chủ quản lí. |
| Đăng xuất | Thao tác chung của phiên, ngoài hai luồng chính | Nút trong `head.jspf` → POST `/logout` → `LibManServlet0.doPost()` hủy phiên và về trang đăng nhập. |

## Cách đọc sơ đồ

Các sơ đồ phân tích giữ lớp biên `GD...` và lớp nghiệp vụ. Ở pha thiết kế, lớp biên được hiện thực bằng JSP; điều hướng, kiểm tra dữ liệu và gọi DAO thực hiện qua `LibManServlet0`. Phương thức nghiệp vụ được đặt ở DAO tương ứng, còn các record giữ dữ liệu hiển thị. Sơ đồ lớp và tuần tự trong `plantuml` thể hiện cách cài đặt này. Đăng nhập là tiền điều kiện trong hai sơ đồ tuần tự; mã đăng nhập và đăng xuất được đối chiếu ở bảng trên.

## Sơ đồ lớp chi tiết trong báo cáo

- **Hình 3.12 – Đăng kí làm thẻ bạn đọc**: [PlantUML](plantuml/01_Module1_Class.puml) · [Sơ đồ SVG](diagram_previews/01_Module1_Class.svg). Dữ liệu biểu mẫu là `Reader0.Form`; DAO đọc hồ sơ và cập nhật hồ sơ/thẻ qua cùng cơ sở dữ liệu.
- **Hình 3.13 – Thống kê tài liệu theo số lần mượn**: [PlantUML](plantuml/02_Module2_Class.puml) · [Sơ đồ SVG](diagram_previews/02_Module2_Class.svg). `DateRange0` kiểm tra khoảng ngày; các DAO trả dữ liệu theo từng màn hình. `Loan0.Detail` chứa tất cả các bản tài liệu trong phiếu.

Các sơ đồ thể hiện những thành phần được sử dụng trong hai luồng sau đăng nhập. `req` và `res` là `HttpServletRequest` và `HttpServletResponse`; tên hiển thị trong ô JSP là dữ liệu hoặc điều khiển của trang. Các record là dạng dữ liệu mà Java đọc hoặc trả cho giao diện. Các quan hệ nghiệp vụ và quan hệ giữa bảng tiếp tục được mô tả ở mục 3.1–3.2.

Trong Hình 3.12 và Hình 3.13, biểu tượng tệp ở đầu tên nhận biết trang JSP. Đường liền nối hai ô JSP biểu diễn việc chuyển màn hình qua liên kết trên giao diện; yêu cầu vẫn đi qua `LibManServlet0`, như các mũi tên nét đứt trên sơ đồ.

Trong hai sơ đồ lớp chi tiết, `Input`, `DateInput`, `Select`, `Table`, `link` và `submit` là kiểu thành phần giao diện. Các tên như `btnAdd` hoặc `tblStatistics` nhận diện thành phần trên sơ đồ; tên này không nhất thiết là ID trong HTML. Ví dụ, `from` và `to` là ô `DateInput` và được gửi dưới dạng chuỗi. Hai DAO của mỗi module dùng trực tiếp phương thức tĩnh `Database0.open()` để mở kết nối JDBC; mũi tên nét đứt đậm có nhãn `open()` thể hiện quan hệ phụ thuộc này.
