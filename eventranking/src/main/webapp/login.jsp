<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login — Smart Campus Notice Board</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<div class="auth-page">
  <div class="auth-card">

    <!-- Logo -->
    <div class="auth-card__logo">
      <div class="auth-card__logo-icon">📋</div>
      <h1 class="auth-card__title">Welcome Back</h1>
      <p class="auth-card__sub">Sign in to Smart Campus Notice Board</p>
    </div>

    <!-- Server-side error / success messages -->
    <c:if test="${not empty error}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${error}</div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${success}</div>
    </c:if>

    <!-- Login Form -->
    <form action="${pageContext.request.contextPath}/login" method="POST" data-validate>

      <div class="form-group">
        <label class="form-label" for="email">Email Address <span class="required">*</span></label>
        <input type="email"
               id="email"
               name="email"
               class="form-control"
               placeholder="you@campus.edu"
               value="${param.email}"
               required
               autocomplete="email"/>
        <div class="form-error" style="display:none"></div>
      </div>

      <div class="form-group">
        <label class="form-label" for="password">Password <span class="required">*</span></label>
        <input type="password"
               id="password"
               name="password"
               class="form-control"
               placeholder="Enter your password"
               required
               autocomplete="current-password"/>
        <div class="form-error" style="display:none"></div>
      </div>

      <div class="flex-between mb-4" style="font-size:.85rem;">
        <label style="display:flex;align-items:center;gap:6px;cursor:pointer;">
          <input type="checkbox" name="rememberMe"/> Remember me
        </label>
        <a href="${pageContext.request.contextPath}/forgot-password.jsp">Forgot password?</a>
      </div>

      <button type="submit" class="btn btn--primary btn--full btn--lg">
        Sign In →
      </button>

    </form>

    <div class="auth-divider">or</div>

    <p class="text-center text-sm">
      Don't have an account?
      <a href="${pageContext.request.contextPath}/register.jsp" style="font-weight:600;">Create one free</a>
    </p>

  </div><!-- /.auth-card -->
</div><!-- /.auth-page -->

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

