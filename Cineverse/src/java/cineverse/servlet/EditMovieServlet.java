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
    private static final String UPLOAD_DIRECTORY = "images";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        
        System.out.println("EditMovieServlet called with action: " + action);
        
        try {
            if ("fetchMovie".equals(action)) {
                handleFetchMovie(request, response);
            } else if ("update".equals(action)) {
                handleUpdateMovie(request, response);
            } else {
                session.setAttribute("messageType", "error");
                session.setAttribute("message", "Invalid action specified!");
                response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("messageType", "error");
            session.setAttribute("message", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
        }
    }

    private void handleUpdateMovie(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        try {
            // Get basic movie information
            int movieId = Integer.parseInt(request.getParameter("movie-id"));
            String movieName = request.getParameter("movie-name");
            String movieLanguage = request.getParameter("movie-language");
            String movieContent = request.getParameter("movie-content");
            String movieTrailerLink = request.getParameter("movie-trailer");
            String movieRating = request.getParameter("movie-rating");
            String movieStatus = request.getParameter("movie-status");
            double adultTicketPrice = Double.parseDouble(request.getParameter("adult-ticket-price"));
            double childTicketPrice = Double.parseDouble(request.getParameter("child-ticket-price"));

            // Handle image
            String imagePath = null;
            Part filePart = request.getPart("movie-image");
            
            if (filePart != null && filePart.getSize() > 0) {
                // New image uploaded
                String fileName = getSubmittedFileName(filePart);
                if (fileName != null && !fileName.isEmpty()) {
                    imagePath = processImageUpload(filePart, request);
                }
            } else {
                // No new image, keep existing image path
                imagePath = request.getParameter("current-image");
                if (imagePath != null && imagePath.startsWith("../")) {
                    imagePath = imagePath.substring(3); // Remove "../" prefix
                }
            }

            // Create movie object
            Movie movie = new Movie(
                movieId, movieName, movieLanguage, movieContent,
                movieTrailerLink, imagePath, movieRating, movieStatus,
                adultTicketPrice, childTicketPrice
            );

            // Update movie in database
            MovieDAO movieDAO = new MovieDAO();
            boolean isUpdated = movieDAO.updateMovie(movie);

            if (isUpdated) {
                session.setAttribute("messageType", "success");
                session.setAttribute("message", "Movie updated successfully!");
            } else {
                session.setAttribute("messageType", "error");
                session.setAttribute("message", "Failed to update movie!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("messageType", "error");
            session.setAttribute("message", "Error updating movie: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
    }

    private String processImageUpload(Part filePart, HttpServletRequest request) throws IOException {
        String fileName = getSubmittedFileName(filePart);
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIRECTORY;
        
        // Create directory if it doesn't exist
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Save file
        String filePath = uploadPath + File.separator + fileName;
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
        }

        // Return relative path for database
        return UPLOAD_DIRECTORY + "/" + fileName;
    }

    private String getSubmittedFileName(Part part) {
        if (part == null) return null;
        
        String header = part.getHeader("content-disposition");
        if (header == null) return null;
        
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim()
                           .replace("\"", "");
            }
        }
        return null;
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
                session.setAttribute("messageType", "error");
                session.setAttribute("message", "Movie not found!");
                response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("messageType", "error");
            session.setAttribute("message", "Error fetching movie: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
        }
    }
}
