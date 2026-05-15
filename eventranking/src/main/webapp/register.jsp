<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Register — Smart Campus Notice Board</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<div class="auth-page">
  <div class="auth-card" style="max-width:500px;">

    <div class="auth-card__logo">
      <div class="auth-card__logo-icon">🎓</div>
      <h1 class="auth-card__title">Create Account</h1>
      <p class="auth-card__sub">Join the Smart Campus Notice Board</p>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/register" method="POST" data-validate>

      <!-- Full Name -->
      <div class="form-group">
        <label class="form-label" for="name">Full Name <span class="required">*</span></label>
        <input type="text" id="name" name="name" class="form-control"
               placeholder="e.g. Aarav Sharma"
               value="${param.name}" required/>
        <div class="form-error" style="display:none"></div>
      </div>

      <!-- Email -->
      <div class="form-group">
        <label class="form-label" for="email">Email Address <span class="required">*</span></label>
        <input type="email" id="email" name="email" class="form-control"
               placeholder="you@campus.edu"
               value="${param.email}" required/>
        <div class="form-hint">Use your official campus email address.</div>
        <div class="form-error" style="display:none"></div>
      </div>

      <!-- Password -->
      <div class="form-group">
        <label class="form-label" for="password">Password <span class="required">*</span></label>
        <input type="password" id="password" name="password" class="form-control"
               placeholder="Minimum 8 characters" required minlength="8"/>
        <div class="form-hint">Use at least 8 characters with a mix of letters and numbers.</div>
        <div class="form-error" style="display:none"></div>
      </div>

      <!-- Confirm Password -->
      <div class="form-group">
        <label class="form-label" for="confirmPassword">Confirm Password <span class="required">*</span></label>
        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
               placeholder="Re-enter your password" required/>
        <div class="form-error" style="display:none"></div>
      </div>

      <!-- Role (hidden — always student on self-registration) -->
      <input type="hidden" name="role" value="student"/>

      <!-- Terms -->
      <div class="form-group" style="margin-bottom:20px;">
        <label style="display:flex;align-items:flex-start;gap:8px;cursor:pointer;font-size:.875rem;color:var(--text-secondary);">
          <input type="checkbox" name="terms" required style="margin-top:3px;"/>
          I agree to the <a href="#" style="margin-left:4px;">Terms of Use</a>&nbsp;and
          <a href="#">Privacy Policy</a>.
        </label>
      </div>

      <button type="submit" class="btn btn--primary btn--full btn--lg">
        Create Account →
      </button>

    </form>

    <div class="auth-divider">or</div>

    <p class="text-center text-sm">
      Already have an account?
      <a href="${pageContext.request.contextPath}/login.jsp" style="font-weight:600;">Sign in</a>
    </p>

  </div>
</div>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
  // Client-side password match check
  document.querySelector('form').addEventListener('submit', function(e) {
    const pw  = document.getElementById('password').value;
    const cpw = document.getElementById('confirmPassword').value;
    if (pw !== cpw) {
      e.preventDefault();
      const errEl = document.getElementById('confirmPassword').closest('.form-group').querySelector('.form-error');
      document.getElementById('confirmPassword').classList.add('error');
      if (errEl) { errEl.textContent = 'Passwords do not match.'; errEl.style.display = 'flex'; }
    }
  });
</script>
</body>
</html>

