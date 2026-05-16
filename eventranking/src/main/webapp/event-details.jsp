<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${event.title} — Campus Notice Board</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<jsp:include page="WEB-INF/includes/navbar.jsp"/>

<main style="padding:28px 0 56px;">
  <div class="container--md">

    <%-- Breadcrumb --%>
    <div class="page-header__breadcrumb">
      <a href="${pageContext.request.contextPath}/home.jsp">🏠 Home</a>
      <span>›</span>
      <span>${event.category}</span>
      <span>›</span>
      <span>${event.title}</span>
    </div>

    <c:if test="${not empty success}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${success}</div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${error}</div>
    </c:if>

    <%-- ── EVENT HEADER ──────────────────────────────────── --%>
    <div class="card mb-6">
      <div class="card__body">

        <div class="flex-between" style="flex-wrap:wrap;gap:12px;margin-bottom:16px;">
          <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
            <span class="badge badge--blue">${event.category}</span>
            <c:if test="${event.status == 'approved'}">
              <span class="badge badge--green">✓ Approved</span>
            </c:if>
            <c:if test="${event.ranking <= 3}">
              <span class="badge badge--yellow">
                <c:choose>
                  <c:when test="${event.ranking == 1}">🥇 #1 Ranked</c:when>
                  <c:when test="${event.ranking == 2}">🥈 #2 Ranked</c:when>
                  <c:otherwise>🥉 #3 Ranked</c:otherwise>
                </c:choose>
              </span>
            </c:if>
          </div>
          <div class="score-chip">⭐ Score: ${event.rankingScore}</div>
        </div>

        <h1 style="font-size:1.8rem;font-weight:800;margin-bottom:12px;">${event.title}</h1>

        <%-- Meta row --%>
        <div style="display:flex;flex-wrap:wrap;gap:20px;font-size:.875rem;color:var(--text-secondary);margin-bottom:20px;">
          <span>📅 <strong>${event.eventDate}</strong></span>
          <span>📍 <strong>${event.location}</strong></span>
          <span>👤 Posted by <strong>${event.createdByName}</strong></span>
          <span>🕐 <strong>${event.createdAt}</strong></span>
        </div>

        <%-- Countdown --%>
        <div style="margin-bottom:20px;">
          <div style="font-size:.78rem;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:8px;">
            ⏳ Event Countdown
          </div>
          <div data-countdown="${event.eventDateISO}"></div>
        </div>

        <%-- Description --%>
        <div style="line-height:1.8;color:var(--text-primary);white-space:pre-wrap;font-size:.95rem;">
          ${event.description}
        </div>

      </div><!-- /.card__body -->

      <%-- ── ENGAGEMENT BAR ──────────────────────────────── --%>
      <div class="card__footer">
        <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:14px;">

          <%-- Stats --%>
          <div style="display:flex;gap:20px;font-size:.875rem;color:var(--text-secondary);">
            <span style="display:flex;align-items:center;gap:5px;">
              👍 <strong>${event.voteCount}</strong> votes
            </span>
            <span style="display:flex;align-items:center;gap:5px;">
              🔖 <strong>${event.bookmarkCount}</strong> bookmarks
            </span>
            <span style="display:flex;align-items:center;gap:5px;">
              👁️ <strong>${event.viewCount}</strong> views
            </span>
          </div>

          <%-- Action buttons --%>
          <div style="display:flex;gap:10px;flex-wrap:wrap;">
            <c:choose>
              <c:when test="${not empty sessionScope.userId}">
                <button class="btn btn--vote vote-btn ${event.userVoted ? 'voted' : ''}"
                        data-event-id="${event.eventId}">
                  👍 <span class="vote-count">${event.voteCount}</span>
                  ${event.userVoted ? ' Voted' : ' Vote'}
                </button>
                <button class="btn btn--bookmark bookmark-btn ${event.userBookmarked ? 'bookmarked' : ''}"
                        data-event-id="${event.eventId}">
                  🔖 <span class="bm-label">${event.userBookmarked ? 'Saved' : 'Bookmark'}</span>
                </button>
              </c:when>
              <c:otherwise>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn--secondary">
                  Login to Vote or Bookmark
                </a>
              </c:otherwise>
            </c:choose>
            <c:if test="${sessionScope.userRole == 'admin'}">
              <a href="${pageContext.request.contextPath}/admin/events/delete?id=${event.eventId}" 
                 class="btn btn--danger"
                 onclick="return confirmDelete('Are you sure you want to permanently delete this event?');">
                🗑️ Delete Event
              </a>
            </c:if>
            <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn--ghost">
              ← Back to Board
            </a>
          </div>

        </div>
      </div><!-- /.card__footer -->
    </div><!-- /.card -->

    <%-- ── RANKING BREAKDOWN ─────────────────────────────── --%>
    <div class="card mb-6">
      <div class="card__header">
        <h3>📊 Ranking Score Breakdown</h3>
      </div>
      <div class="card__body">
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:16px;margin-bottom:20px;">

          <div style="text-align:center;padding:16px;background:var(--primary-light);border-radius:10px;">
            <div style="font-size:1.8rem;font-weight:800;color:var(--primary);">
              ${event.voteCount}
            </div>
            <div style="font-size:.78rem;color:var(--text-muted);margin:4px 0;">Votes</div>
            <div style="font-size:.82rem;font-weight:600;color:var(--primary);">× 3 = ${event.voteCount * 3}</div>
          </div>

          <div style="text-align:center;padding:16px;background:#fff7ed;border-radius:10px;">
            <div style="font-size:1.8rem;font-weight:800;color:var(--warning);">
              ${event.bookmarkCount}
            </div>
            <div style="font-size:.78rem;color:var(--text-muted);margin:4px 0;">Bookmarks</div>
            <div style="font-size:.82rem;font-weight:600;color:var(--warning);">× 2 = ${event.bookmarkCount * 2}</div>
          </div>

          <div style="text-align:center;padding:16px;background:#d1fae5;border-radius:10px;">
            <div style="font-size:1.8rem;font-weight:800;color:var(--secondary);">
              ${event.viewCount}
            </div>
            <div style="font-size:.78rem;color:var(--text-muted);margin:4px 0;">Views</div>
            <div style="font-size:.82rem;font-weight:600;color:var(--secondary);">× 1 = ${event.viewCount}</div>
          </div>

          <div style="text-align:center;padding:16px;background:linear-gradient(135deg,#1a56db,#1341b0);border-radius:10px;">
            <div style="font-size:1.8rem;font-weight:800;color:#fff;">
              ${event.rankingScore}
            </div>
            <div style="font-size:.78rem;color:rgba(255,255,255,.7);margin:4px 0;">Total Score</div>
            <div style="font-size:.78rem;color:rgba(255,255,255,.8);">Board Position #${event.ranking}</div>
          </div>

        </div>

        <%-- Visual progress bars --%>
        <div style="display:flex;flex-direction:column;gap:10px;">
          <div>
            <div class="flex-between mb-2" style="font-size:.8rem;">
              <span>Votes contribution</span>
              <span style="font-weight:600;">${event.voteCount * 3} pts</span>
            </div>
            <div class="progress">
              <div class="progress__bar progress__bar--primary"
                   style="width:${event.rankingScore > 0 ? (event.voteCount * 3 * 100 / event.rankingScore) : 0}%"></div>
            </div>
          </div>
          <div>
            <div class="flex-between mb-2" style="font-size:.8rem;">
              <span>Bookmarks contribution</span>
              <span style="font-weight:600;">${event.bookmarkCount * 2} pts</span>
            </div>
            <div class="progress">
              <div class="progress__bar progress__bar--warning"
                   style="width:${event.rankingScore > 0 ? (event.bookmarkCount * 2 * 100 / event.rankingScore) : 0}%"></div>
            </div>
          </div>
          <div>
            <div class="flex-between mb-2" style="font-size:.8rem;">
              <span>Views contribution</span>
              <span style="font-weight:600;">${event.viewCount} pts</span>
            </div>
            <div class="progress">
              <div class="progress__bar progress__bar--success"
                   style="width:${event.rankingScore > 0 ? (event.viewCount * 100 / event.rankingScore) : 0}%"></div>
            </div>
          </div>
        </div>

      </div><!-- /.card__body -->
    </div><!-- /.card -->

    <%-- ── SIMILAR EVENTS ─────────────────────────────────── --%>
    <c:if test="${not empty similarEvents}">
      <h3 style="margin-bottom:14px;">📌 More in ${event.category}</h3>
      <div style="display:flex;flex-direction:column;gap:12px;">
        <c:forEach var="sim" items="${similarEvents}">
          <div class="card">
            <div class="card__body" style="display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 18px;">
              <div>
                <a href="${pageContext.request.contextPath}/event?id=${sim.eventId}"
                   style="font-weight:600;">${sim.title}</a>
                <div style="font-size:.8rem;color:var(--text-muted);margin-top:2px;">
                  📅 ${sim.eventDate} · ⭐ ${sim.rankingScore}
                </div>
              </div>
              <a href="${pageContext.request.contextPath}/event?id=${sim.eventId}"
                 class="btn btn--secondary btn--sm">View →</a>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:if>

  </div><%-- /.container--md --%>
</main>

<footer class="footer">
  <div class="container">
    <p>© 2025 Smart Campus Notice Board</p>
  </div>
</footer>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

