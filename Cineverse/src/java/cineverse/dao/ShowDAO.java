package cineverse.dao;

import cineverse.model.Show;
import cineverse.connection.DbConnection;
import java.sql.*;
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
        String sql = "INSERT INTO shows (movie_id, hall_id, show_time, start_date, end_date) VALUES (?, ?, ?, ?, ?)";
        try {
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setInt(1, show.getMovieId());
            pst.setInt(2, show.getHallId());
            pst.setString(3, show.getShowTime());
            pst.setDate(4, show.getStartDate());
            pst.setDate(5, show.getEndDate());
            
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<LocalDate, List<Show>> getAvailableShowsByMovie(int movieId) {
    Map<LocalDate, List<Show>> showsByDate = new TreeMap<>(); // TreeMap for sorted dates
    LocalDate today = LocalDate.now();
    
    String sql = "SELECT s.show_id, s.movie_id, s.hall_id, h.hall_name, " +
                 "s.show_time, s.start_date, s.status, s.created_at " +
                 "FROM shows s " +
                 "JOIN halls h ON s.hall_id = h.hall_id " +
                 "WHERE s.movie_id = ? AND s.status = 'active' " +
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
            show.setStatus(rs.getString("status"));
            show.setHallName(rs.getString("hall_name"));
            
            LocalDate showDate = rs.getDate("start_date").toLocalDate();
            showsByDate.computeIfAbsent(showDate, k -> new ArrayList<>()).add(show);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return showsByDate;
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
    // Add other necessary methods
}
