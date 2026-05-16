package com.eventranking.controller;

import com.eventranking.dao.EventDAO;
import com.eventranking.dao.ViewDAO;
import com.eventranking.model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * GET /event?id=N
 * Shows event details, records a view, and fetches similar events.
 */
@WebServlet("/event")
public class EventDetailServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();
    private final ViewDAO  viewDAO  = new ViewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            res.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        try {
            int eventId = Integer.parseInt(idParam);

            HttpSession session = req.getSession(false);
            int userId = 0;
            if (session != null && session.getAttribute("userId") != null) {
                userId = (int) session.getAttribute("userId");
            }

            // ── Load event ───────────────────────────────────
            Event event = eventDAO.getEventById(eventId, userId);
            if (event == null) {
                res.sendRedirect(req.getContextPath() + "/home.jsp");
                return;
            }

            // ── Record view ──────────────────────────────────
            String ip = req.getHeader("X-Forwarded-For");
            if (ip == null) ip = req.getRemoteAddr();
            viewDAO.recordView(userId, eventId, ip);

            // ── Similar events ───────────────────────────────
            List<Event> similar = eventDAO.getSimilarEvents(eventId, event.getCategory(), 3);

            // ── ISO date for JS countdown ─────────────────────
            // Format: "2025-06-15T00:00:00"
            req.setAttribute("event",         event);
            req.setAttribute("similarEvents", similar);

            req.getRequestDispatcher("/event-details.jsp").forward(req, res);

        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/home.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Could not load event.");
            req.getRequestDispatcher("/event-details.jsp").forward(req, res);
        }
    }
}

