package cineverse.servlet;

import cineverse.dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DeleteProfileServlet")
public class DeleteProfileServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            UserDAO userDao = new UserDAO();
            boolean deleted = userDao.deleteUser(userId);

            if (deleted) {
                session.invalidate();
                // Create new session for message
                session = request.getSession();
                session.setAttribute("message", "Account deleted successfully!");
                session.setAttribute("messageType", "success");
                response.sendRedirect("login.jsp");
                return;
            } else {
                session.setAttribute("message", "Failed to delete account!");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }

        response.sendRedirect("profile.jsp");
    }
}
