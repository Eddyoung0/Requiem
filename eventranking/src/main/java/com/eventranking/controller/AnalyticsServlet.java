package com.eventranking.controller;

import com.eventranking.dao.AnalyticsDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * GET /admin/analytics — loads chart data for admin-analytics.jsp
 */
@WebServlet("/admin/analytics")
public class AnalyticsServlet extends HttpServlet {

    private final AnalyticsDAO analyticsDAO = new AnalyticsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int days = 14;
            try { days = Math.min(90, Math.max(7,
                    Integer.parseInt(req.getParameter("days")))); }
            catch (Exception ignored) {}

            // ── Engagement line chart (votes / bookmarks / views per day) ──
            List<Map<String, Object>> engagement = analyticsDAO.getDailyEngagement(days);
            req.setAttribute("engagementData", toJson(engagement));

            // ── Category doughnut chart ──────────────────────────────────
            List<Map<String, Object>> byCat = analyticsDAO.getEventsByCategory();
            req.setAttribute("categoryData", toJson(byCat));

            // ── Registrations bar chart ──────────────────────────────────
            List<Map<String, Object>> registrations = analyticsDAO.getDailyRegistrations(days);
            req.setAttribute("registrationData", toJson(registrations));

            // ── Top active users ─────────────────────────────────────────
            List<Map<String, Object>> topUsers = analyticsDAO.getTopActiveUsers(8);
            req.setAttribute("topUsers", topUsers);
            req.setAttribute("topUsersData", toJson(topUsers));

            // ── Summary totals ───────────────────────────────────────────
            Map<String, Integer> totals = analyticsDAO.getSummaryTotals();
            totals.forEach(req::setAttribute);

            req.setAttribute("selectedDays", days);

            req.getRequestDispatcher("/admin/analytics.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Could not load analytics: " + e.getMessage());
            req.getRequestDispatcher("/admin/analytics.jsp").forward(req, res);
        }
    }

    /** Serialize a list/map to a JSON string for inline use in Chart.js. */
    private String toJson(Object obj) {
        try {
            // Simple hand-rolled serialiser — avoids adding Jackson dependency
            if (obj instanceof List<?> list) {
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) sb.append(",");
                    sb.append(mapToJson((Map<?, ?>) list.get(i)));
                }
                sb.append("]");
                return sb.toString();
            }
            return "[]";
        } catch (Exception e) {
            return "[]";
        }
    }

    private String mapToJson(Map<?, ?> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<?, ?> entry : map.entrySet()) {
            if (!first) sb.append(",");
            first = false;
            sb.append("\"").append(entry.getKey()).append("\":");
            Object v = entry.getValue();
            if (v instanceof Number) sb.append(v);
            else sb.append("\"").append(v.toString().replace("\"", "\\\"")).append("\"");
        }
        sb.append("}");
        return sb.toString();
    }
}

