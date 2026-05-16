<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Dashboard — Campus Notice Board</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<jsp:include page="WEB-INF/includes/navbar.jsp"/>

<%-- Guard --%>
<c:if test="${empty sessionScope.userId}">
  <c:redirect url="/login.jsp"/>
</c:if>

<main style="padding:28px 0 56px;">
  <div class="container">

    <%-- Page header --%>
    <div class="page-header flex-between" style="align-items:flex-start;flex-wrap:wrap;gap:12px;">
      <div>
        <h1 class="page-header__title">👤 My Dashboard</h1>
        <p class="page-header__sub">
          Welcome back, <strong>${sessionScope.userName}</strong>!
          Track your activity and bookmarks below.
        </p>
      </div>
      <a href="${pageContext.request.contextPath}/submit-event.jsp" class="btn btn--primary">
        ➕ Submit Event
      </a>
    </div>

    <c:if test="${not empty success}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${success}</div>
    </c:if>

    <%-- ── STAT CARDS  --%>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-bottom:28px;">

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--blue">📋</div>
        <div>
          <div class="stat-card__value">${fn:length(mySubmissions)}</div>
          <div class="stat-card__label">Events Submitted</div>
          <div class="stat-card__change">
            ${approvedCount} approved
          </div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--yellow">🔖</div>
        <div>
          <div class="stat-card__value">${fn:length(myBookmarks)}</div>
          <div class="stat-card__label">Bookmarked Events</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--green">👍</div>
        <div>
          <div class="stat-card__value">${myVoteCount}</div>
          <div class="stat-card__label">Votes Cast</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--purple">👁️</div>
        <div>
          <div class="stat-card__value">${totalViewsOnMyEvents}</div>
          <div class="stat-card__label">Views on My Events</div>
        </div>
      </div>

    </div>

    <%-- ── TAB LAYOUT  --%>
    <div style="border-bottom:1px solid var(--border);margin-bottom:20px;">
      <div style="display:flex;gap:0;" id="tab-nav">
        <button class="tab-btn active" data-tab="bookmarks"
                style="padding:10px 20px;background:none;border:none;border-bottom:2px solid var(--primary);
                       font-weight:600;font-size:.9rem;color:var(--primary);cursor:pointer;">
          🔖 Bookmarks (${fn:length(myBookmarks)})
        </button>
        <button class="tab-btn" data-tab="submissions"
                style="padding:10px 20px;background:none;border:none;border-bottom:2px solid transparent;
                       font-weight:600;font-size:.9rem;color:var(--text-muted);cursor:pointer;">
          📤 My Submissions (${fn:length(mySubmissions)})
        </button>
        <button class="tab-btn" data-tab="votes"
                style="padding:10px 20px;background:none;border:none;border-bottom:2px solid transparent;
                       font-weight:600;font-size:.9rem;color:var(--text-muted);cursor:pointer;">
          👍 Voted Events (${myVoteCount})
        </button>
      </div>
    </div>

    <%-- ── BOOKMARKS TAB  --%>
    <div id="tab-bookmarks" class="tab-panel">
      <c:choose>
        <c:when test="${not empty myBookmarks}">
          <div style="display:flex;flex-direction:column;gap:12px;">
            <c:forEach var="event" items="${myBookmarks}">
              <div class="card">
                <div class="card__body" style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;">
                  <div style="flex:1;min-width:0;">
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px;">
                      <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                         style="font-weight:700;">${event.title}</a>
                      <span class="badge badge--blue">${event.category}</span>
                    </div>
                    <div style="font-size:.8rem;color:var(--text-muted);">
                      📅 ${event.eventDate} &nbsp;·&nbsp; 📍 ${event.location} &nbsp;·&nbsp; ⭐ Score: ${event.rankingScore}
                    </div>
                  </div>
                  <div style="display:flex;gap:8px;">
                    <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                       class="btn btn--secondary btn--sm">View →</a>
                    <button class="btn btn--bookmark btn--sm bookmarked bookmark-btn"
                            data-event-id="${event.eventId}">
                      🔖 Remove
                    </button>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="empty-state">
            <div class="empty-state__icon">🔖</div>
            <div class="empty-state__title">No bookmarks yet</div>
            <p class="empty-state__sub">Browse events and bookmark the ones you're interested in.</p>
            <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn--primary mt-4">Browse Events</a>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ── SUBMISSIONS TAB  --%>
    <div id="tab-submissions" class="tab-panel" style="display:none;">
      <c:choose>
        <c:when test="${not empty mySubmissions}">
          <div class="table-wrap">
            <table class="table">
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Category</th>
                  <th>Date</th>
                  <th>Status</th>
                  <th>Score</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="event" items="${mySubmissions}">
                  <tr>
                    <td>
                      <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                         style="font-weight:600;">${event.title}</a>
                    </td>
                    <td><span class="badge badge--blue">${event.category}</span></td>
                    <td style="white-space:nowrap;">${event.eventDate}</td>
                    <td>
                      <c:choose>
                        <c:when test="${event.status == 'approved'}">
                          <span class="badge badge--green">✓ Approved</span>
                        </c:when>
                        <c:when test="${event.status == 'pending'}">
                          <span class="badge badge--yellow">⏳ Pending</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge--red">✗ Rejected</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${event.status == 'approved'}">
                        <div class="score-chip">⭐ ${event.rankingScore}</div>
                      </c:if>
                      <c:if test="${event.status != 'approved'}">—</c:if>
                    </td>
                    <td>
                      <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                         class="btn btn--secondary btn--sm">View</a>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:when>
        <c:otherwise>
          <div class="empty-state">
            <div class="empty-state__icon">📤</div>
            <div class="empty-state__title">No submissions yet</div>
            <p class="empty-state__sub">Submit your first event proposal to the notice board.</p>
            <a href="${pageContext.request.contextPath}/submit-event.jsp" class="btn btn--primary mt-4">
              ➕ Submit Event
            </a>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ── VOTED EVENTS TAB --%>
    <div id="tab-votes" class="tab-panel" style="display:none;">
      <c:choose>
        <c:when test="${not empty myVotedEvents}">
          <div style="display:flex;flex-direction:column;gap:12px;">
            <c:forEach var="event" items="${myVotedEvents}">
              <div class="card">
                <div class="card__body" style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;">
                  <div style="flex:1;min-width:0;">
                    <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                       style="font-weight:700;">${event.title}</a>
                    <div style="font-size:.8rem;color:var(--text-muted);margin-top:3px;">
                      ${event.category} &nbsp;·&nbsp; Board Position #${event.ranking}
                    </div>
                  </div>
                  <div class="score-chip">⭐ ${event.rankingScore}</div>
                  <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                     class="btn btn--secondary btn--sm">View →</a>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="empty-state">
            <div class="empty-state__icon">👍</div>
            <div class="empty-state__title">No votes cast yet</div>
            <p class="empty-state__sub">Vote on events to help them rise in the rankings.</p>
            <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn--primary mt-4">Explore Events</a>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

  </div><%-- /.container --%>
</main>

<footer class="footer"><div class="container"><p>© 2025 Smart Campus Notice Board</p></div></footer>
<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
  // Simple tab switching
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      document.querySelectorAll('.tab-btn').forEach(b => {
        b.style.borderBottomColor = 'transparent';
        b.style.color = 'var(--text-muted)';
        b.classList.remove('active');
      });
      this.style.borderBottomColor = 'var(--primary)';
      this.style.color = 'var(--primary)';
      this.classList.add('active');

      document.querySelectorAll('.tab-panel').forEach(p => p.style.display = 'none');
      document.getElementById('tab-' + this.dataset.tab).style.display = '';
    });
  });
</script>
</body>
</html>

