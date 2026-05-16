package com.eventranking.util;

import com.eventranking.dao.UserDAO;
import com.eventranking.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.*;
import java.util.Base64;

/**
 * "Remember Me" implementation using a secure token cookie.
 *
 * Flow:
 *  1. On login with rememberMe=on → generate token, store in DB, set cookie (30 days)
 *  2. On every request → if no session but cookie present → look up token, restore session
 *  3. On logout → delete token from DB, clear cookie
 */

@WebFilter("/*")
public class RememberMeFilter implements Filter {

    private static final String COOKIE_NAME = "campus_rm";
    private static final int COOKIE_DAYS = 30;
    private static final int COOKIE_SECS = COOKIE_DAYS * 24 * 3600;
    private static final SecureRandom RNG = new SecureRandom();

    private UserDAO userDAO;

    @Override
    public void init(FilterConfig cfg) {
        userDAO = new UserDAO();
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest hReq = (HttpServletRequest) req;
        HttpServletResponse hRes = (HttpServletResponse) res;
        HttpSession session = hReq.getSession(false);

        // If no active session, try to restore from cookie
        if (session == null || session.getAttribute("userId") == null) {
            Cookie rmCookie = findCookie(hReq.getCookies(), COOKIE_NAME);
            if (rmCookie != null) {
                restoreSession(hReq, hRes, rmCookie.getValue());
            }
        }

        chain.doFilter(req, res);
    }

    // Public helpers called by LoginServlet / LogoutServlet

    /** Called after successful login when user checked "Remember Me". */
    public static void issueToken(HttpServletRequest req, HttpServletResponse res, int userId) {
        String token = generateToken();
        try {
            String sql = """
                INSERT INTO remember_tokens (user_id, token, expires_at)
                VALUES (?, ?, NOW() + INTERVAL 30 DAY)
                ON DUPLICATE KEY UPDATE token=VALUES(token), expires_at=VALUES(expires_at)
                """;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setString(2, token);
                ps.executeUpdate();
            }
            Cookie cookie = new Cookie(COOKIE_NAME, token);
            cookie.setMaxAge(COOKIE_SECS);
            cookie.setHttpOnly(true);
            cookie.setPath("/");
            res.addCookie(cookie);
        } catch (SQLException e) {
            System.err.println("[RememberMe] Could not issue token: " + e.getMessage());
        }
    }

    /** Called on logout to revoke the token. */
    public static void revokeToken(HttpServletRequest req, HttpServletResponse res) {
        Cookie rmCookie = findCookie(req.getCookies(), COOKIE_NAME);
        if (rmCookie != null) {
            try {
                String sql = "DELETE FROM remember_tokens WHERE token=?";
                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, rmCookie.getValue());
                    ps.executeUpdate();
                }
            } catch (SQLException e) {
                System.err.println("[RememberMe] Could not revoke token: " + e.getMessage());
            }
            // Expire the cookie
            rmCookie.setMaxAge(0);
            rmCookie.setPath("/");
            res.addCookie(rmCookie);
        }
    }

    // Private Methods

    private void restoreSession(HttpServletRequest req, HttpServletResponse res, String token) {
        try {
            String sql = """
                SELECT u.user_id, u.name, u.email, u.role
                FROM remember_tokens rt
                JOIN users u ON rt.user_id = u.user_id
                WHERE rt.token = ? AND rt.expires_at > NOW() AND u.status = 'active'
                """;
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, token);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        HttpSession session = req.getSession(true);
                        session.setAttribute("userId", rs.getInt("user_id"));
                        session.setAttribute("userName", rs.getString("name"));
                        session.setAttribute("userEmail", rs.getString("email"));
                        session.setAttribute("userRole", rs.getString("role"));
                        session.setMaxInactiveInterval(30 * 60);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[RememberMe] Error restoring session: " + e.getMessage());
        }
    }

    private static String generateToken() {
        byte[] bytes = new byte[32];
        RNG.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static Cookie findCookie(Cookie[] cookies, String name) {
        if (cookies == null) return null;
        for (Cookie c : cookies) if (name.equals(c.getName())) return c;
        return null;
    }
}

