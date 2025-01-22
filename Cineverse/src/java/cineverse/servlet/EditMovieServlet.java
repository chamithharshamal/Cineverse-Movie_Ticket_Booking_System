/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cineverse.servlet;

import cineverse.dao.MovieDAO;
import cineverse.model.Movie;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/admin/EditMovieServlet")
@MultipartConfig
public class EditMovieServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        
        System.out.println("Action received: " + action); // Debug line
        
        if ("fetchMovie".equals(action)) {
            handleFetchMovie(request, response);
        } else if ("update".equals(action)) {
            handleUpdateMovie(request, response);
        } else {
            session.setAttribute("message", "Invalid action specified!");
            response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
        }
    }
    
    private void handleFetchMovie(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        try {
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            MovieDAO movieDAO = new MovieDAO();
            Movie movie = movieDAO.getMovieById(movieId);
            
            if (movie != null) {
                request.setAttribute("movieToEdit", movie);
                request.getRequestDispatcher("/admin/addMovie.jsp").forward(request, response);
            } else {
                session.setAttribute("message", "Movie not found!");
                response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
        }
    }
    
    private void handleUpdateMovie(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        try {
            // Get all form parameters
            int movieId = Integer.parseInt(request.getParameter("movie-id"));
            String movieName = request.getParameter("movie-name");
            String movieLanguage = request.getParameter("movie-language");
            String movieContent = request.getParameter("movie-content");
            String movieTrailerLink = request.getParameter("movie-trailer");
            String movieRating = request.getParameter("movie-rating");
            String movieStatus = request.getParameter("movie-status");
            double adultTicketPrice = Double.parseDouble(request.getParameter("adult-ticket-price"));
            double childTicketPrice = Double.parseDouble(request.getParameter("child-ticket-price"));

            // Debug printing
            System.out.println("Updating movie with ID: " + movieId);
            System.out.println("Movie Name: " + movieName);

            // Handle image update
            Part filePart = request.getPart("movie-image");
            String imagePath;
            
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String uploadPath = "C:\\Users\\Dell\\Documents\\GitHub\\Cineverse-Movie_Ticket_Booking_System\\Cineverse\\web\\images";
                imagePath = "../images/" + fileName;

                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String absoluteImagePath = uploadPath + File.separator + fileName;
                try (InputStream fileContent = filePart.getInputStream()) {
                    Files.copy(fileContent, Paths.get(absoluteImagePath), StandardCopyOption.REPLACE_EXISTING);
                }
            } else {
                imagePath = request.getParameter("current-image");
            }

            Movie movie = new Movie(
                movieId, movieName, movieLanguage, movieContent,
                movieTrailerLink, imagePath, movieRating, movieStatus,
                adultTicketPrice, childTicketPrice
            );

            MovieDAO movieDAO = new MovieDAO();
            boolean isUpdated = movieDAO.updateMovie(movie);

            if (isUpdated) {
                session.setAttribute("message", "Movie updated successfully!");
            } else {
                session.setAttribute("message", "Failed to update movie!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error updating movie: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
    }
}
