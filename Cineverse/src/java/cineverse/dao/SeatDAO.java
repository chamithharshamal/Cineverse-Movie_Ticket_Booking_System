package cineverse.dao;

import cineverse.connection.DbConnection;
import cineverse.model.Seat;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatDAO {
    private Connection conn;

    public SeatDAO() {
        conn = DbConnection.getConnection();
    }

    // Get all seats for a specific show
    public List<Seat> getSeatsByShowId(int showId) {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT * FROM seats WHERE show_id = ?";
        
        try {
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setInt(1, showId);
            ResultSet rs = pst.executeQuery();
            
            while (rs.next()) {
                Seat seat = new Seat();
                seat.setSeatId(rs.getInt("seat_id"));
                seat.setSeatNumber(rs.getString("seat_number"));
                seat.setIsBooked(rs.getBoolean("is_booked"));
                // Set show object if needed
                seats.add(seat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seats;
    }

    // Create seats for a new show
    public boolean createSeatsForShow(int showId) {
        String sql = "INSERT INTO seats (show_id, seat_number, is_booked) VALUES (?, ?, ?)";
        boolean success = true;
        
        try {
            conn.setAutoCommit(false);
            PreparedStatement pst = conn.prepareStatement(sql);
            
            // Create 40 seats (A1-D10)
            char[] rows = {'A', 'B', 'C', 'D'};
            for (char row : rows) {
                for (int i = 1; i <= 10; i++) {
                    pst.setInt(1, showId);
                    pst.setString(2, row + String.valueOf(i));
                    pst.setBoolean(3, false);
                    pst.addBatch();
                }
            }
            
            pst.executeBatch();
            conn.commit();
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            success = false;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return success;
    }

    // Book selected seats
    public boolean bookSeats(int showId, List<String> seatNumbers) {
        String sql = "UPDATE seats SET is_booked = true WHERE show_id = ? AND seat_number = ? AND is_booked = false";
        boolean success = true;
        
        try {
            conn.setAutoCommit(false);
            PreparedStatement pst = conn.prepareStatement(sql);
            
            for (String seatNumber : seatNumbers) {
                pst.setInt(1, showId);
                pst.setString(2, seatNumber);
                pst.addBatch();
            }
            
            int[] results = pst.executeBatch();
            for (int result : results) {
                if (result != 1) {
                    throw new SQLException("Seat booking failed");
                }
            }
            conn.commit();
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            success = false;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return success;
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
