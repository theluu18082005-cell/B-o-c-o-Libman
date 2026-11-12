<%@ page pageEncoding="UTF-8" %>
<% String boundary = "GDDocumentStatistics0"; %>
<%@ include file="head.jspf" %>
<%
DateRange0 range = (DateRange0) request.getAttribute("range");
List<?> items = (List<?>) request.getAttribute("items");
String from = Html0.e(request.getAttribute("from")), to = Html0.e(request.getAttribute("to"));
%>
<div class="hero">
<h1>Thống kê tài liệu theo số lần mượn</h1><p>Thống kê theo ngày lập phiếu mượn, gồm cả tài liệu đã trả.</p></div>
<form class="panel filters" action="<%= base %>/manager/statistics" method="get">
  <label>Ngày bắt đầu<input name="from" type="date" value="<%= from %>" required>
  <% if (errors.containsKey("from")) { %><small class="error"><%= Html0.e(errors.get("from")) %></small><% } %></label>
  <label>Ngày kết thúc<input name="to" type="date" value="<%= to %>" required>
  <% if (errors.containsKey("to")) { %><small class="error"><%= Html0.e(errors.get("to")) %></small><% } %></label>
  <button class="primary" type="submit">Xem thống kê</button>
</form>
<section class="panel result">
  <div class="feature"><h2>Kết quả thống kê</h2>
    <% if (range != null) { %><span class="badge"><%= Html0.date(range.from()) %> – <%= Html0.date(range.to()) %></span><% } %></div>
  <div class="scroll"><table>
  <thead><tr><th>STT</th><th>Mã tài liệu</th><th>Tên tài liệu</th><th>Loại tài liệu</th><th>Tác giả</th><th class="num">Số lần mượn</th></tr></thead>
  <tbody>
  <% if (items == null || items.isEmpty()) { %>
  <tr><td colspan="6" class="empty"><%= items == null ? "Kết quả sẽ xuất hiện ở đây sau khi thống kê." : "Không có dữ liệu mượn tài liệu trong khoảng thời gian đã chọn." %></td></tr>
  <% } else { int i=0; for (Object row : items) { DocumentStatistics0 s = (DocumentStatistics0) row; %>
  <tr><td><%= ++i %></td><td class="code"><%= Html0.e(s.documentCode()) %></td>
    <td><a href="<%= base %>/manager/history?document=<%= s.documentId() %>&amp;from=<%= from %>&amp;to=<%= to %>"><%= Html0.e(s.title()) %></a></td>
    <td><%= Html0.e(s.documentType()) %></td><td><%= Html0.e(s.author()) %></td><td class="num"><strong><%= s.borrowCount() %></strong></td></tr>
  <% }} %>
  </tbody></table></div>
</section>
<div class="actions"><a class="button secondary" href="<%= base %>/manager/reports">Quay lại</a></div>
<%@ include file="foot.jspf" %>
