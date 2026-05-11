<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Submit Event — Campus Notice Board</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<jsp:include page="WEB-INF/includes/navbar.jsp"/>

<%-- Guard: redirect if not logged in --%>
<c:if test="${empty sessionScope.userId}">
  <c:redirect url="/login.jsp"/>
</c:if>

<main style="padding:28px 0 56px;">
  <div class="container--md">

    <div class="page-header__breadcrumb">
      <a href="${pageContext.request.contextPath}/home.jsp">🏠 Home</a>
      <span>›</span>
      <span>Submit Event</span>
    </div>

    <%-- Page title --%>
    <div class="page-header">
      <h1 class="page-header__title">➕ Submit an Event</h1>
      <p class="page-header__sub">
        Fill in the details below. Your submission will be reviewed by an admin before going live.
      </p>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${error}</div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${success}</div>
    </c:if>

    <%-- ── INFO BOX ─────────────────────────────────────── --%>
    <div class="alert alert--info mb-6">
      ℹ️ Once your event is approved, it will appear on the notice board and start accumulating votes, bookmarks, and views to build its ranking score.
    </div>

    <div class="card">
      <div class="card__header">
        <h2 style="font-size:1.1rem;">Event Details</h2>
      </div>
      <div class="card__body">

        <form action="${pageContext.request.contextPath}/submit-event" method="POST" data-validate>

          <%-- Title --%>
          <div class="form-group">
            <label class="form-label" for="title">
              Event Title <span class="required">*</span>
            </label>
            <input type="text" id="title" name="title" class="form-control"
                   placeholder="e.g. Annual Hackathon 2025"
                   value="${param.title}"
                   data-maxlength="150"
                   required/>
            <div class="form-error" style="display:none"></div>
          </div>

          <%-- Category + Date (two columns) --%>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
            <div class="form-group">
              <label class="form-label" for="category">
                Category <span class="required">*</span>
              </label>
              <select id="category" name="category" class="form-control" required>
                <option value="">— Select category —</option>
                <option value="Campus Event"  ${param.category == 'Campus Event'  ? 'selected' : ''}>🎓 Campus Event</option>
                <option value="Workshop"      ${param.category == 'Workshop'      ? 'selected' : ''}>🔧 Workshop</option>
                <option value="Competition"   ${param.category == 'Competition'   ? 'selected' : ''}>🏆 Competition</option>
                <option value="Internship"    ${param.category == 'Internship'    ? 'selected' : ''}>💼 Internship</option>
                <option value="Club Activity" ${param.category == 'Club Activity' ? 'selected' : ''}>🎭 Club Activity</option>
                <option value="Seminar"       ${param.category == 'Seminar'       ? 'selected' : ''}>📖 Seminar</option>
                <option value="Other"         ${param.category == 'Other'         ? 'selected' : ''}>📌 Other</option>
              </select>
              <div class="form-error" style="display:none"></div>
            </div>

            <div class="form-group">
              <label class="form-label" for="eventDate">
                Event Date <span class="required">*</span>
              </label>
              <input type="date" id="eventDate" name="eventDate" class="form-control"
                     value="${param.eventDate}" required
                     min="${today}"/>
              <div class="form-error" style="display:none"></div>
            </div>
          </div>

          <%-- Location --%>
          <div class="form-group">
            <label class="form-label" for="location">
              Location / Venue <span class="required">*</span>
            </label>
            <input type="text" id="location" name="location" class="form-control"
                   placeholder="e.g. Main Auditorium, Block A, Room 204"
                   value="${param.location}" required/>
            <div class="form-error" style="display:none"></div>
          </div>

          <%-- Description --%>
          <div class="form-group">
            <label class="form-label" for="description">
              Description <span class="required">*</span>
            </label>
            <textarea id="description" name="description" class="form-control"
                      placeholder="Describe the event — what it is, who should attend, what participants will gain…"
                      data-maxlength="1000"
                      required>${param.description}</textarea>
            <div class="form-error" style="display:none"></div>
          </div>

          <%-- Optional contact --%>
          <div class="form-group">
            <label class="form-label" for="contactEmail">Contact Email <em>(optional)</em></label>
            <input type="email" id="contactEmail" name="contactEmail" class="form-control"
                   placeholder="organizer@campus.edu"
                   value="${param.contactEmail}"/>
            <div class="form-hint">Students can reach out to this address for queries.</div>
          </div>

          <%-- Submit --%>
          <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;margin-top:8px;">
            <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn--ghost">
              ← Cancel
            </a>
            <button type="submit" class="btn btn--primary btn--lg">
              📤 Submit for Review
            </button>
          </div>

        </form>

      </div><!-- /.card__body -->
    </div><!-- /.card -->

    <%-- ── SUBMISSION GUIDE ────────────────────────────── --%>
    <div class="card mt-6">
      <div class="card__header">
        <h3 style="font-size:.95rem;">📋 What happens next?</h3>
      </div>
      <div class="card__body">
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;">
          <div style="display:flex;gap:12px;align-items:flex-start;">
            <div style="font-size:1.4rem;">📥</div>
            <div>
              <div style="font-weight:600;font-size:.875rem;">1. Submitted</div>
              <div style="font-size:.8rem;color:var(--text-muted);">Your event is queued for admin review.</div>
            </div>
          </div>
          <div style="display:flex;gap:12px;align-items:flex-start;">
            <div style="font-size:1.4rem;">🔍</div>
            <div>
              <div style="font-weight:600;font-size:.875rem;">2. Reviewed</div>
              <div style="font-size:.8rem;color:var(--text-muted);">Admin checks and approves or returns it.</div>
            </div>
          </div>
          <div style="display:flex;gap:12px;align-items:flex-start;">
            <div style="font-size:1.4rem;">📋</div>
            <div>
              <div style="font-weight:600;font-size:.875rem;">3. Published</div>
              <div style="font-size:.8rem;color:var(--text-muted);">Event goes live on the ranked notice board.</div>
            </div>
          </div>
          <div style="display:flex;gap:12px;align-items:flex-start;">
            <div style="font-size:1.4rem;">🏆</div>
            <div>
              <div style="font-weight:600;font-size:.875rem;">4. Ranked</div>
              <div style="font-size:.8rem;color:var(--text-muted);">Community votes push it to the top.</div>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div><%-- /.container--md --%>
</main>

<footer class="footer"><div class="container"><p>© 2025 Smart Campus Notice Board</p></div></footer>
<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
  // Set min date to today
  document.getElementById('eventDate').min = new Date().toISOString().split('T')[0];
</script>
</body>
</html>

