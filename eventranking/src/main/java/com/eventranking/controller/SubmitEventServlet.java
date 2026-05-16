package com.eventranking.controller;

import com.eventranking.dao.EventDAO;
import com.eventranking.model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

/**
 * POST /submit-event — saves a student's event proposal with status='pending'.
 * GET  /submit-event — shows the submission form.
 */
@WebServlet("/submit-event")
public class SubmitEventServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setAttribute("today", LocalDate.now().toString());
        req.getRequestDispatcher("/submit-event.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // ── Auth guard ───────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp?redirect=/submit-event.jsp");
            return;
        }

        String title        = req.getParameter("title");
        String description  = req.getParameter("description");
        String category     = req.getParameter("category");
        String eventDateStr = req.getParameter("eventDate");
        String location     = req.getParameter("location");
        String contactEmail = req.getParameter("contactEmail");

        // ── Validation ───────────────────────────────────────
        if (isBlank(title) || isBlank(description) || isBlank(category)
                || isBlank(eventDateStr) || isBlank(location)) {
            req.setAttribute("error", "Please fill in all required fields.");
            req.setAttribute("today", LocalDate.now().toString());
            req.getRequestDispatcher("/submit-event.jsp").forward(req, res);
            return;
        }

        Date eventDate;
        try {
            eventDate = Date.valueOf(eventDateStr);
            if (eventDate.toLocalDate().isBefore(LocalDate.now())) {
                req.setAttribute("error", "Event date must be in the future.");
                req.setAttribute("today", LocalDate.now().toString());
                req.getRequestDispatcher("/submit-event.jsp").forward(req, res);
                return;
            }
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", "Invalid date format.");
            req.setAttribute("today", LocalDate.now().toString());
            req.getRequestDispatcher("/submit-event.jsp").forward(req, res);
            return;
        }

        try {
            int userId = (int) session.getAttribute("userId");

            Event event = new Event();
            event.setTitle(title.trim());
            event.setDescription(description.trim());
            event.setCategory(category);
            event.setEventDate(eventDate);
            event.setLocation(location.trim());
            event.setContactEmail(contactEmail != null ? contactEmail.trim() : null);
            event.setCreatedBy(userId);
            event.setStatus("pending");   // admin must approve

            int newId = eventDAO.createEvent(event);

            if (newId > 0) {
                req.getSession().setAttribute("successMsg",
                        "Event submitted! It will appear on the board after admin approval.");
                res.sendRedirect(req.getContextPath() + "/user-dashboard.jsp");
            } else {
                req.setAttribute("error", "Submission failed. Please try again.");
                req.getRequestDispatcher("/submit-event.jsp").forward(req, res);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Server error. Please try again.");
            req.setAttribute("today", LocalDate.now().toString());
            req.getRequestDispatcher("/submit-event.jsp").forward(req, res);
        }
    }

    private boolean isBlank(String s) { return s == null || s.isBlank(); }
}

