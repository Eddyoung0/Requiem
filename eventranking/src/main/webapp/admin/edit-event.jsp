<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Edit Event — Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<c:if test="${sessionScope.userRole != 'admin'}">
  <c:redirect url="/login.jsp"/>
</c:if>

<div class="admin-layout">

  <aside class="admin-sidebar">
    <div class="admin-sidebar__logo">⚙️ Admin Panel</div>
    <nav class="admin-sidebar__nav">
      <div class="admin-sidebar__section-title">Overview</div>
      <a href="${pageContext.request.contextPath}/admin/dashboard"><span class="icon">📊</span> Dashboard</a>
      <a href="${pageContext.request.contextPath}/admin/analytics"><span class="icon">📈</span> Analytics</a>
      <div class="admin-sidebar__section-title">Events</div>
      <a href="${pageContext.request.contextPath}/admin/events" class="active"><span class="icon">📋</span> All Events</a>
      <a href="${pageContext.request.contextPath}/admin/events?filter=pending"><span class="icon">⏳</span> Pending</a>
      <a href="${pageContext.request.contextPath}/admin/events/create"><span class="icon">➕</span> Create Event</a>
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
      <span>›</span>
      <a href="${pageContext.request.contextPath}/admin/events">Events</a>
      <span>›</span> <span>Edit</span>
    </div>

    <div class="flex-between mb-6" style="flex-wrap:wrap;gap:12px;">
      <div>
        <h1 style="font-size:1.4rem;font-weight:800;">✏️ Edit Event</h1>
        <p style="font-size:.875rem;color:var(--text-muted);margin-top:2px;">
          Update the event details below.
        </p>
      </div>
      <a href="${pageContext.request.contextPath}/admin/events" class="btn btn--ghost">← Back to Events</a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${error}</div>
    </c:if>

    <%-- Ranking snapshot --%>
    <c:if test="${editEvent.status == 'approved'}">
      <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:20px;">
        <div style="background:var(--primary-light);border-radius:10px;padding:14px;text-align:center;">
          <div style="font-size:1.4rem;font-weight:800;color:var(--primary);">${editEvent.voteCount}</div>
          <div style="font-size:.75rem;color:var(--text-muted);">Votes</div>
        </div>
        <div style="background:#fff7ed;border-radius:10px;padding:14px;text-align:center;">
          <div style="font-size:1.4rem;font-weight:800;color:var(--warning);">${editEvent.bookmarkCount}</div>
          <div style="font-size:.75rem;color:var(--text-muted);">Bookmarks</div>
        </div>
        <div style="background:#d1fae5;border-radius:10px;padding:14px;text-align:center;">
          <div style="font-size:1.4rem;font-weight:800;color:var(--secondary);">${editEvent.viewCount}</div>
          <div style="font-size:.75rem;color:var(--text-muted);">Views</div>
        </div>
        <div style="background:linear-gradient(135deg,#1a56db,#1341b0);border-radius:10px;padding:14px;text-align:center;">
          <div style="font-size:1.4rem;font-weight:800;color:#fff;">${editEvent.rankingScore}</div>
          <div style="font-size:.75rem;color:rgba(255,255,255,.7);">Score</div>
        </div>
      </div>
    </c:if>

    <div class="card">
      <div class="card__header"><h3 style="font-size:.95rem;">Event Details</h3></div>
      <div class="card__body">

        <form action="${pageContext.request.contextPath}/admin/events/edit"
              method="POST" data-validate>

          <input type="hidden" name="eventId" value="${editEvent.eventId}"/>

          <div class="form-group">
            <label class="form-label">Event Title <span class="required">*</span></label>
            <input type="text" name="title" class="form-control"
                   value="${editEvent.title}" data-maxlength="150" required/>
          </div>

          <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;">
            <div class="form-group">
              <label class="form-label">Category <span class="required">*</span></label>
              <select name="category" class="form-control" required>
                <option value="Campus Event"  ${editEvent.category == 'Campus Event'  ? 'selected' : ''}>🎓 Campus Event</option>
                <option value="Workshop"      ${editEvent.category == 'Workshop'      ? 'selected' : ''}>🔧 Workshop</option>
                <option value="Competition"   ${editEvent.category == 'Competition'   ? 'selected' : ''}>🏆 Competition</option>
                <option value="Internship"    ${editEvent.category == 'Internship'    ? 'selected' : ''}>💼 Internship</option>
                <option value="Club Activity" ${editEvent.category == 'Club Activity' ? 'selected' : ''}>🎭 Club Activity</option>
                <option value="Seminar"       ${editEvent.category == 'Seminar'       ? 'selected' : ''}>📖 Seminar</option>
                <option value="Other"         ${editEvent.category == 'Other'         ? 'selected' : ''}>📌 Other</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">Event Date <span class="required">*</span></label>
              <input type="date" name="eventDate" class="form-control"
                     value="${editEvent.eventDate}" required/>
            </div>
            <div class="form-group">
              <label class="form-label">Status <span class="required">*</span></label>
              <select name="status" class="form-control" required>
                <option value="pending"  ${editEvent.status == 'pending'  ? 'selected' : ''}>⏳ Pending</option>
                <option value="approved" ${editEvent.status == 'approved' ? 'selected' : ''}>✅ Approved</option>
                <option value="rejected" ${editEvent.status == 'rejected' ? 'selected' : ''}>❌ Rejected</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Location <span class="required">*</span></label>
            <input type="text" name="location" class="form-control"
                   value="${editEvent.location}" required/>
          </div>

          <div class="form-group">
            <label class="form-label">Description <span class="required">*</span></label>
            <textarea name="description" class="form-control"
                      data-maxlength="1000" required>${editEvent.description}</textarea>
          </div>

          <div class="form-group">
            <label class="form-label">Contact Email <em>(optional)</em></label>
            <input type="email" name="contactEmail" class="form-control"
                   value="${editEvent.contactEmail}"/>
          </div>

          <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;margin-top:8px;">
            <a href="${pageContext.request.contextPath}/admin/events/delete?id=${editEvent.eventId}"
               class="btn btn--danger btn--sm"
               onclick="return confirmDelete('Permanently delete this event and all its votes/bookmarks/views?')">
              🗑️ Delete Event
            </a>
            <div style="display:flex;gap:10px;">
              <a href="${pageContext.request.contextPath}/admin/events" class="btn btn--ghost">Cancel</a>
              <button type="submit" class="btn btn--primary">💾 Save Changes</button>
            </div>
          </div>

        </form>
      </div>
    </div>

  </div>
</div>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

