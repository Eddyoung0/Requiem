package com.eventranking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        com.eventranking.util.RememberMeFilter.revokeToken(req, res);
        if (session != null) session.invalidate();
        res.sendRedirect(req.getContextPath() + "/login.jsp?success=You+have+been+signed+out.");
    }
}
