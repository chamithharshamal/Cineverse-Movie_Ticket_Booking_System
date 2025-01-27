package cineverse.dao;

import cineverse.model.Show;
import cineverse.connection.DbConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;


public class ShowDAO {
    private Connection conn;

    public ShowDAO() {
        conn = DbConnection.getConnection();
    }

    public boolean addShow(Show show) {
        String sql = "INSERT INTO shows (movie_id, hall_id, show_time, start_date, end_date, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        try {
            PreparedStatement pst = conn.prepareStatement(sql);
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

    public List<Show> getAllShows() {
        List<Show> shows = new ArrayList<>();
        String sql = "SELECT s.*, h.hall_name FROM shows s " +
                    "JOIN halls h ON s.hall_id = h.hall_id " +
                    "WHERE s.status = 'active' ORDER BY s.start_date, s.show_time";
        
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            
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
                shows.add(show);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return shows;
    }
public Map<LocalDate, List<Show>> getAvailableShowsByMovie(int movieId) {
    Map<LocalDate, List<Show>> showsByDate = new TreeMap<>(); // TreeMap to maintain date order
    LocalDate today = LocalDate.now();
    
    String sql = "SELECT s.*, h.hall_name " +
                 "FROM shows s " +
                 "JOIN halls h ON s.hall_id = h.hall_id " +
                 "WHERE s.movie_id = ? " +
                 "AND s.status = 'active' " +
                 "AND s.start_date >= ? " +
                 "ORDER BY s.start_date, s.show_time";
    
    try {
        PreparedStatement pst = conn.prepareStatement(sql);
        pst.setInt(1, movieId);
        pst.setDate(2, Date.valueOf(today));
        
        ResultSet rs = pst.executeQuery();
        
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
            
            // Convert sql.Date to LocalDate for mapping
            LocalDate showDate = rs.getDate("start_date").toLocalDate();
            
            // Add show to the appropriate date list
            if (!showsByDate.containsKey(showDate)) {
                showsByDate.put(showDate, new ArrayList<>());
            }
            showsByDate.get(showDate).add(show);
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return showsByDate;
}

public Show getShowById(int showId) {
    String sql = "SELECT s.*, h.hall_name, m.title as movie_title " +
                 "FROM shows s " +
                 "JOIN halls h ON s.hall_id = h.hall_id " +
                 "JOIN movies m ON s.movie_id = m.movie_id " +
                 "WHERE s.show_id = ?";
    
    try {
        PreparedStatement pst = conn.prepareStatement(sql);
        pst.setInt(1, showId);
        ResultSet rs = pst.executeQuery();
        
        if (rs.next()) {
            Show show = new Show();
            show.setShowId(rs.getInt("show_id"));
            show.setMovieId(rs.getInt("movie_id"));
            show.setHallId(rs.getInt("hall_id"));
            show.setShowTime(rs.getString("show_time"));
            show.setStartDate(rs.getDate("start_date"));
            show.setEndDate(rs.getDate("end_date"));
            show.setStatus(rs.getString("status"));
            show.setHallName(rs.getString("hall_name"));
            // You'll need to add this field to Show class
            
            return show;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return null;
}

    public void close() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
