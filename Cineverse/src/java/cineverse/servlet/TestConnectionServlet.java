package cineverse.servlet;

import cineverse.connection.DbConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

@WebServlet("/test-connection")
public class TestConnectionServlet extends HttpServlet {

    @Override
    protected void doGet(javax.servlet.http.HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        Connection connection = DbConnection.getConnection();

        if (connection != null) {
            response.getWriter().println("<script>alert('Database connection established successfully!');</script>");
        } else {
            response.getWriter().println("<script>alert('Failed to establish database connection!');</script>");
        }
    }
}
