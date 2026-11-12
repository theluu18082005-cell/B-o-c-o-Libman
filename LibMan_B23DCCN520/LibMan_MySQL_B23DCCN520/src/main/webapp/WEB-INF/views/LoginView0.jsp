<%@ page pageEncoding="UTF-8" %>
<% String boundary = "GDLogin0"; %>
<%@ include file="head.jspf" %>
<section class="login">
  <div class="panel">
    <h1>Đăng nhập</h1>
    <form class="stack" method="post" action="<%= base %>/login">
      <input type="hidden" name="csrf" value="<%= csrf %>">
      <label>Tên đăng nhập<input name="username" autocomplete="username" maxlength="50" required value="<%= Html0.e(request.getAttribute("username")) %>"></label>
      <label>Mật khẩu<input name="password" type="password" autocomplete="current-password" maxlength="128" required></label>
      <button class="primary" type="submit">Đăng nhập</button>
    </form>
    <% if (Boolean.TRUE.equals(request.getAttribute("demo"))) { %>
    <div class="demo"><strong>Tài khoản demo</strong>
      <p>Bạn đọc: <code>bandoc</code> · Quản lí: <code>quanly</code></p>
      <p>Mật khẩu chung: <code>LibManDemo!2026</code></p>
    </div>
    <% } %>
  </div>
</section>
<%@ include file="foot.jspf" %>
