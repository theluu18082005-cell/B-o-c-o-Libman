<%@ page pageEncoding="UTF-8" %>
<% String boundary = "GDReportSelection0"; %>
<%@ include file="head.jspf" %>
<h1>Chọn báo cáo</h1>
<ul class="report-list">
  <li><a class="enabled" href="<%= base %>/manager/statistics">Thống kê tài liệu theo số lần mượn</a></li>
  <li><span>Thống kê bạn đọc theo số lần mượn</span><small>Chưa cài đặt</small></li>
  <li><span>Thống kê nhà cung cấp theo số lượng tài liệu nhập</span><small>Chưa cài đặt</small></li>
</ul>
<div class="actions"><a class="button secondary" href="<%= base %>/manager">Quay lại</a></div>
<%@ include file="foot.jspf" %>
