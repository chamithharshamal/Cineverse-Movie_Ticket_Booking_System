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
            String relativeImagePath = "../images/" + fileName;

           
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            
            String absoluteImagePath = uploadPath + File.separator + fileName;
            try (InputStream fileContent = filePart.getInputStream()) {
                Files.copy(fileContent, Paths.get(absoluteImagePath), StandardCopyOption.REPLACE_EXISTING);
            }

            // Create movie object
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
                request.setAttribute("message", "Movie added successfully!");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Failed to add movie. Please try again.");
                request.setAttribute("messageType", "error");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid input. Please check your data.");
            request.setAttribute("messageType", "error");
            e.printStackTrace();
        } catch (IOException e) {
            request.setAttribute("message", "Error uploading image. Please try again.");
            request.setAttribute("messageType", "error");
            e.printStackTrace();
        } catch (Exception e) {
            request.setAttribute("message", "An unexpected error occurred.");
            request.setAttribute("messageType", "error");
            e.printStackTrace();
        }

        request.getRequestDispatcher("/admin/addMovie.jsp").forward(request, response);
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
