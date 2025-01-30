/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cineverse.servlet;

import cineverse.dao.MovieDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/DeleteMovieServlet")
public class DeleteMovieServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            MovieDAO movieDAO = new MovieDAO();
            boolean isDeleted = movieDAO.deleteMovie(movieId);

            if (isDeleted) {
                session.setAttribute("message", "Movie and all related shows and seats deleted successfully!");
            } else {
                session.setAttribute("message", "Failed to delete movie and its related data!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
    }
}
