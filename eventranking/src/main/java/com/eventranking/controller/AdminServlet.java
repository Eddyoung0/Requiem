package com.eventranking.controller;

import com.eventranking.dao.EventDAO;
import com.eventranking.dao.UserDAO;
import com.eventranking.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
/**
 * Central admin controller mapped to /admin/*
 *
 * Routes:
 *  GET  /admin/dashboard        → admin-dashboard.jsp
 *  GET  /admin/events           → event list with filter/search
 *  GET  /admin/events/create    → create event form
 *  POST /admin/events/create    → save new event
 *  GET  /admin/events/edit?id=N → edit event form
 *  POST /admin/events/edit      → update event
 *  GET  /admin/events/delete?id=N → delete event
 *  POST /admin/events           → approve/reject (AJAX + redirect)
 *  GET  /admin/users            → user list
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private static final int PAGE_SIZE = 15;
    private final EventDAO eventDAO = new EventDAO();
    private final UserDAO  userDAO  = new UserDAO();

    // ── Auth helper ──────────────────────────────────────────
    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && "admin".equals(s.getAttribute("userRole"));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        String path = req.getPathInfo();               // e.g. "/dashboard"
        if (path == null) path = "/dashboard";
        try {
            switch (path) {
                case "/dashboard" -> handleDashboard(req, res);
                case "/events"    -> handleEventList(req, res);
                case "/events/create" -> handleEventCreateForm(req, res);
                case "/events/edit"   -> handleEventEditForm(req, res);
                case "/events/delete" -> handleEventDelete(req, res);
                case "/users"         -> handleUserList(req, res);
                default -> res.sendRedirect(req.getContextPath() + "/admin/dashboard");
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        String path = req.getPathInfo();
        if (path == null) path = "";
        try {
            switch (path) {
                case "/events"        -> handleEventAction(req, res);  // approve/reject
                case "/events/create" -> handleEventCreateSave(req, res);
                case "/events/edit"   -> handleEventEditSave(req, res);
                case "/users"         -> handleUserAction(req, res);
                default -> res.sendRedirect(req.getContextPath() + "/admin/dashboard");
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    // ── DASHBOARD ────────────────────────────────────────────
    private void handleDashboard(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        req.setAttribute("totalEvents",       eventDAO.countApprovedEvents());
        req.setAttribute("pendingCount",      eventDAO.countPendingEvents());
        req.setAttribute("totalUsers",        userDAO.countAllUsers());
        req.setAttribute("totalVotes",        eventDAO.countTotalVotes());
        req.setAttribute("newEventsThisWeek", eventDAO.countNewEventsThisWeek());
        req.setAttribute("newUsersThisWeek",  userDAO.countNewUsersThisWeek());
        req.setAttribute("pendingEvents",     eventDAO.getPendingEvents());
        req.setAttribute("topEvents",         eventDAO.getTopRankedEvents(5));
        req.setAttribute("allEvents",         eventDAO.getAllEventsAdmin(null, null, 0, PAGE_SIZE));
        req.setAttribute("currentPage", 1);
        req.setAttribute("totalPages", 1);
        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, res);
    }

    // ── EVENT LIST ────────────────────────────────────────────
    private void handleEventList(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        String filter = req.getParameter("filter");
        String search = req.getParameter("search");
        int page      = parsePage(req.getParameter("page"));
        int offset    = (page - 1) * PAGE_SIZE;
        List<Event> events = eventDAO.getAllEventsAdmin(filter, search, offset, PAGE_SIZE);
        int total          = eventDAO.countAllEventsAdmin(filter, search);
        int totalPages     = (int) Math.ceil((double) total / PAGE_SIZE);
        req.setAttribute("allEvents",    events);
        req.setAttribute("currentPage",  page);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("pendingCount", eventDAO.countPendingEvents());
        // Re-use dashboard for event list too (or create a separate event-list.jsp)
        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, res);
    }

    // ── CREATE EVENT FORM ────────────────────────────────────
    private void handleEventCreateForm(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        req.setAttribute("today", LocalDate.now().toString());
        req.getRequestDispatcher("/admin/create-event.jsp").forward(req, res);
    }

    private void handleEventCreateSave(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        Event event = buildEventFromRequest(req);
        int userId  = (int) req.getSession().getAttribute("userId");
        event.setCreatedBy(userId);
        event.setStatus("approved");  // admin-created events are auto-approved
        int newId = eventDAO.createEvent(event);
        if (newId > 0) {
            req.getSession().setAttribute("successMsg", "Event created successfully.");
        }
        res.sendRedirect(req.getContextPath() + "/admin/dashboard");
    }

    // ── EDIT EVENT ────────────────────────────────────────────
    private void handleEventEditForm(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        int eventId = Integer.parseInt(req.getParameter("id"));
        Event event = eventDAO.getEventByIdAdmin(eventId);
        req.setAttribute("editEvent", event);
        req.getRequestDispatcher("/admin/edit-event.jsp").forward(req, res);
    }

    private void handleEventEditSave(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        Event event = buildEventFromRequest(req);
        int eventId = Integer.parseInt(req.getParameter("eventId"));
        event.setEventId(eventId);
        event.setStatus(req.getParameter("status"));
        eventDAO.updateEvent(event);
        res.sendRedirect(req.getContextPath() + "/admin/dashboard");
    }

    // ── DELETE ────────────────────────────────────────────────
    private void handleEventDelete(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        int eventId = Integer.parseInt(req.getParameter("id"));
        eventDAO.deleteEvent(eventId);
        res.sendRedirect(req.getContextPath() + "/admin/dashboard");
    }

    // ── APPROVE / REJECT (AJAX or form POST) ─────────────────
    private void handleEventAction(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        String action  = req.getParameter("action");
        int    eventId = Integer.parseInt(req.getParameter("eventId"));
        boolean ok = switch (action) {
            case "approve" -> eventDAO.updateStatus(eventId, "approved");
            case "reject"  -> eventDAO.updateStatus(eventId, "rejected");
            default        -> false;
        };
        // If AJAX (Accept: application/json), return JSON; else redirect
        String accept = req.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            res.setContentType("application/json;charset=UTF-8");
            res.getWriter().write("{\"success\":" + ok + "}");
        } else {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    // ── USER LIST ─────────────────────────────────────────────
    private void handleUserList(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        req.setAttribute("users", userDAO.getAllUsers());
        req.getRequestDispatcher("/admin/user-list.jsp").forward(req, res);
    }

    private void handleUserAction(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        String action = req.getParameter("action");
        int userId    = Integer.parseInt(req.getParameter("userId"));
        if ("deactivate".equals(action)) userDAO.updateStatus(userId, "inactive");
        if ("activate".equals(action))   userDAO.updateStatus(userId, "active");
        if ("delete".equals(action))     userDAO.deleteUser(userId);
        res.sendRedirect(req.getContextPath() + "/admin/users");
    }

    // ── HELPERS ───────────────────────────────────────────────
    private Event buildEventFromRequest(HttpServletRequest req) {
        Event e = new Event();
        e.setTitle(req.getParameter("title").trim());
        e.setDescription(req.getParameter("description").trim());
        e.setCategory(req.getParameter("category"));
        e.setEventDate(Date.valueOf(req.getParameter("eventDate")));
        e.setLocation(req.getParameter("location").trim());
        String ce = req.getParameter("contactEmail");
        e.setContactEmail(ce != null ? ce.trim() : null);
        return e;
    }

    private int parsePage(String p) {
        try { return Math.max(1, Integer.parseInt(p)); }
        catch (Exception e) { return 1; }
    }
}

