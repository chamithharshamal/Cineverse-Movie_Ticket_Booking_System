package cineverse.servlet;

import cineverse.dao.UserDAO;
import cineverse.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phoneNumber = request.getParameter("phoneNumber");
        String role = request.getParameter("role");
        UserDAO userDao = new UserDAO();
        
        if (userDao.checkEmail(email)) {
            response.sendRedirect("login.jsp?msg=exists");
            return;
        }
        
        User user = new User(name, email, password, phoneNumber, role);
        
        if (userDao.registerUser(user)) {
            response.sendRedirect("login.jsp?msg=success");
        } else {
            response.sendRedirect("login.jsp?msg=error");
        }
    }
}
