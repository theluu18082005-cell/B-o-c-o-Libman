<%@ page pageEncoding="UTF-8" %>
<% String boundary = "GDManagerHome0"; %>
<%@ include file="head.jspf" %>
<h1>Trang chủ nhân viên quản lí</h1>
<p>Xin chào, <strong><%= Html0.e(account.fullName()) %></strong>.</p>
<p>Chọn <strong>Xem báo cáo</strong> để xem danh sách báo cáo thư viện.</p>
<%@ include file="foot.jspf" %>
