package cineverse.dao;

import cineverse.connection.DbConnection;
import cineverse.model.Seat;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class SeatDAO {
     private Connection conn;
      
       public SeatDAO() {
        conn = DbConnection.getConnection();
    }
       
    public List<Seat> getSeatsByShowId(int showId) {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT * FROM seats WHERE show_id = ? ORDER BY seat_number";

        try (
             PreparedStatement pst = conn.prepareStatement(sql)) {
            
            pst.setInt(1, showId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    Seat seat = new Seat();
                    seat.setSeatId(rs.getInt("seat_id"));
                    seat.setShowId(rs.getInt("show_id"));
                    seat.setSeatNumber(rs.getString("seat_number"));
                    seat.setBooked(rs.getInt("is_booked") == 1);
                    seats.add(seat);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seats;
    }
    
      public boolean deleteSeatsForShow(int showId) {
        String sql = "DELETE FROM seats WHERE show_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setInt(1, showId);
            return pst.executeUpdate() >= 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
