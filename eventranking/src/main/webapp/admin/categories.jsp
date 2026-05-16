<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-ctx="${pageContext.request.contextPath}">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Categories — Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>

<c:if test="${sessionScope.userRole != 'admin'}"><c:redirect url="/login.jsp"/></c:if>

<%-- Consume one-time flash messages --%>
<c:set var="catSuccess" value="${sessionScope.catSuccess}"/>
<c:set var="catError"   value="${sessionScope.catError}"/>
<c:remove var="catSuccess" scope="session"/>
<c:remove var="catError"   scope="session"/>

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
      <a href="${pageContext.request.contextPath}/admin/users"><span class="icon">👥</span> Manage Users</a>
      <div class="admin-sidebar__section-title">Settings</div>
      <a href="${pageContext.request.contextPath}/admin/categories/" class="active"><span class="icon">🗂️</span> Categories</a>
      <a href="${pageContext.request.contextPath}/home.jsp"><span class="icon">🏠</span> View Site</a>
      <a href="${pageContext.request.contextPath}/logout"><span class="icon">🚪</span> Sign Out</a>
    </nav>
  </aside>

  <div class="admin-main">

    <div class="flex-between mb-6" style="flex-wrap:wrap;gap:12px;">
      <div>
        <h1 style="font-size:1.4rem;font-weight:800;">🗂️ Manage Categories</h1>
        <p style="font-size:.875rem;color:var(--text-muted);">
          Categories drive the notice board filter sidebar and event submission form.
        </p>
      </div>
    </div>

    <c:if test="${not empty catSuccess}">
      <div class="alert alert--success" data-auto-dismiss>✅ ${catSuccess}</div>
    </c:if>
    <c:if test="${not empty catError}">
      <div class="alert alert--error" data-auto-dismiss>⚠️ ${catError}</div>
    </c:if>

    <div style="display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:start;">

      <%-- ── CATEGORY TABLE ─────────────────────────────── --%>
      <div class="card">
        <div class="card__header">
          <h3 style="font-size:.95rem;">
            All Categories (${fn:length(categories)})
          </h3>
        </div>
        <div class="table-wrap" style="border:none;border-radius:0;">
          <table class="table">
            <thead>
              <tr>
                <th>Icon</th>
                <th>Name</th>
                <th>Order</th>
                <th>Events</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="cat" items="${categories}">
                <tr>
                  <td style="font-size:1.3rem;">${cat.icon}</td>
                  <td style="font-weight:600;">${cat.name}</td>
                  <td style="color:var(--text-muted);">${cat.displayOrder}</td>
                  <td>
                    <span class="badge badge--blue">${cat.eventCount}</span>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${cat.active}">
                        <span class="badge badge--green">● Active</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge badge--gray">○ Hidden</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <div style="display:flex;gap:6px;">
                      <%-- Edit inline modal trigger --%>
                      <button class="btn btn--secondary btn--sm"
                              onclick="openEdit(${cat.categoryId},'${cat.name}','${cat.icon}',${cat.displayOrder},${cat.active})">
                        ✏️ Edit
                      </button>
                      <c:if test="${cat.eventCount == 0}">
                        <a href="${pageContext.request.contextPath}/admin/categories/delete?id=${cat.categoryId}"
                           class="btn btn--danger btn--sm"
                           onclick="return confirmDelete('Delete category \'${cat.name}\'?')">
                          🗑️
                        </a>
                      </c:if>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>

      <%-- ── ADD CATEGORY FORM ──────────────────────────── --%>
      <div class="card" style="position:sticky;top:80px;">
        <div class="card__header">
          <h3 style="font-size:.95rem;">➕ Add New Category</h3>
        </div>
        <div class="card__body">
          <form action="${pageContext.request.contextPath}/admin/categories/create"
                method="POST" data-validate>

            <div class="form-group">
              <label class="form-label">Category Name <span class="required">*</span></label>
              <input type="text" name="name" class="form-control"
                     placeholder="e.g. Cultural Fest" required/>
            </div>

            <div class="form-group">
              <label class="form-label">Icon Emoji</label>
              <input type="text" name="icon" class="form-control"
                     placeholder="🎪" maxlength="4"/>
              <div class="form-hint">Paste a single emoji (optional).</div>
            </div>

            <div class="form-group">
              <label class="form-label">Display Order</label>
              <input type="number" name="displayOrder" class="form-control"
                     placeholder="10" min="1" max="99" value="10"/>
              <div class="form-hint">Lower numbers appear first in the sidebar.</div>
            </div>

            <button type="submit" class="btn btn--primary btn--full">
              ➕ Create Category
            </button>
          </form>
        </div>
      </div>

    </div><!-- /grid -->

  </div><!-- /.admin-main -->
</div><!-- /.admin-layout -->

<%-- ── EDIT MODAL ─────────────────────────────────────────── --%>
<div id="editModal" class="modal-overlay" style="display:none;">
  <div class="modal">
    <div class="modal__header">
      <h3 style="font-size:1rem;">✏️ Edit Category</h3>
      <button class="modal__close" onclick="closeEdit()">✕</button>
    </div>
    <div class="modal__body">
      <form action="${pageContext.request.contextPath}/admin/categories/edit"
            method="POST" data-validate id="editForm">

        <input type="hidden" name="categoryId" id="editId"/>

        <div class="form-group">
          <label class="form-label">Category Name <span class="required">*</span></label>
          <input type="text" name="name" id="editName" class="form-control" required/>
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
          <div class="form-group">
            <label class="form-label">Icon</label>
            <input type="text" name="icon" id="editIcon" class="form-control" maxlength="4"/>
          </div>
          <div class="form-group">
            <label class="form-label">Order</label>
            <input type="number" name="displayOrder" id="editOrder" class="form-control" min="1" max="99"/>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Status</label>
          <select name="active" id="editActive" class="form-control">
            <option value="1">● Active (visible)</option>
            <option value="0">○ Hidden</option>
          </select>
        </div>

        <div class="modal__footer" style="padding:0;border:none;margin-top:16px;">
          <button type="button" class="btn btn--ghost" onclick="closeEdit()">Cancel</button>
          <button type="submit" class="btn btn--primary">💾 Save Changes</button>
        </div>

      </form>
    </div>
  </div>
</div>

<div id="toast-container"></div>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
  function openEdit(id, name, icon, order, active) {
    document.getElementById('editId').value     = id;
    document.getElementById('editName').value   = name;
    document.getElementById('editIcon').value   = icon;
    document.getElementById('editOrder').value  = order;
    document.getElementById('editActive').value = active ? '1' : '0';
    document.getElementById('editModal').style.display = 'flex';
  }
  function closeEdit() {
    document.getElementById('editModal').style.display = 'none';
  }
  // Close on backdrop click
  document.getElementById('editModal').addEventListener('click', function(e) {
    if (e.target === this) closeEdit();
  });
</script>
</body>
</html>

