package com.eventranking.controller;

import com.eventranking.dao.EventDAO;
import com.eventranking.model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * Handles GET /events → populates home.jsp with ranked events,
 * category counts, pagination, and trending event.
 */
@WebServlet("/events")
public class EventServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        try {
            // ── Pagination ──────────────────────────────────
            int page = 1;
            try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); }
            catch (Exception ignored) {}

            int offset = (page - 1) * PAGE_SIZE;
            String sort = req.getParameter("sort");

            // ── Session user ────────────────────────────────
            HttpSession session = req.getSession(false);
            int userId = 0;
            if (session != null && session.getAttribute("userId") != null) {
                userId = (int) session.getAttribute("userId");
            }

            // ── Ranked events ────────────────────────────────
            List<Event> events = eventDAO.getRankedEvents(sort, offset, PAGE_SIZE, userId);
            int totalEvents    = eventDAO.countApprovedEvents();
            int totalPages     = (int) Math.ceil((double) totalEvents / PAGE_SIZE);

            // ── Category counts (sidebar) ─────────────────────
            req.setAttribute("workshopCount",    eventDAO.countByCategory("Workshop"));
            req.setAttribute("competitionCount", eventDAO.countByCategory("Competition"));
            req.setAttribute("internshipCount",  eventDAO.countByCategory("Internship"));
            req.setAttribute("clubCount",        eventDAO.countByCategory("Club Activity"));
            req.setAttribute("campusCount",      eventDAO.countByCategory("Campus Event"));
            req.setAttribute("seminarCount",     eventDAO.countByCategory("Seminar"));

            // ── Hero stats ───────────────────────────────────
            req.setAttribute("totalVotes", eventDAO.countTotalVotes());

            // ── Trending ─────────────────────────────────────
            req.setAttribute("trendingEvent", eventDAO.getTrendingEvent());

            // ── Bind to request ──────────────────────────────
            req.setAttribute("events",       events);
            req.setAttribute("totalEvents",  totalEvents);
            req.setAttribute("currentPage",  page);
            req.setAttribute("totalPages",   totalPages);

            req.getRequestDispatcher("/home.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Could not load events. Please try again.");
            req.getRequestDispatcher("/home.jsp").forward(req, res);
        }
    }
}

