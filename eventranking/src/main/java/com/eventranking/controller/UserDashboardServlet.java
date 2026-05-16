package com.eventranking.controller;

import com.eventranking.dao.*;
import com.eventranking.model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * GET /user-dashboard — populates user-dashboard.jsp with
 * bookmarks, submissions, and voted events.
 */
@WebServlet("/user-dashboard")
public class UserDashboardServlet extends HttpServlet {

    private final EventDAO eventDAO = new EventDAO();
    private final BookmarkDAO bookmarkDAO = new BookmarkDAO();
    private final VoteDAO voteDAO = new VoteDAO();
    private final ViewDAO viewDAO = new ViewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Consume one-time success message from submit redirect
        String successMsg = (String) session.getAttribute("successMsg");
        if (successMsg != null) {
            req.setAttribute("success", successMsg);
            session.removeAttribute("successMsg");
        }

        try {
            int userId = (int) session.getAttribute("userId");

            // Bookmarks
            List<Event> bookmarks = bookmarkDAO.getBookmarkedEvents(userId);
            req.setAttribute("myBookmarks", bookmarks);

            // My submissions (all statuses)
            List<Event> submissions = getMySubmissions(userId);
            req.setAttribute("mySubmissions", submissions);

            long approvedCount = submissions.stream()
            .filter(e -> "approved".equals(e.getStatus())).count();
            req.setAttribute("approvedCount", (int) approvedCount);

            // Voted events
            List<Event> voted = getVotedEvents(userId);
            req.setAttribute("myVotedEvents", voted);
            req.setAttribute("myVoteCount", voteDAO.countVotesByUser(userId));

            // Total views on this user's events
            req.setAttribute("totalViewsOnMyEvents", viewDAO.totalViewsOnUserEvents(userId));

            req.getRequestDispatcher("/user-dashboard.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Could not load dashboard.");
            req.getRequestDispatcher("/user-dashboard.jsp").forward(req, res);
        }
    }

    private List<Event> getMySubmissions(int userId) throws Exception {
        // Reuse admin DAO but filter by created_by
        return new EventDAO().getAllEventsAdmin(null, null, 0, 100)
                .stream()
                .filter(e -> e.getCreatedBy() == userId)
                .toList();
    }

    private List<Event> getVotedEvents(int userId) throws Exception {
        // Fetch approved ranked events the user voted for
        return new EventDAO().getRankedEvents("score", 0, 100, userId)
                .stream()
                .filter(Event::isUserVoted)
                .toList();
    }
}

