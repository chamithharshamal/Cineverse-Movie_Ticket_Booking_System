package cineverse.dao;

import cineverse.connection.DbConnection;
import cineverse.model.Show;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class ShowDAO {
    
    public boolean addShow(Show show) {
        String sql = "INSERT INTO shows (movie_id, hall_id, show_time, start_date, end_date, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
                    
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            
            pst.setInt(1, show.getMovieId());
            pst.setInt(2, show.getHallId());
            pst.setString(3, show.getShowTime());
            pst.setDate(4, show.getStartDate());
            pst.setDate(5, show.getEndDate());
            pst.setString(6, show.getStatus());
            
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Show getShowById(int showId) {
        String sql = "SELECT s.*, h.hall_name FROM shows s " +
                    "JOIN halls h ON s.hall_id = h.hall_id " +
                    "WHERE s.show_id = ?";
        Show show = null;

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            
            pst.setInt(1, showId);
            System.out.println("Debug: Executing query for show_id: " + showId);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    show = new Show();
                    show.setShowId(rs.getInt("show_id"));
                    show.setMovieId(rs.getInt("movie_id"));
                    show.setHallId(rs.getInt("hall_id"));
                    show.setShowTime(rs.getString("show_time"));
                    show.setStartDate(rs.getDate("start_date"));
                    show.setEndDate(rs.getDate("end_date"));
                    show.setStatus(rs.getString("status"));
                    show.setHallName(rs.getString("hall_name"));

                    System.out.println("Debug: Show found - ID: " + show.getShowId() + 
                                     ", Movie ID: " + show.getMovieId());
                } else {
                    System.out.println("Debug: No show found with ID: " + showId);
                }
            }
        } catch (SQLException e) {
            System.out.println("Debug: SQL Exception: " + e.getMessage());
            e.printStackTrace();
        }
        return show;
    }

    public Map<LocalDate, List<Show>> getAvailableShowsByMovie(int movieId) {
        Map<LocalDate, List<Show>> showsByDate = new TreeMap<>();
        String sql = "SELECT s.*, h.hall_name FROM shows s " +
                    "JOIN halls h ON s.hall_id = h.hall_id " +
                    "WHERE s.movie_id = ? AND s.status = 'active' " +
                    "AND s.start_date >= ? " +
                    "ORDER BY s.start_date, s.show_time";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            
            pst.setInt(1, movieId);
            pst.setDate(2, Date.valueOf(LocalDate.now()));
            
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    Show show = new Show();
                    show.setShowId(rs.getInt("show_id"));
                    show.setMovieId(rs.getInt("movie_id"));
                    show.setHallId(rs.getInt("hall_id"));
                    show.setShowTime(rs.getString("show_time"));
                    show.setStartDate(rs.getDate("start_date"));
                    show.setEndDate(rs.getDate("end_date"));
                    show.setStatus(rs.getString("status"));
                    show.setHallName(rs.getString("hall_name"));

                    LocalDate showDate = rs.getDate("start_date").toLocalDate();
                    showsByDate.computeIfAbsent(showDate, k -> new ArrayList<>()).add(show);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return showsByDate;
    }

    public boolean checkShowExists(int showId) {
        String sql = "SELECT COUNT(*) FROM shows WHERE show_id = ?";
        
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            
            pst.setInt(1, showId);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public void printAllShows() {
        String sql = "SELECT s.*, h.hall_name FROM shows s " +
                    "JOIN halls h ON s.hall_id = h.hall_id";
                    
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            System.out.println("\nDebug: All Shows in Database:");
            System.out.println("----------------------------------------");
            while (rs.next()) {
                System.out.printf("Show ID: %d, Movie ID: %d, Hall: %s, Time: %s, Date: %s\n",
                    rs.getInt("show_id"),
                    rs.getInt("movie_id"),
                    rs.getString("hall_name"),
                    rs.getString("show_time"),
                    rs.getDate("start_date")
                );
            }
            System.out.println("----------------------------------------\n");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Add method to update show status
    public boolean updateShowStatus(int showId, String status) {
        String sql = "UPDATE shows SET status = ? WHERE show_id = ?";
        
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            
            pst.setString(1, status);
            pst.setInt(2, showId);
            
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
