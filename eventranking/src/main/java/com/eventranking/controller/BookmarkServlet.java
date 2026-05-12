package com.eventranking.controller;

import com.eventranking.dao.BookmarkDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * POST /bookmark?eventId=N&action=add|remove
 * AJAX endpoint — responds with JSON {success, bookmarked, message}
 */
@WebServlet("/bookmark")
public class BookmarkServlet extends HttpServlet {

    private final BookmarkDAO bookmarkDAO = new BookmarkDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.getWriter().write("{\"success\":false,\"message\":\"Please login to bookmark.\"}");
            return;
        }

        String idParam = req.getParameter("eventId");
        String action  = req.getParameter("action");

        if (idParam == null || action == null) {
            res.getWriter().write("{\"success\":false,\"message\":\"Invalid request.\"}");
            return;
        }

        try {
            int userId  = (int) session.getAttribute("userId");
            int eventId = Integer.parseInt(idParam);

            boolean result;
            boolean nowBookmarked;

            if ("add".equals(action)) {
                result = bookmarkDAO.addBookmark(userId, eventId);
                nowBookmarked = true;
            } else {
                result = bookmarkDAO.removeBookmark(userId, eventId);
                nowBookmarked = false;
            }

            res.getWriter().write(
                    "{\"success\":" + result
                    + ",\"bookmarked\":" + nowBookmarked + "}");

        } catch (NumberFormatException e) {
            res.getWriter().write("{\"success\":false,\"message\":\"Invalid event ID.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("{\"success\":false,\"message\":\"Server error.\"}");
        }
    }
}

