<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Admin Dashboard — Campus Notice Board</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<%-- Guard: admin only --%>
<c:if test="${sessionScope.userRole != 'admin'}">
  <c:redirect url="/home.jsp"/>
</c:if>

<%-- ═══ ADMIN LAYOUT ══════════════════════════════════════════ --%>
<div class="admin-layout">

  <%-- ── ADMIN SIDEBAR ──────────────────────────────────── --%>
  <aside class="admin-sidebar">
    <div class="admin-sidebar__logo">
      ⚙️ Admin Panel
    </div>

    <nav class="admin-sidebar__nav">
      <div class="admin-sidebar__section-title">Overview</div>
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="active">
        <span class="icon">📊</span> Dashboard
      </a>

      <div class="admin-sidebar__section-title">Events</div>
      <a href="${pageContext.request.contextPath}/admin/events">
        <span class="icon">📋</span> All Events
      </a>
      <a href="${pageContext.request.contextPath}/admin/events?filter=pending">
        <span class="icon">⏳</span> Pending Approval
        <c:if test="${pendingCount > 0}">
          <span style="margin-left:auto;background:#e02424;color:#fff;font-size:.7rem;
                       font-weight:700;padding:1px 7px;border-radius:999px;">
            ${pendingCount}
          </span>
        </c:if>
      </a>
      <a href="${pageContext.request.contextPath}/admin/events?filter=approved">
        <span class="icon">✅</span> Approved
      </a>
      <a href="${pageContext.request.contextPath}/admin/events/create">
        <span class="icon">➕</span> Create Event
      </a>

      <div class="admin-sidebar__section-title">Users</div>
      <a href="${pageContext.request.contextPath}/admin/users">
        <span class="icon">👥</span> Manage Users
      </a>

      <div class="admin-sidebar__section-title">Settings</div>
      <a href="${pageContext.request.contextPath}/admin/analytics">
        <span class="icon">📈</span> Analytics
      </a>
      <a href="${pageContext.request.contextPath}/admin/categories/">
        <span class="icon">🗂️</span> Categories
      </a>
      <a href="${pageContext.request.contextPath}/home.jsp">
        <span class="icon">🏠</span> View Site
      </a>
      <a href="${pageContext.request.contextPath}/logout">
        <span class="icon">🚪</span> Sign Out
      </a>
    </nav>
  </aside>

  <%-- ── ADMIN MAIN CONTENT ─────────────────────────────── --%>
  <div class="admin-main">

    <%-- Header --%>
    <div class="flex-between" style="margin-bottom:24px;flex-wrap:wrap;gap:12px;">
      <div>
        <h1 style="font-size:1.5rem;font-weight:800;">Dashboard</h1>
        <p style="font-size:.875rem;color:var(--text-muted);margin-top:2px;">
          Smart Campus Notice Board — Admin Overview
        </p>
      </div>
      <div style="display:flex;gap:10px;">
        <a href="${pageContext.request.contextPath}/admin/events/create" class="btn btn--primary btn--sm">
          ➕ New Event
        </a>
        <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn--secondary btn--sm">
          🏠 View Site
        </a>
      </div>
    </div>

    <c:if test="${not empty success}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${success}</div>
    </c:if>

    <%-- ── STAT CARDS ──────────────────────────────────── --%>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin-bottom:28px;">

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--blue">📋</div>
        <div>
          <div class="stat-card__value">${totalEvents}</div>
          <div class="stat-card__label">Total Events</div>
          <div class="stat-card__change">↑ ${newEventsThisWeek} this week</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--yellow">⏳</div>
        <div>
          <div class="stat-card__value" style="${pendingCount > 0 ? 'color:var(--warning)' : ''}">${pendingCount}</div>
          <div class="stat-card__label">Pending Approval</div>
          <c:if test="${pendingCount > 0}">
            <a href="${pageContext.request.contextPath}/admin/events?filter=pending"
               style="font-size:.78rem;font-weight:600;color:var(--warning);margin-top:4px;display:block;">
              Review now →
            </a>
          </c:if>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--green">👥</div>
        <div>
          <div class="stat-card__value">${totalUsers}</div>
          <div class="stat-card__label">Registered Users</div>
          <div class="stat-card__change">↑ ${newUsersThisWeek} this week</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--purple">👍</div>
        <div>
          <div class="stat-card__value">${totalVotes}</div>
          <div class="stat-card__label">Total Votes Cast</div>
        </div>
      </div>

    </div>

    <%-- ── TWO-COLUMN LOWER SECTION ─────────────────────── --%>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:24px;">

      <%-- Pending approvals --%>
      <div class="card">
        <div class="card__header flex-between">
          <h3 style="font-size:.95rem;">⏳ Pending Approvals</h3>
          <a href="${pageContext.request.contextPath}/admin/events?filter=pending"
             style="font-size:.8rem;color:var(--primary);">View all</a>
        </div>
        <div class="card__body" style="padding:0;">
          <c:choose>
            <c:when test="${not empty pendingEvents}">
              <c:forEach var="event" items="${pendingEvents}" begin="0" end="4">
                <div style="padding:12px 16px;border-bottom:1px solid var(--border);
                            display:flex;align-items:center;gap:10px;">
                  <div style="flex:1;min-width:0;">
                    <div style="font-weight:600;font-size:.875rem;
                                white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                      ${event.title}
                    </div>
                    <div style="font-size:.75rem;color:var(--text-muted);">
                      ${event.category} · ${event.createdByName}
                    </div>
                  </div>
                    <div style="display:flex;gap:6px;">
                      <button class="btn btn--success btn--sm"
                              onclick="quickApprove(${event.eventId},'approve')">✓</button>
                      <button class="btn btn--danger btn--sm"
                              onclick="quickApprove(${event.eventId},'reject')">✗</button>
                      <a href="${pageContext.request.contextPath}/admin/events/delete?id=${event.eventId}" 
                         class="btn btn--ghost btn--sm" style="color:var(--danger);"
                         onclick="return confirmDelete('Are you sure you want to permanently delete this event?');" title="Delete">🗑️</a>
                    </div>
                </div>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div class="empty-state" style="padding:28px;">
                <div class="empty-state__icon" style="font-size:1.8rem;">✅</div>
                <div class="empty-state__title" style="font-size:.9rem;">All clear!</div>
                <p class="empty-state__sub" style="font-size:.8rem;">No pending events.</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <%-- Top ranked events --%>
      <div class="card">
        <div class="card__header flex-between">
          <h3 style="font-size:.95rem;">🏆 Top Ranked Events</h3>
          <a href="${pageContext.request.contextPath}/admin/events?sort=score"
             style="font-size:.8rem;color:var(--primary);">View all</a>
        </div>
        <div class="card__body" style="padding:0;">
          <c:forEach var="event" items="${topEvents}" begin="0" end="4" varStatus="st">
            <div style="padding:12px 16px;border-bottom:1px solid var(--border);
                        display:flex;align-items:center;gap:10px;">
              <div style="font-size:.9rem;font-weight:700;color:var(--text-muted);min-width:24px;">
                ${st.index + 1}.
              </div>
              <div style="flex:1;min-width:0;">
                <div style="font-weight:600;font-size:.875rem;
                            white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                  ${event.title}
                </div>
                <div style="font-size:.75rem;color:var(--text-muted);">
                  👍 ${event.voteCount} · 🔖 ${event.bookmarkCount} · 👁️ ${event.viewCount}
                </div>
              </div>
              <div style="display:flex;align-items:center;gap:10px;">
                <div class="score-chip" style="font-size:.75rem;padding:3px 9px;">⭐ ${event.rankingScore}</div>
                <c:if test="${sessionScope.userRole == 'admin'}">
                  <a href="${pageContext.request.contextPath}/admin/events/delete?id=${event.eventId}" 
                     class="btn btn--ghost btn--sm" style="color:var(--danger);padding:0 5px;"
                     onclick="return confirmDelete('Are you sure you want to permanently delete this event?');" title="Delete">🗑️</a>
                </c:if>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

    </div>

    <%-- ── ALL EVENTS TABLE ────────────────────────────────── --%>
    <div class="card">
      <div class="card__header flex-between">
        <h3 style="font-size:.95rem;">📋 All Events</h3>

        <%-- Search + filter --%>
        <div style="display:flex;gap:10px;align-items:center;">
          <form action="${pageContext.request.contextPath}/admin/events" method="GET"
                style="display:flex;gap:8px;">
            <input type="text" name="search" placeholder="Search…"
                   class="form-control" style="width:180px;padding:7px 12px;font-size:.82rem;"
                   value="${param.search}"/>
            <select name="filter" class="form-control" style="width:130px;padding:7px 12px;font-size:.82rem;"
                    onchange="this.form.submit()">
              <option value="all"      ${param.filter == 'all'      || empty param.filter ? 'selected' : ''}>All</option>
              <option value="pending"  ${param.filter == 'pending'  ? 'selected' : ''}>Pending</option>
              <option value="approved" ${param.filter == 'approved' ? 'selected' : ''}>Approved</option>
              <option value="rejected" ${param.filter == 'rejected' ? 'selected' : ''}>Rejected</option>
            </select>
            <button type="submit" class="btn btn--secondary btn--sm">Search</button>
          </form>
        </div>
      </div>

      <div class="table-wrap" style="border:none;border-radius:0;">
        <c:choose>
          <c:when test="${not empty allEvents}">
            <table class="table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Title</th>
                  <th>Category</th>
                  <th>Date</th>
                  <th>Submitted By</th>
                  <th>Status</th>
                  <th>Score</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="event" items="${allEvents}" varStatus="loop">
                  <tr>
                    <td style="color:var(--text-muted);font-size:.82rem;">${loop.index + 1}</td>
                    <td>
                      <a href="${pageContext.request.contextPath}/event?id=${event.eventId}"
                         target="_blank" style="font-weight:600;">${event.title}</a>
                    </td>
                    <td><span class="badge badge--blue">${event.category}</span></td>
                    <td style="white-space:nowrap;font-size:.82rem;">${event.eventDate}</td>
                    <td style="font-size:.82rem;">${event.createdByName}</td>
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
                        <strong>${event.rankingScore}</strong>
                      </c:if>
                      <c:if test="${event.status != 'approved'}">—</c:if>
                    </td>
                    <td>
                      <div style="display:flex;gap:6px;flex-wrap:nowrap;">
                        <c:if test="${event.status == 'pending'}">
                          <button class="btn btn--success btn--sm"
                                  onclick="quickApprove(${event.eventId},'approve')" title="Approve">✓</button>
                          <button class="btn btn--danger btn--sm"
                                  onclick="quickApprove(${event.eventId},'reject')" title="Reject">✗</button>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/admin/events/edit?id=${event.eventId}"
                           class="btn btn--ghost btn--sm" title="Edit">✏️</a>
                        <a href="${pageContext.request.contextPath}/admin/events/delete?id=${event.eventId}"
                           class="btn btn--ghost btn--sm"
                           onclick="return confirmDelete('Delete this event?')"
                           title="Delete">🗑️</a>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <div class="empty-state">
              <div class="empty-state__icon">📭</div>
              <div class="empty-state__title">No events found</div>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <%-- Pagination --%>
      <c:if test="${totalPages > 1}">
        <div class="card__footer">
          <div class="pagination" style="margin-top:0;">
            <c:if test="${currentPage > 1}">
              <a class="pagination__btn"
                 href="?page=${currentPage-1}&filter=${param.filter}&search=${param.search}">‹</a>
            </c:if>
            <c:forEach begin="1" end="${totalPages}" var="p">
              <a class="pagination__btn ${p == currentPage ? 'active' : ''}"
                 href="?page=${p}&filter=${param.filter}&search=${param.search}">${p}</a>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
              <a class="pagination__btn"
                 href="?page=${currentPage+1}&filter=${param.filter}&search=${param.search}">›</a>
            </c:if>
          </div>
        </div>
      </c:if>

    </div><%-- /.card --%>

  </div><%-- /.admin-main --%>
</div><%-- /.admin-layout --%>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

