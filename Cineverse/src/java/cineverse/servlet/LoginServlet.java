package cineverse.servlet;

import cineverse.dao.UserDAO;
import cineverse.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Cookie;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    private static final int COOKIE_MAX_AGE = 30 * 24 * 60 * 60; // 30 days in seconds

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe"); 

        UserDAO userDao = new UserDAO();
        User user = userDao.loginUser(email, password);
        
        if (user != null) {
            
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); 

            
            if (rememberMe != null && rememberMe.equals("on")) {
                // Create cookies
                Cookie emailCookie = new Cookie("userEmail", email);
                Cookie passwordCookie = new Cookie("userPassword", password); 
                Cookie rememberMeCookie = new Cookie("rememberMe", "true");

              
                emailCookie.setMaxAge(COOKIE_MAX_AGE);
                passwordCookie.setMaxAge(COOKIE_MAX_AGE);
                rememberMeCookie.setMaxAge(COOKIE_MAX_AGE);

               
                emailCookie.setPath("/");
                passwordCookie.setPath("/");
                rememberMeCookie.setPath("/");

               
                response.addCookie(emailCookie);
                response.addCookie(passwordCookie);
                response.addCookie(rememberMeCookie);
            } else {
                // Remove existing cookies if "Remember Me" is not checked
                Cookie[] cookies = request.getCookies();
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if (cookie.getName().equals("userEmail") || 
                            cookie.getName().equals("userPassword") || 
                            cookie.getName().equals("rememberMe")) {
                            cookie.setMaxAge(0);
                            cookie.setPath("/");
                            response.addCookie(cookie);
                        }
                    }
                }
            }
            
            // Redirect based on role
            if ("admin".equals(user.getRole())) {
                response.sendRedirect("admin/addMovie.jsp");
            } else {
                response.sendRedirect("index.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?error=login");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            String email = null;
            String password = null;
            String rememberMe = null;

            for (Cookie cookie : cookies) {
                switch (cookie.getName()) {
                    case "userEmail":
                        email = cookie.getValue();
                        break;
                    case "userPassword":
                        password = cookie.getValue();
                        break;
                    case "rememberMe":
                        rememberMe = cookie.getValue();
                        break;
                }
            }

            // If remember me cookies exist, try auto-login
            if (email != null && password != null && rememberMe != null) {
                UserDAO userDao = new UserDAO();
                User user = userDao.loginUser(email, password);
                
                if (user != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("user", user);
                    
                    if ("admin".equals(user.getRole())) {
                        response.sendRedirect("admin/addMovie.jsp");
                        return;
                    } else {
                        response.sendRedirect("index.jsp");
                        return;
                    }
                }
            }
        }
       
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
