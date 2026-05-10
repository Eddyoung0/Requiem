package com.eventranking.controller;

import com.eventranking.dao.VoteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/vote"})
public class VoteServlet extends HttpServlet {
   private final VoteDAO voteDAO = new VoteDAO();

   public VoteServlet() {
   }
}
