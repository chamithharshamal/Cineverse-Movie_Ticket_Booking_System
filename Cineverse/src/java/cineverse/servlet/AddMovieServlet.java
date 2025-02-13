package cineverse.servlet;

import cineverse.dao.MovieDAO;
import cineverse.model.Movie;
import java.io.*;
import java.nio.file.*;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin/AddMovieServlet") 
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,    // 1MB
    maxFileSize = 1024 * 1024 * 10,     // 10MB
    maxRequestSize = 1024 * 1024 * 15    // 15MB
)
public class AddMovieServlet extends HttpServlet {
    // Configuration constants
    private static final String UPLOAD_DIRECTORY = "../images";
    private static final String FALLBACK_UPLOAD_PATH = System.getProperty("user.home") + File.separator + "cineverse_uploads";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String uploadedFilePath = null;
        
        try {
            // Extract form data
            int movieId = Integer.parseInt(request.getParameter("movie-id"));
            String movieName = request.getParameter("movie-name");
            String movieLanguage = request.getParameter("movie-language");
            String movieContent = request.getParameter("movie-content");
            String movieTrailerLink = request.getParameter("movie-trailer");
            String movieRating = request.getParameter("movie-rating");
            String movieStatus = request.getParameter("movie-status");
            double adultTicketPrice = Double.parseDouble(request.getParameter("adult-ticket-price"));
            double childTicketPrice = Double.parseDouble(request.getParameter("child-ticket-price"));

            // Handle file upload
            Part filePart = request.getPart("movie-image");
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            // Validate file type
            if (!isValidImageFile(originalFileName)) {
                throw new ServletException("Invalid file type! Please upload an image file.");
            }

            // Generate unique filename
            String fileName = generateUniqueFileName(originalFileName);

            // Get upload path using multiple fallback options
            String uploadPath = determineUploadPath(request);
            String relativeImagePath = UPLOAD_DIRECTORY + "/" + fileName;
            
            // Create upload directory if it doesn't exist
            Files.createDirectories(Paths.get(uploadPath));

            // Save the file
            uploadedFilePath = uploadPath + File.separator + fileName;
            saveFile(filePart, uploadedFilePath);

            // Create and save movie object
            Movie movie = new Movie(
                movieId, movieName, movieLanguage, movieContent,
                movieTrailerLink, relativeImagePath, movieRating,
                movieStatus, adultTicketPrice, childTicketPrice
            );

            // Save to database
            MovieDAO movieDAO = new MovieDAO();
            if (movieDAO.addMovie(movie)) {
                session.setAttribute("messageType", "success");
                session.setAttribute("message", "Movie added successfully!");
            } else {
                throw new ServletException("Failed to add movie to database");
            }

        } catch (Exception e) {
            // Clean up uploaded file if something went wrong
            if (uploadedFilePath != null) {
                try {
                    Files.deleteIfExists(Paths.get(uploadedFilePath));
                } catch (IOException ignore) {}
            }
            
            session.setAttribute("messageType", "error");
            session.setAttribute("message", "Error: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
    }

    private String determineUploadPath(HttpServletRequest request) throws IOException {
        // Try multiple locations
        String[] possiblePaths = {
            // 1. Context-relative path
            getServletContext().getRealPath("") + UPLOAD_DIRECTORY,
            
            // 2. Custom environment variable if set
            System.getenv("CINEVERSE_UPLOAD_PATH"),
            
            // 3. Project-specific directory in user's home
            FALLBACK_UPLOAD_PATH,
            
            // 4. Temporary directory
            System.getProperty("java.io.tmpdir") + File.separator + "cineverse_uploads"
        };

        for (String path : possiblePaths) {
            if (path != null && !path.trim().isEmpty()) {
                try {
                    Path dirPath = Paths.get(path);
                    if (!Files.exists(dirPath)) {
                        Files.createDirectories(dirPath);
                    }
                    if (Files.isWritable(dirPath)) {
                        return path;
                    }
                } catch (IOException e) {
                    continue; // Try next path if this one fails
                }
            }
        }

        throw new IOException("No writable upload directory available");
    }

    private void saveFile(Part filePart, String targetPath) throws IOException {
        
        Path temp = Files.createTempFile("upload_", ".tmp");
        try {
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, temp, StandardCopyOption.REPLACE_EXISTING);
            }
            Files.move(temp, Paths.get(targetPath), StandardCopyOption.ATOMIC_MOVE);
        } finally {
            Files.deleteIfExists(temp);
        }
    }

    // Existing helper methods remain the same
    private boolean isValidImageFile(String fileName) {
        String[] allowedExtensions = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".avif"};
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
        return System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/addMovie.jsp");
    }
}
