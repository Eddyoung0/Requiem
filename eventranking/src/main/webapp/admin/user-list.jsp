<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Users — Admin</title>
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
      <a href="${pageContext.request.contextPath}/admin/events"><span class="icon">📋</span> All Events</a>
      <a href="${pageContext.request.contextPath}/admin/events?filter=pending"><span class="icon">⏳</span> Pending</a>
      <a href="${pageContext.request.contextPath}/admin/events/create"><span class="icon">➕</span> Create Event</a>
      <div class="admin-sidebar__section-title">Users</div>
      <a href="${pageContext.request.contextPath}/admin/users" class="active"><span class="icon">👥</span> Manage Users</a>
      <div class="admin-sidebar__section-title">Settings</div>
      <a href="${pageContext.request.contextPath}/home.jsp"><span class="icon">🏠</span> View Site</a>
      <a href="${pageContext.request.contextPath}/logout"><span class="icon">🚪</span> Sign Out</a>
    </nav>
  </aside>

  <div class="admin-main">

    <div class="flex-between mb-6" style="flex-wrap:wrap;gap:12px;">
      <div>
        <h1 style="font-size:1.4rem;font-weight:800;">👥 Manage Users</h1>
        <p style="font-size:.875rem;color:var(--text-muted);margin-top:2px;">
          ${fn:length(users)} registered user${fn:length(users) != 1 ? 's' : ''}
        </p>
      </div>
    </div>

    <c:if test="${not empty success}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${success}</div>
    </c:if>

    <div class="card">
      <div class="table-wrap" style="border:none;border-radius:0;">
        <table class="table">
          <thead>
            <tr>
              <th>#</th>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
              <th>Status</th>
              <th>Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="user" items="${users}" varStatus="st">
              <tr>
                <td style="color:var(--text-muted);font-size:.82rem;">${st.index + 1}</td>
                <td>
                  <div style="display:flex;align-items:center;gap:10px;">
                    <div style="width:32px;height:32px;border-radius:50%;background:var(--primary);
                                color:#fff;display:flex;align-items:center;justify-content:center;
                                font-weight:700;font-size:.85rem;flex-shrink:0;">
                      ${fn:substring(user.name,0,1)}
                    </div>
                    <span style="font-weight:600;">${user.name}</span>
                  </div>
                </td>
                <td style="font-size:.875rem;">${user.email}</td>
                <td>
                  <c:choose>
                    <c:when test="${user.role == 'admin'}">
                      <span class="badge badge--purple">⚙️ Admin</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge badge--blue">🎓 Student</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${user.status == 'active'}">
                      <span class="badge badge--green">● Active</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge badge--gray">○ Inactive</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td style="font-size:.82rem;white-space:nowrap;">${user.createdAt}</td>
                <td>
                  <%-- Don't allow admin to deactivate themselves --%>
                  <c:if test="${user.userId != sessionScope.userId}">
                    <div style="display:flex;gap:6px;">
                      <c:choose>
                        <c:when test="${user.status == 'active'}">
                          <form action="${pageContext.request.contextPath}/admin/users"
                                method="POST" style="display:inline;">
                            <input type="hidden" name="action"  value="deactivate"/>
                            <input type="hidden" name="userId"  value="${user.userId}"/>
                            <button type="submit" class="btn btn--ghost btn--sm"
                                    onclick="return confirm('Deactivate ${user.name}?')"
                                    title="Deactivate">🔒</button>
                          </form>
                        </c:when>
                        <c:otherwise>
                          <form action="${pageContext.request.contextPath}/admin/users"
                                method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="activate"/>
                            <input type="hidden" name="userId" value="${user.userId}"/>
                            <button type="submit" class="btn btn--success btn--sm"
                                    title="Activate">🔓</button>
                          </form>
                        </c:otherwise>
                      </c:choose>
                      <c:if test="${user.role != 'admin'}">
                        <form action="${pageContext.request.contextPath}/admin/users"
                              method="POST" style="display:inline;">
                          <input type="hidden" name="action" value="delete"/>
                          <input type="hidden" name="userId" value="${user.userId}"/>
                          <button type="submit" class="btn btn--danger btn--sm"
                                  onclick="return confirmDelete('Delete user ${user.name}? This cannot be undone.')"
                                  title="Delete">🗑️</button>
                        </form>
                      </c:if>
                    </div>
                  </c:if>
                  <c:if test="${user.userId == sessionScope.userId}">
                    <span style="font-size:.78rem;color:var(--text-muted);">You</span>
                  </c:if>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</div>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

