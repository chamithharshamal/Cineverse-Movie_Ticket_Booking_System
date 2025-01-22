package cineverse.dao;

import cineverse.connection.DbConnection;
import cineverse.model.Movie;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MovieDAO {
    private Connection connection;

    public MovieDAO() {
        connection = DbConnection.getConnection();
    }

    // Add new movie
public boolean addMovie(Movie movie) {
    String query = "INSERT INTO movies (movie_id, movie_name, language, content, " +
                  "trailer_link, image_path, rating, status, " +
                  "adult_ticket_price, child_ticket_price) " +
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    try (PreparedStatement pst = connection.prepareStatement(query)) {
        pst.setInt(1, movie.getMovieId());
        pst.setString(2, movie.getMovieName());
        pst.setString(3, movie.getLanguage());
        pst.setString(4, movie.getContent());
        pst.setString(5, movie.getTrailerLink());
        pst.setString(6, movie.getImagePath());
        pst.setString(7, movie.getRating());
        pst.setString(8, movie.getStatus());
        pst.setDouble(9, movie.getAdultTicketPrice());
        pst.setDouble(10, movie.getChildTicketPrice());

        return pst.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}


    // Get all movies
   public List<Movie> getAllMovies() {
    List<Movie> movies = new ArrayList<>();
    String query = "SELECT * FROM movies ORDER BY created_at DESC";
    
    try (Statement st = connection.createStatement();
         ResultSet rs = st.executeQuery(query)) {
        
        while (rs.next()) {
            Movie movie = new Movie();
            movie.setMovieId(rs.getInt("movie_id"));
            movie.setMovieName(rs.getString("movie_name"));
            movie.setLanguage(rs.getString("language"));
            movie.setContent(rs.getString("content"));
            movie.setTrailerLink(rs.getString("trailer_link"));
            movie.setImagePath(rs.getString("image_path"));  // Match column name
            movie.setRating(rs.getString("rating"));
            movie.setStatus(rs.getString("status"));
            movie.setAdultTicketPrice(rs.getDouble("adult_ticket_price"));
            movie.setChildTicketPrice(rs.getDouble("child_ticket_price"));
            movies.add(movie);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return movies;
}


    // Get movie by ID
    public Movie getMovieById(int movieId) {
        String query = "SELECT * FROM movies WHERE movie_id = ?";
        
        try (PreparedStatement pst = connection.prepareStatement(query)) {
            pst.setInt(1, movieId);
            ResultSet rs = pst.executeQuery();
            
            if (rs.next()) {
                Movie movie = new Movie();
                movie.setMovieId(rs.getInt("movie_id"));
                movie.setMovieName(rs.getString("movie_name"));
                movie.setLanguage(rs.getString("language"));
                movie.setContent(rs.getString("content"));
                movie.setTrailerLink(rs.getString("trailer_link"));
               movie.setImagePath(rs.getString("image_path"));
                movie.setRating(rs.getString("rating"));
                movie.setStatus(rs.getString("status"));
                movie.setAdultTicketPrice(rs.getDouble("adult_ticket_price"));
                movie.setChildTicketPrice(rs.getDouble("child_ticket_price"));
                return movie;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Update movie
   public boolean updateMovie(Movie movie) {
    String query = "UPDATE movies SET movie_name=?, language=?, content=?, "
            + "trailer_link=?, image_path=?, rating=?, status=?, "
            + "adult_ticket_price=?, child_ticket_price=? WHERE movie_id=?";
    
    try (PreparedStatement pst = connection.prepareStatement(query)) {
        // Debug print
        System.out.println("Executing update for movie ID: " + movie.getMovieId());
        
        pst.setString(1, movie.getMovieName());
        pst.setString(2, movie.getLanguage());
        pst.setString(3, movie.getContent());
        pst.setString(4, movie.getTrailerLink());
        pst.setString(5, movie.getImagePath());
        pst.setString(6, movie.getRating());
        pst.setString(7, movie.getStatus());
        pst.setDouble(8, movie.getAdultTicketPrice());
        pst.setDouble(9, movie.getChildTicketPrice());
        pst.setInt(10, movie.getMovieId());

        // Debug print
        System.out.println("Executing query: " + query);
        
        int rowsAffected = pst.executeUpdate();
        System.out.println("Rows affected: " + rowsAffected);
        
        return rowsAffected > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        System.out.println("SQL Error: " + e.getMessage());
        return false;
    }
}


    // Delete movie
    public boolean deleteMovie(int movieId) {
        String query = "DELETE FROM movies WHERE movie_id = ?";
        
        try (PreparedStatement pst = connection.prepareStatement(query)) {
            pst.setInt(1, movieId);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get movies by status
    public List<Movie> getMoviesByStatus(String status) {
        List<Movie> movies = new ArrayList<>();
        String query = "SELECT * FROM movies WHERE status = ? ORDER BY created_at DESC";
        
        try (PreparedStatement pst = connection.prepareStatement(query)) {
            pst.setString(1, status);
            ResultSet rs = pst.executeQuery();
            
            while (rs.next()) {
                Movie movie = new Movie();
                movie.setMovieId(rs.getInt("movie_id"));
                movie.setMovieName(rs.getString("movie_name"));
                movie.setLanguage(rs.getString("language"));
                movie.setContent(rs.getString("content"));
                movie.setTrailerLink(rs.getString("trailer_link"));
               movie.setImagePath(rs.getString("image_path"));
                movie.setRating(rs.getString("rating"));
                movie.setStatus(rs.getString("status"));
                movie.setAdultTicketPrice(rs.getDouble("adult_ticket_price"));
                movie.setChildTicketPrice(rs.getDouble("child_ticket_price"));
                movies.add(movie);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movies;
    }

    // Search movies by name
    public List<Movie> searchMovies(String searchTerm) {
        List<Movie> movies = new ArrayList<>();
        String query = "SELECT * FROM movies WHERE movie_name LIKE ? ORDER BY created_at DESC";
        
        try (PreparedStatement pst = connection.prepareStatement(query)) {
            pst.setString(1, "%" + searchTerm + "%");
            ResultSet rs = pst.executeQuery();
            
            while (rs.next()) {
                Movie movie = new Movie();
                movie.setMovieId(rs.getInt("movie_id"));
                movie.setMovieName(rs.getString("movie_name"));
                movie.setLanguage(rs.getString("language"));
                movie.setContent(rs.getString("content"));
                movie.setTrailerLink(rs.getString("trailer_link"));
               movie.setImagePath(rs.getString("image_path"));
                movie.setRating(rs.getString("rating"));
                movie.setStatus(rs.getString("status"));
                movie.setAdultTicketPrice(rs.getDouble("adult_ticket_price"));
                movie.setChildTicketPrice(rs.getDouble("child_ticket_price"));
                movies.add(movie);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movies;
    }

    // Check if movie exists
    public boolean movieExists(int movieId) {
        String query = "SELECT COUNT(*) FROM movies WHERE movie_id = ?";
        
        try (PreparedStatement pst = connection.prepareStatement(query)) {
            pst.setInt(1, movieId);
            ResultSet rs = pst.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Close database connection
    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
