package cineverse.dao;

import cineverse.model.Show;
import cineverse.connection.DbConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

    public List<Show> getShowsByMovie(int movieId) {
        List<Show> shows = new ArrayList<>();
        String sql = "SELECT s.*, h.hall_name FROM shows s JOIN halls h ON s.hall_id = h.hall_id WHERE s.movie_id = ? AND s.status = 'active'";
        
        try {
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setInt(1, movieId);
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
                shows.add(show);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return shows;
    }

    // Add other necessary methods
}
