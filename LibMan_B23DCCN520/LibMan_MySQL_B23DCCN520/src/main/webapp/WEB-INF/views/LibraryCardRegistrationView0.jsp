<%@ page pageEncoding="UTF-8" %>
<% String boundary = "GDLibraryCardRegistration0"; %>
<%@ include file="head.jspf" %>
<%
Reader0.Form data = (Reader0.Form) request.getAttribute("form");
LibraryCard0 card = (LibraryCard0) request.getAttribute("card");
boolean created = Boolean.TRUE.equals(request.getAttribute("created"));
boolean existing = Boolean.TRUE.equals(request.getAttribute("existingCard"));
%>
<div class="hero"><h1>Đăng kí làm thẻ bạn đọc</h1>
<p><%= card == null && !existing ? "Kiểm tra thông tin cá nhân và chọn loại thẻ muốn đăng kí." : "Thông tin thẻ gắn với hồ sơ bạn đọc." %></p></div>
<% if (card != null) { %>
  <% if (created) { %><p class="notice success" role="status">Đăng kí thẻ bạn đọc thành công.</p><% } %>
  <section class="panel">
    <div class="feature"><h2>Thông tin thẻ bạn đọc</h2><span class="badge"><%= Html0.e(card.status()) %></span></div>
    <dl class="facts">
      <div><dt>Số thẻ</dt><dd><strong><%= Html0.e(card.cardNumber()) %></strong></dd></div>
      <div><dt>Họ tên bạn đọc</dt><dd><%= Html0.e(data.fullName()) %></dd></div>
      <div><dt>Loại thẻ</dt><dd><%= Html0.e(card.cardType()) %></dd></div>
      <div><dt>Ngày đăng kí</dt><dd><%= Html0.date(card.registrationDate()) %></dd></div>
      <div><dt>Ngày hết hạn</dt><dd><%= Html0.date(card.expirationDate()) %></dd></div>
    </dl>
  </section>
  <div class="actions"><a class="button secondary" href="<%= base %>/reader">Trang chủ bạn đọc</a></div>
<% } else if (!existing) { %>
<section class="panel">
  <h2>Thông tin cá nhân</h2>
  <form method="post" action="<%= base %>/reader/card">
    <input type="hidden" name="csrf" value="<%= csrf %>">
    <div class="fields">
      <label>Họ tên<input name="fullName" maxlength="100" required value="<%= Html0.e(data.fullName()) %>">
        <% if (errors.containsKey("fullName")) { %><small class="error"><%= Html0.e(errors.get("fullName")) %></small><% } %></label>
      <label>Ngày sinh<input name="dateOfBirth" type="date" required value="<%= Html0.e(data.dateOfBirth()) %>">
        <% if (errors.containsKey("dateOfBirth")) { %><small class="error"><%= Html0.e(errors.get("dateOfBirth")) %></small><% } %></label>
      <label class="wide">Địa chỉ<input name="address" maxlength="255" required value="<%= Html0.e(data.address()) %>">
        <% if (errors.containsKey("address")) { %><small class="error"><%= Html0.e(errors.get("address")) %></small><% } %></label>
      <label>Số điện thoại<input name="phoneNumber" type="tel" maxlength="20" required value="<%= Html0.e(data.phoneNumber()) %>">
        <% if (errors.containsKey("phoneNumber")) { %><small class="error"><%= Html0.e(errors.get("phoneNumber")) %></small><% } %></label>
      <label>Email<input name="email" type="email" maxlength="254" required value="<%= Html0.e(data.email()) %>">
        <% if (errors.containsKey("email")) { %><small class="error"><%= Html0.e(errors.get("email")) %></small><% } %></label>
      <label>Loại thẻ<select name="cardType" required><option value="">Chọn loại thẻ</option>
      <% for (String option : List.of(LibraryCard0.STUDENT, LibraryCard0.STANDARD)) { %>
        <option value="<%= Html0.e(option) %>"<%= option.equals(data.cardType()) ? " selected" : "" %>><%= Html0.e(option) %></option>
      <% } %></select>
      <% if (errors.containsKey("cardType")) { %><small class="error"><%= Html0.e(errors.get("cardType")) %></small><% } %></label>
    </div>
    <div class="actions"><button class="primary" type="submit">Thêm</button>
      <a class="button secondary" href="<%= base %>/reader">Hủy</a></div>
  </form>
</section>
<% } else { %>
  <div class="actions"><a class="button secondary" href="<%= base %>/reader">Trang chủ bạn đọc</a></div>
<% } %>
<%@ include file="foot.jspf" %>
