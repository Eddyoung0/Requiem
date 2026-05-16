<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Smart Campus Notice Board</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<%-- ═══ NAVBAR ═══════════════════════════════════════════════ --%>
<jsp:include page="WEB-INF/includes/navbar.jsp"/>

<%-- ═══ HERO ══════════════════════════════════════════════════ --%>
<section class="hero">
  <div class="container">
    <div class="flex-between" style="flex-wrap:wrap;gap:24px;">
      <div>
        <div class="hero__eyebrow">📋 Smart Campus Notice Board</div>
        <h1 class="hero__title">Discover &amp; Rank<br/>Campus Events</h1>
        <p class="hero__sub">
          Events rise to the top based on community votes, bookmarks, and views.
          The most relevant content is always front and centre.
        </p>
        <div class="hero__stats">
          <div>
            <div class="hero__stat-val">${totalEvents != null ? totalEvents : '—'}</div>
            <div class="hero__stat-lab">Active Events</div>
          </div>
          <div>
            <div class="hero__stat-val">${totalUsers != null ? totalUsers : '—'}</div>
            <div class="hero__stat-lab">Students</div>
          </div>
          <div>
            <div class="hero__stat-val">${totalVotes != null ? totalVotes : '—'}</div>
            <div class="hero__stat-lab">Total Votes</div>
          </div>
        </div>
      </div>

      <%-- Ranking formula card --%>
      <div style="background:rgba(255,255,255,.12);backdrop-filter:blur(8px);
                  border:1px solid rgba(255,255,255,.2);border-radius:16px;
                  padding:20px 24px;color:#fff;min-width:240px;">
        <div style="font-size:.72rem;font-weight:700;opacity:.7;text-transform:uppercase;letter-spacing:.08em;margin-bottom:10px;">
          🏆 Ranking Formula
        </div>
        <div style="font-family:'Courier New',monospace;font-size:.9rem;line-height:2;">
          Score =<br/>
          &nbsp;(Votes × <strong>3</strong>) +<br/>
          &nbsp;(Bookmarks × <strong>2</strong>) +<br/>
          &nbsp;Views
        </div>
      </div>
    </div>
  </div>
</section>

<%-- ═══ MAIN CONTENT ══════════════════════════════════════════ --%>
<main style="padding: 28px 0 48px;">
  <div class="container">

    <%-- Flash messages --%>
    <c:if test="${not empty success}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${success}</div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${error}</div>
    </c:if>

    <div class="layout-sidebar">

      <%-- ── SIDEBAR ──────────────────────────────────────── --%>
      <aside>
        <div class="sidebar">

          <%-- Search --%>
          <div class="sidebar__section">
            <div class="search-bar">
              <svg class="search-bar__icon" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
              </svg>
              <input type="text" id="live-search" placeholder="Search events…"/>
            </div>
          </div>

          <%-- Categories --%>
          <div class="sidebar__section">
            <div class="sidebar__title">Categories</div>
            <div style="display:flex;flex-direction:column;gap:2px;">
              <a href="#" class="sidebar__nav-link cat-pill active" data-category="all">
                <span class="icon">🗂️</span> All Events
                <span class="count">${totalEvents}</span>
              </a>
              <a href="#" class="sidebar__nav-link cat-pill" data-category="Workshop">
                <span class="icon">🔧</span> Workshops
                <span class="count">${workshopCount}</span>
              </a>
              <a href="#" class="sidebar__nav-link cat-pill" data-category="Competition">
                <span class="icon">🏆</span> Competitions
                <span class="count">${competitionCount}</span>
              </a>
              <a href="#" class="sidebar__nav-link cat-pill" data-category="Internship">
                <span class="icon">💼</span> Internships
                <span class="count">${internshipCount}</span>
              </a>
              <a href="#" class="sidebar__nav-link cat-pill" data-category="Club Activity">
                <span class="icon">🎭</span> Club Activities
                <span class="count">${clubCount}</span>
              </a>
              <a href="#" class="sidebar__nav-link cat-pill" data-category="Campus Event">
                <span class="icon">🎓</span> Campus Events
                <span class="count">${campusCount}</span>
              </a>
              <a href="#" class="sidebar__nav-link cat-pill" data-category="Seminar">
                <span class="icon">📖</span> Seminars
                <span class="count">${seminarCount}</span>
              </a>
            </div>
          </div>

          <%-- Sort options --%>
          <div class="sidebar__section">
            <div class="sidebar__title">Sort By</div>
            <form action="${pageContext.request.contextPath}/events" method="GET">
              <select name="sort" class="form-control" onchange="this.form.submit()">
                <option value="score"    ${param.sort == 'score'    || empty param.sort ? 'selected' : ''}>🏆 Ranking Score</option>
                <option value="date"     ${param.sort == 'date'     ? 'selected' : ''}>📅 Upcoming First</option>
                <option value="votes"    ${param.sort == 'votes'    ? 'selected' : ''}>👍 Most Voted</option>
                <option value="views"    ${param.sort == 'views'    ? 'selected' : ''}>👁️ Most Viewed</option>
                <option value="newest"   ${param.sort == 'newest'   ? 'selected' : ''}>🆕 Newest First</option>
              </select>
            </form>
          </div>

          <%-- Quick links --%>
          <div class="sidebar__section">
            <div class="sidebar__title">Quick Links</div>
            <a href="${pageContext.request.contextPath}/submit-event.jsp" class="sidebar__nav-link">
              <span class="icon">➕</span> Submit Your Event
            </a>
            <c:if test="${not empty sessionScope.userId}">
              <a href="${pageContext.request.contextPath}/user-dashboard.jsp" class="sidebar__nav-link">
                <span class="icon">🔖</span> My Bookmarks
              </a>
            </c:if>
          </div>

        </div><!-- /.sidebar -->
      </aside>

      <%-- ── EVENT FEED ───────────────────────────────────── --%>
      <section>

        <%-- Trending banner --%>
        <c:if test="${not empty trendingEvent}">
          <div style="background:linear-gradient(135deg,#fff7ed,#fef3c7);
                      border:1px solid #fed7aa;border-radius:12px;
                      padding:14px 18px;margin-bottom:20px;
                      display:flex;align-items:center;gap:12px;">
            <span style="font-size:1.4rem;">🔥</span>
            <div>
              <div style="font-size:.72rem;font-weight:700;color:#9a3412;text-transform:uppercase;letter-spacing:.06em;">
                Trending Now
              </div>
              <a href="${pageContext.request.contextPath}/event?id=${trendingEvent.eventId}"
                 style="font-weight:700;color:#1a1a2e;">
                ${trendingEvent.title}
              </a>
              <span style="font-size:.8rem;color:#92400e;margin-left:8px;">
                Score: ${trendingEvent.rankingScore}
              </span>
            </div>
          </div>
        </c:if>

        <%-- Section header --%>
        <div class="flex-between mb-4">
          <h2 style="font-size:1.25rem;">
            🏅 Ranked Notice Board
          </h2>
          <span class="badge badge--blue">
            ${fn:length(events)} event${fn:length(events) != 1 ? 's' : ''}
          </span>
        </div>

        <%-- Event cards list --%>
        <c:choose>
          <c:when test="${not empty events}">
            <div style="display:flex;flex-direction:column;gap:14px;">

              <c:forEach var="event" items="${events}" varStatus="loop">
                <article class="event-card
                                ${loop.index < 1 ? 'event-card--top' : ''}
                                ${event.trending  ? 'event-card--trending' : ''}"
                         data-category="${event.category}"
                         data-title="${event.title}"
                         data-desc="${event.description}">

                  <%-- Rank badge --%>
                  <div class="event-card__rank">
                    <c:choose>
                      <c:when test="${loop.index == 0}"><div class="rank-badge rank-badge--1">🥇</div></c:when>
                      <c:when test="${loop.index == 1}"><div class="rank-badge rank-badge--2">🥈</div></c:when>
                      <c:when test="${loop.index == 2}"><div class="rank-badge rank-badge--3">🥉</div></c:when>
                      <c:otherwise><div class="rank-badge rank-badge--n">#${loop.index + 1}</div></c:otherwise>
                    </c:choose>
                  </div>

                  <div class="event-card__body">

                    <%-- Title + category --%>
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px;flex-wrap:wrap;">
                      <h3 class="event-card__title">
                        <a href="${pageContext.request.contextPath}/event?id=${event.eventId}">
                          ${event.title}
                        </a>
                      </h3>
                      <span class="badge badge--blue">${event.category}</span>
                      <c:if test="${event.status == 'approved'}">
                        <span class="badge badge--green">✓ Approved</span>
                      </c:if>
                    </div>

                    <%-- Description --%>
                    <p class="event-card__desc">${event.description}</p>

                    <%-- Meta: date, location --%>
                    <div class="event-card__meta">
                      <span>📅 ${event.eventDate}</span>
                      <span>📍 ${event.location}</span>
                      <span>👤 ${event.createdByName}</span>
                    </div>

                    <%-- Footer: stats + actions --%>
                    <div class="event-card__footer">
                      <div class="event-card__stats">
                        <span>👍 ${event.voteCount}</span>
                        <span>🔖 ${event.bookmarkCount}</span>
                        <span>👁️ ${event.viewCount}</span>
                        <div class="score-chip">⭐ ${event.rankingScore}</div>
                      </div>

                      <div class="event-card__actions">
                        <c:if test="${not empty sessionScope.userId}">
                          <button class="btn btn--vote btn--sm vote-btn ${event.userVoted ? 'voted' : ''}"
                                  data-event-id="${event.eventId}">
                            👍 <span class="vote-count">${event.voteCount}</span>
                          </button>
                          <button class="btn btn--bookmark btn--sm bookmark-btn ${event.userBookmarked ? 'bookmarked' : ''}"
                                  data-event-id="${event.eventId}">
                            🔖 <span class="bm-label">${event.userBookmarked ? 'Saved' : 'Bookmark'}</span>
                          </button>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                           class="btn btn--secondary btn--sm">
                          View →
                        </a>
                      </div>
                    </div>

                  </div><!-- /.event-card__body -->
                </article>
              </c:forEach>

            </div><!-- /event list -->

            <%-- Pagination --%>
            <c:if test="${totalPages > 1}">
              <div class="pagination">
                <c:if test="${currentPage > 1}">
                  <a class="pagination__btn" href="?page=${currentPage - 1}&sort=${param.sort}">‹</a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="p">
                  <a class="pagination__btn ${p == currentPage ? 'active' : ''}"
                     href="?page=${p}&sort=${param.sort}">${p}</a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                  <a class="pagination__btn" href="?page=${currentPage + 1}&sort=${param.sort}">›</a>
                </c:if>
              </div>
            </c:if>

          </c:when>

          <c:otherwise>
            <div class="empty-state">
              <div class="empty-state__icon">📭</div>
              <div class="empty-state__title">No events yet</div>
              <p class="empty-state__sub">Be the first to submit an event to the notice board.</p>
              <a href="${pageContext.request.contextPath}/submit-event.jsp"
                 class="btn btn--primary mt-4">➕ Submit Event</a>
            </div>
          </c:otherwise>
        </c:choose>

      </section><%-- /event feed --%>

    </div><%-- /.layout-sidebar --%>
  </div><%-- /.container --%>
</main>

<footer class="footer">
  <div class="container">
    <p>© 2025 Smart Campus Notice Board · Ranking Score = (Votes×3) + (Bookmarks×2) + Views</p>
  </div>
</footer>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

