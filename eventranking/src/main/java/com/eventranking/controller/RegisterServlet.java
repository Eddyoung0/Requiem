package com.eventranking.controller;

import com.eventranking.dao.UserDAO;
import com.eventranking.model.User;
import org.mindrot.jbcrypt.BCrypt;
import com.eventranking.util.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s != null && s.getAttribute("userId") != null) {
            res.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        req.getRequestDispatcher("/register.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Validation
        if (isBlank(name) || isBlank(email) || isBlank(password)) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        if (password.length() < 8) {
            req.setAttribute("error", "Password must be at least 8 characters.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        if (!email.matches("^[\\w.+-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        try {
            if (userDAO.emailExists(email.trim().toLowerCase())) {
                req.setAttribute("error", "An account with this email already exists.");
                req.getRequestDispatcher("/register.jsp").forward(req, res);
                return;
            }

            // Create user 
            User user = new User();
            user.setName(name.trim());
            user.setEmail(email.trim().toLowerCase());
            user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt(10)));
            user.setRole("student");
            user.setStatus("active");

            int newId = userDAO.createUser(user);
            if (newId > 0) {
                // Send welcome email (non-blocking)
                try {
                    String appUrl = req.getScheme() + "://" + req.getServerName()
                            + ":" + req.getServerPort() + req.getContextPath();
                    EmailService.sendWelcomeEmail(user.getEmail(), user.getName(), appUrl);
                } catch (Exception ignored) {}
                res.sendRedirect(req.getContextPath()
                        + "/login.jsp?success=Account+created!+Please+sign+in.");
            } else {
                req.setAttribute("error", "Registration failed. Please try again.");
                req.getRequestDispatcher("/register.jsp").forward(req, res);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "A server error occurred. Please try again.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
        }
    }

    private boolean isBlank(String s) { return s == null || s.isBlank(); }
}

