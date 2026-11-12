<%@ page pageEncoding="UTF-8" %>
<% String boundary = "GDDocumentBorrowingHistory0"; %>
<%@ include file="head.jspf" %>
<%
DateRange0 range = (DateRange0) request.getAttribute("range");
Loan0.History history = (Loan0.History) request.getAttribute("history");
String dates = "from=" + range.from() + "&amp;to=" + range.to();
%>
<div class="hero">
  <h1>Lịch sử mượn tài liệu</h1><p><strong><%= Html0.e(history.documentCode()) %></strong> · <%= Html0.e(history.title()) %> · <%= Html0.e(history.documentType()) %></p></div>
<section class="panel">
  <div class="feature"><div><h2>Danh sách phiếu mượn</h2><p><%= Html0.date(range.from()) %> – <%= Html0.date(range.to()) %></p></div>
    <span class="badge"><%= history.loans().size() %> lần mượn</span></div>
  <div class="scroll"><table>
  <thead><tr><th>STT</th><th>Mã phiếu mượn</th><th>Ngày mượn</th><th>Mã bạn đọc</th><th>Họ tên bạn đọc</th></tr></thead>
  <tbody>
    <% int i=0; for (Loan0 l : history.loans()) { %>
    <tr><td><%= ++i %></td><td class="code"><a href="<%= base %>/manager/loan?document=<%= history.documentId() %>&amp;<%= dates %>&amp;loan=<%= Html0.e(Html0.query(l.loanCode())) %>"><%= Html0.e(l.loanCode()) %></a></td>
      <td><%= Html0.date(l.loanDate()) %></td><td class="code"><%= Html0.e(l.readerCode()) %></td><td><%= Html0.e(l.readerName()) %></td></tr>
    <% } %>
  </tbody></table></div>
</section>
<div class="actions"><a class="button secondary" href="<%= base %>/manager/statistics?<%= dates %>">Quay lại</a></div>
<%@ include file="foot.jspf" %>
