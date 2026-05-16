<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Create Event — Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<c:if test="${sessionScope.userRole != 'admin'}">
  <c:redirect url="/login.jsp"/>
</c:if>

<div class="admin-layout">

  <%-- Sidebar --%>
  <aside class="admin-sidebar">
    <div class="admin-sidebar__logo">⚙️ Admin Panel</div>
    <nav class="admin-sidebar__nav">
      <div class="admin-sidebar__section-title">Overview</div>
      <a href="${pageContext.request.contextPath}/admin/dashboard"><span class="icon">📊</span> Dashboard</a>
      <a href="${pageContext.request.contextPath}/admin/analytics"><span class="icon">📈</span> Analytics</a>
      <div class="admin-sidebar__section-title">Events</div>
      <a href="${pageContext.request.contextPath}/admin/events"><span class="icon">📋</span> All Events</a>
      <a href="${pageContext.request.contextPath}/admin/events?filter=pending"><span class="icon">⏳</span> Pending</a>
      <a href="${pageContext.request.contextPath}/admin/events/create" class="active"><span class="icon">➕</span> Create Event</a>
      <div class="admin-sidebar__section-title">Users</div>
      <a href="${pageContext.request.contextPath}/admin/users"><span class="icon">👥</span> Manage Users</a>
      <div class="admin-sidebar__section-title">Settings</div>
      <a href="${pageContext.request.contextPath}/home.jsp"><span class="icon">🏠</span> View Site</a>
      <a href="${pageContext.request.contextPath}/logout"><span class="icon">🚪</span> Sign Out</a>
    </nav>
  </aside>

  <div class="admin-main">

    <div class="page-header__breadcrumb">
      <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
      <span>›</span> <span>Create Event</span>
    </div>

    <div class="flex-between mb-6" style="flex-wrap:wrap;gap:12px;">
      <div>
        <h1 style="font-size:1.4rem;font-weight:800;">➕ Create New Event</h1>
        <p style="font-size:.875rem;color:var(--text-muted);margin-top:2px;">
          Admin-created events are automatically approved and go live immediately.
        </p>
      </div>
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn--ghost">← Back</a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${error}</div>
    </c:if>

    <div class="card">
      <div class="card__header"><h3 style="font-size:.95rem;">Event Details</h3></div>
      <div class="card__body">

        <form action="${pageContext.request.contextPath}/admin/events/create"
              method="POST" data-validate>

          <div class="form-group">
            <label class="form-label">Event Title <span class="required">*</span></label>
            <input type="text" name="title" class="form-control"
                   placeholder="e.g. Annual Tech Fest 2025"
                   value="${param.title}" data-maxlength="150" required/>
          </div>

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
            <div class="form-group">
              <label class="form-label">Category <span class="required">*</span></label>
              <select name="category" class="form-control" required>
                <option value="">— Select —</option>
                <option value="Campus Event">🎓 Campus Event</option>
                <option value="Workshop">🔧 Workshop</option>
                <option value="Competition">🏆 Competition</option>
                <option value="Internship">💼 Internship</option>
                <option value="Club Activity">🎭 Club Activity</option>
                <option value="Seminar">📖 Seminar</option>
                <option value="Other">📌 Other</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">Event Date <span class="required">*</span></label>
              <input type="date" name="eventDate" class="form-control"
                     value="${param.eventDate}" min="${today}" required/>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Location <span class="required">*</span></label>
            <input type="text" name="location" class="form-control"
                   placeholder="e.g. Main Auditorium, Block A"
                   value="${param.location}" required/>
          </div>

          <div class="form-group">
            <label class="form-label">Description <span class="required">*</span></label>
            <textarea name="description" class="form-control"
                      placeholder="Full event description…"
                      data-maxlength="1000" required>${param.description}</textarea>
          </div>

          <div class="form-group">
            <label class="form-label">Contact Email <em>(optional)</em></label>
            <input type="email" name="contactEmail" class="form-control"
                   placeholder="organizer@campus.edu" value="${param.contactEmail}"/>
          </div>

          <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:8px;">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="btn btn--ghost">Cancel</a>
            <button type="submit" class="btn btn--primary">
              ✅ Publish Event
            </button>
          </div>

        </form>
      </div>
    </div>

  </div>
</div>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
  document.getElementById && (document.querySelector('[name="eventDate"]').min =
    new Date().toISOString().split('T')[0]);
</script>
</body>
</html>

