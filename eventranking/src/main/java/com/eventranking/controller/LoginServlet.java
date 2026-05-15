package com.eventranking.controller;

import com.eventranking.dao.UserDAO;
import com.eventranking.model.User;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /** GET /login → show login page */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // If already logged in, redirect home
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            res.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, res);
    }

    /** POST /login → authenticate */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        // Basic input validation
        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }

        try {
            User user = userDAO.getUserByEmail(email.trim().toLowerCase());

            if (user == null || !BCrypt.checkpw(password, user.getPassword())) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/login.jsp").forward(req, res);
                return;
            }

            if (!user.isActive()) {
                req.setAttribute("error", "Your account has been deactivated. Please contact admin.");
                req.getRequestDispatcher("/login.jsp").forward(req, res);
                return;
            }

            // Create session 
            HttpSession session = req.getSession(true);
            session.setAttribute("userId",   user.getUserId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userRole",  user.getRole());
            session.setMaxInactiveInterval(30 * 60);

            // Remember Me cookie
            if ("on".equals(req.getParameter("rememberMe"))) {
                com.eventranking.util.RememberMeFilter.issueToken(req, res, user.getUserId());
            }

            // Redirect admin to admin dashboard, student to home
            if (user.isAdmin()) {
                res.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                String redirect = req.getParameter("redirect");
                res.sendRedirect(redirect != null && !redirect.isBlank()
                        ? redirect
                        : req.getContextPath() + "/home.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "A server error occurred. Please try again.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
        }
    }
}

