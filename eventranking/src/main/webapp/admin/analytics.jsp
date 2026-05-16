<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Analytics — Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <!-- Chart.js CDN -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
</head>
<body>

<c:if test="${sessionScope.userRole != 'admin'}"><c:redirect url="/login.jsp"/></c:if>

<div class="admin-layout">

  <!-- Sidebar -->
  <aside class="admin-sidebar">
    <div class="admin-sidebar__logo">⚙️ Admin Panel</div>
    <nav class="admin-sidebar__nav">
      <div class="admin-sidebar__section-title">Overview</div>
      <a href="${pageContext.request.contextPath}/admin/dashboard"><span class="icon">📊</span> Dashboard</a>
      <a href="${pageContext.request.contextPath}/admin/analytics" class="active"><span class="icon">📈</span> Analytics</a>
      <div class="admin-sidebar__section-title">Events</div>
      <a href="${pageContext.request.contextPath}/admin/events"><span class="icon">📋</span> All Events</a>
      <a href="${pageContext.request.contextPath}/admin/events?filter=pending"><span class="icon">⏳</span> Pending</a>
      <a href="${pageContext.request.contextPath}/admin/events/create"><span class="icon">➕</span> Create Event</a>
      <div class="admin-sidebar__section-title">Users</div>
      <a href="${pageContext.request.contextPath}/admin/users"><span class="icon">👥</span> Manage Users</a>
      <div class="admin-sidebar__section-title">Settings</div>
      <a href="${pageContext.request.contextPath}/admin/categories"><span class="icon">🗂️</span> Categories</a>
      <a href="${pageContext.request.contextPath}/home.jsp"><span class="icon">🏠</span> View Site</a>
      <a href="${pageContext.request.contextPath}/logout"><span class="icon">🚪</span> Sign Out</a>
    </nav>
  </aside>

  <div class="admin-main">

    <!-- Header -->
    <div class="flex-between mb-6" style="flex-wrap:wrap;gap:12px;">
      <div>
        <h1 style="font-size:1.4rem;font-weight:800;">📈 Analytics</h1>
        <p style="font-size:.875rem;color:var(--text-muted);">Engagement, growth, and ranking insights</p>
      </div>
      <!-- Date range selector -->
      <form action="${pageContext.request.contextPath}/admin/analytics" method="GET"
            style="display:flex;gap:8px;align-items:center;">
        <label style="font-size:.85rem;font-weight:600;color:var(--text-secondary);">Last</label>
        <select name="days" class="form-control" style="width:100px;padding:7px 12px;font-size:.85rem;"
                onchange="this.form.submit()">
          <option value="7"  ${selectedDays==7  ? 'selected' : ''}>7 days</option>
          <option value="14" ${selectedDays==14 ? 'selected' : ''}>14 days</option>
          <option value="30" ${selectedDays==30 ? 'selected' : ''}>30 days</option>
          <option value="90" ${selectedDays==90 ? 'selected' : ''}>90 days</option>
        </select>
      </form>
    </div>

    <!-- Summary stat cards -->
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:14px;margin-bottom:24px;">
      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--blue">📋</div>
        <div><div class="stat-card__value">${totalEvents}</div><div class="stat-card__label">Total Events</div></div>
      </div>
      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--green">👥</div>
        <div><div class="stat-card__value">${totalUsers}</div><div class="stat-card__label">Users</div></div>
      </div>
      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--purple">👍</div>
        <div><div class="stat-card__value">${totalVotes}</div><div class="stat-card__label">Total Votes</div></div>
      </div>
      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--yellow">🔖</div>
        <div><div class="stat-card__value">${totalBookmarks}</div><div class="stat-card__label">Bookmarks</div></div>
      </div>
      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--blue">👁️</div>
        <div><div class="stat-card__value">${totalViews}</div><div class="stat-card__label">Total Views</div></div>
      </div>
    </div>

    <!-- Row 1: Engagement line + Category doughnut -->
    <div style="display:grid;grid-template-columns:2fr 1fr;gap:20px;margin-bottom:20px;">

      <!-- Engagement Line Chart -->
      <div class="card">
        <div class="card__header">
          <h3 style="font-size:.95rem;">📊 Daily Engagement (last ${selectedDays} days)</h3>
        </div>
        <div class="card__body">
          <canvas id="engagementChart" height="100"></canvas>
        </div>
      </div>

      <!-- Category Doughnut Chart -->
      <div class="card">
        <div class="card__header">
          <h3 style="font-size:.95rem;">🗂️ Events by Category</h3>
        </div>
        <div class="card__body" style="display:flex;align-items:center;justify-content:center;">
          <canvas id="categoryChart" height="180"></canvas>
        </div>
      </div>

    </div>

    <!-- Row 2: Registrations bar + Top users -->
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px;">

      <!-- Registrations Bar Chart -->
      <div class="card">
        <div class="card__header">
          <h3 style="font-size:.95rem;">👥 New Registrations (last ${selectedDays} days)</h3>
        </div>
        <div class="card__body">
          <canvas id="registrationsChart" height="120"></canvas>
        </div>
      </div>

      <!-- Top Active Users horizontal bar -->
      <div class="card">
        <div class="card__header">
          <h3 style="font-size:.95rem;">🏆 Most Active Users (by votes cast)</h3>
        </div>
        <div class="card__body">
          <canvas id="topUsersChart" height="120"></canvas>
        </div>
      </div>

    </div>

    <!-- Top Users Table -->
    <div class="card">
      <div class="card__header">
        <h3 style="font-size:.95rem;">👥 Top Active Users Detail</h3>
      </div>
      <div class="table-wrap" style="border:none;border-radius:0;">
        <table class="table">
          <thead>
            <tr><th>#</th><th>User</th><th>Votes Cast</th><th>Activity Bar</th></tr>
          </thead>
          <tbody>
            <c:set var="maxVotes" value="1"/>
            <c:forEach var="u" items="${topUsers}">
              <c:if test="${u.votes > maxVotes}"><c:set var="maxVotes" value="${u.votes}"/></c:if>
            </c:forEach>
            <c:forEach var="u" items="${topUsers}" varStatus="st">
              <tr>
                <td style="color:var(--text-muted);">${st.index+1}</td>
                <td>
                  <div style="display:flex;align-items:center;gap:10px;">
                    <div style="width:30px;height:30px;border-radius:50%;background:var(--primary);
                                color:#fff;display:flex;align-items:center;justify-content:center;
                                font-weight:700;font-size:.8rem;">
                      ${fn:substring(u.name,0,1)}
                    </div>
                    <span style="font-weight:600;">${u.name}</span>
                  </div>
                </td>
                <td><strong>${u.votes}</strong></td>
                <td style="width:40%;">
                  <div class="progress">
                    <div class="progress__bar progress__bar--primary"
                         style="width:${maxVotes > 0 ? (u.votes * 100 / maxVotes) : 0}%"></div>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

  </div><!-- /.admin-main -->
</div><!-- /.admin-layout -->

<!-- Pass JSON data to JS -->
<script>
  const ENGAGEMENT_DATA   = ${engagementData};
  const CATEGORY_DATA     = ${categoryData};
  const REGISTRATION_DATA = ${registrationData};
  const TOP_USERS_DATA    = ${topUsersData};
</script>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script src="${pageContext.request.contextPath}/js/charts.js"></script>
</body>
</html>

