package com.eventranking.controller;

import com.eventranking.dao.VoteDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * POST /vote?eventId=N
 * AJAX endpoint — responds with JSON {success, newCount, message}
 */
@WebServlet("/vote")
public class VoteServlet extends HttpServlet {

    private final VoteDAO voteDAO = new VoteDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json;charset=UTF-8");

        // ── Auth check ───────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.getWriter().write("{\"success\":false,\"message\":\"Please login to vote.\"}");
            return;
        }

        String idParam = req.getParameter("eventId");
        if (idParam == null) {
            res.getWriter().write("{\"success\":false,\"message\":\"Invalid request.\"}");
            return;
        }

        try {
            int userId  = (int) session.getAttribute("userId");
            int eventId = Integer.parseInt(idParam);

            int newCount = voteDAO.addVote(userId, eventId);

            if (newCount == -1) {
                res.getWriter().write("{\"success\":false,\"message\":\"You have already voted for this event.\"}");
            } else {
                res.getWriter().write(
                        "{\"success\":true,\"newCount\":" + newCount + "}");
            }

        } catch (NumberFormatException e) {
            res.getWriter().write("{\"success\":false,\"message\":\"Invalid event ID.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("{\"success\":false,\"message\":\"Server error. Please try again.\"}");
        }
    }
}

