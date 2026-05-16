package com.eventranking.controller;

import com.eventranking.dao.CategoryDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * GET  /admin/categories         → list
 * POST /admin/categories/create  → create
 * POST /admin/categories/edit    → update
 * GET  /admin/categories/delete  → delete
 */
@WebServlet("/admin/categories/*")
public class CategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && "admin".equals(s.getAttribute("userRole"));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        String path = req.getPathInfo();
        try {
            if (path == null || path.equals("/")) {
                showList(req, res);
            } else if (path.equals("/delete")) {
                handleDelete(req, res);
            } else {
                showList(req, res);
            }
        } catch (Exception e) {
            throw new ServletException("Error handling category GET request", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req)) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        String path = req.getPathInfo();
        try {
            if ("/create".equals(path)) handleCreate(req, res);
            else if ("/edit".equals(path)) handleEdit(req, res);
            else res.sendRedirect(req.getContextPath() + "/admin/categories/");
        } catch (Exception e) {
            throw new ServletException("Error handling category POST request", e);
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        req.setAttribute("categories", categoryDAO.getAllCategoriesAdmin());
        req.getRequestDispatcher("/admin/categories.jsp").forward(req, res);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        String name  = req.getParameter("name");
        String icon  = req.getParameter("icon");
        int    order = 99;
        try { order = Integer.parseInt(req.getParameter("displayOrder")); } catch (Exception ignored) {}

        if (name != null && !name.isBlank()) {
            categoryDAO.createCategory(name.trim(), icon, order);
            req.getSession().setAttribute("catSuccess", "Category \"" + name.trim() + "\" created.");
        }
        res.sendRedirect(req.getContextPath() + "/admin/categories/");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("categoryId"));
        String name = req.getParameter("name");
        String icon = req.getParameter("icon");
        int order  = 99;
        boolean active = "1".equals(req.getParameter("active"));
        try { order = Integer.parseInt(req.getParameter("displayOrder")); } catch (Exception ignored) {}

        categoryDAO.updateCategory(id, name.trim(), icon, order, active);
        res.sendRedirect(req.getContextPath() + "/admin/categories/");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean deleted = categoryDAO.deleteCategory(id);
        if (!deleted) {
            req.getSession().setAttribute("catError",
                    "Cannot delete: this category is used by existing events.");
        }
        res.sendRedirect(req.getContextPath() + "/admin/categories/");
    }
}

