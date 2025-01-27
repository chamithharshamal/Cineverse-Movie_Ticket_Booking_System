package cineverse.servlet;

import cineverse.dao.MovieDAO;
import cineverse.model.Movie;
import java.io.*;
import java.nio.file.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/admin/AddMovieServlet") 
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,    
    maxFileSize = 1024 * 1024 * 10,     
    maxRequestSize = 1024 * 1024 * 15   
)
public class AddMovieServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            int movieId = Integer.parseInt(request.getParameter("movie-id"));
            String movieName = request.getParameter("movie-name");
            String movieLanguage = request.getParameter("movie-language");
            String movieContent = request.getParameter("movie-content");
            String movieTrailerLink = request.getParameter("movie-trailer");
            String movieRating = request.getParameter("movie-rating");
            String movieStatus = request.getParameter("movie-status");
            double adultTicketPrice = Double.parseDouble(request.getParameter("adult-ticket-price"));
            double childTicketPrice = Double.parseDouble(request.getParameter("child-ticket-price"));

            Part filePart = request.getPart("movie-image");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            String uploadPath = "C:\\Users\\Dell\\Documents\\GitHub\\Cineverse-Movie_Ticket_Booking_System\\Cineverse\\web\\images";
            String relativeImagePath = "images/" + fileName;

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String absoluteImagePath = uploadPath + File.separator + fileName;
            try (InputStream fileContent = filePart.getInputStream()) {
                Files.copy(fileContent, Paths.get(absoluteImagePath), StandardCopyOption.REPLACE_EXISTING);
            }

            Movie movie = new Movie(
                movieId,
                movieName,
                movieLanguage,
                movieContent,
                movieTrailerLink,
                relativeImagePath,
                movieRating,
                movieStatus,
                adultTicketPrice,
                childTicketPrice
            );

            MovieDAO movieDAO = new MovieDAO();
            boolean isAdded = movieDAO.addMovie(movie);

           if (isAdded) {
    session.setAttribute("messageType", "success");
    session.setAttribute("message", "Movie added successfully!");
} else {
    session.setAttribute("messageType", "error");
    session.setAttribute("message", "Failed to add movie!");
}

        } catch (Exception e) {
            session.setAttribute("message", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
    }

    private boolean isValidImageFile(String fileName) {
        String[] allowedExtensions = {".jpg", ".jpeg", ".png", ".gif", ".webp"};
        String fileExtension = fileName.toLowerCase();
        for (String extension : allowedExtensions) {
            if (fileExtension.endsWith(extension)) {
                return true;
            }
        }
        return false;
    }

    private String generateUniqueFileName(String originalFileName) {
        String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        return System.currentTimeMillis() + extension;
    }
}
