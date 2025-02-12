package cineverse.servlet;

import cineverse.dao.UserDAO;
import cineverse.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            UserDAO userDao = new UserDAO();
            boolean updated = false;
            
            // Update basic info
            User user = new User();
            user.setId(userId);
            user.setName(name);
            user.setEmail(email);
            user.setPhoneNumber(phone);
            updated = userDao.updateUser(user);

            // Handle password update if provided
            if (currentPassword != null && !currentPassword.isEmpty() 
                && newPassword != null && !newPassword.isEmpty()) {
                
                if (!newPassword.equals(confirmPassword)) {
                    session.setAttribute("message", "New passwords don't match!");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect("profile.jsp");
                    return;
                }
                
                boolean passwordUpdated = userDao.updatePassword(userId, currentPassword, newPassword);
                if (!passwordUpdated) {
                    session.setAttribute("message", "Current password is incorrect!");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect("profile.jsp");
                    return;
                }
                updated = passwordUpdated;
            }

            if (updated) {
                session.setAttribute("user", user);
                session.setAttribute("message", "Profile updated successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Failed to update profile!");
                session.setAttribute("messageType", "error");
            }
            
        } catch (Exception e) {
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
        response.sendRedirect("profile.jsp");
    }
}
