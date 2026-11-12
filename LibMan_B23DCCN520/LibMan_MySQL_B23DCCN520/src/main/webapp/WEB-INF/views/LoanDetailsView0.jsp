<%@ page pageEncoding="UTF-8" %>
<% String boundary = "GDLoanDetails0"; %>
<%@ include file="head.jspf" %>
<%
DateRange0 range = (DateRange0) request.getAttribute("range");
Loan0.Detail detail = (Loan0.Detail) request.getAttribute("detail");
Loan0 l = detail.loan();
%>
<div class="hero"><h1>Chi tiết phiếu mượn <%= Html0.e(l.loanCode()) %></h1></div>
<section class="panel"><h2>Thông tin chung</h2>
  <dl class="facts">
    <div><dt>Ngày mượn</dt><dd><%= Html0.date(l.loanDate()) %></dd></div>
    <div><dt>Mã bạn đọc</dt><dd><%= Html0.e(l.readerCode()) %></dd></div>
    <div><dt>Họ tên bạn đọc</dt><dd><%= Html0.e(l.readerName()) %></dd></div>
    <div><dt>Nhân viên lập phiếu</dt><dd><%= Html0.e(l.librarianName()) %></dd></div>
  </dl>
</section>
<section class="panel result">
  <h2>Danh sách bản tài liệu</h2>
  <div class="scroll"><table>
  <thead><tr><th>Mã bản</th><th>Mã tài liệu</th><th>Tên tài liệu</th><th>Hạn trả</th><th>Tình trạng khi mượn</th><th>Trạng thái mượn</th></tr></thead>
  <tbody>
    <% for (Loan0.Line row : detail.lines()) { %>
    <tr><td class="code"><%= Html0.e(row.copyCode()) %></td><td class="code"><%= Html0.e(row.documentCode()) %></td>
    <td><%= Html0.e(row.title()) %></td><td><%= Html0.date(row.dueDate()) %></td><td><%= Html0.e(row.conditionOnLoan()) %></td>
    <td><span class="badge<%= row.returned() ? "" : " muted" %>"><%= row.returned() ? "Đã trả" : "Đang mượn" %></span></td></tr>
    <% } %>
  </tbody></table></div>
</section>
<div class="actions"><a class="button secondary" href="<%= base %>/manager/history?document=<%= Html0.e(request.getAttribute("documentId")) %>&amp;from=<%= range.from() %>&amp;to=<%= range.to() %>">Quay lại</a></div>
<%@ include file="foot.jspf" %>
