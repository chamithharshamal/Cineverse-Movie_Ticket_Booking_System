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

    public List<Seat> getSeatsByIds(String[] seatIds) {
        List<Seat> seats = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT * FROM seats WHERE seat_id IN (");

        for (int i = 0; i < seatIds.length; i++) {
            sql.append(i == 0 ? "?" : ", ?");
        }
        sql.append(")");

        try (PreparedStatement pst = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < seatIds.length; i++) {
                pst.setInt(i + 1, Integer.parseInt(seatIds[i]));
            }

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

    public boolean areSeatsAvailable(int showId, String[] seatNumbers) {
        String sql = "SELECT COUNT(*) FROM seats WHERE show_id = ? AND seat_number = ? AND is_booked = 0";

        try (PreparedStatement pst = conn.prepareStatement(sql)) {
            for (String seatNumber : seatNumbers) {
                pst.setInt(1, showId);
                pst.setString(2, seatNumber);
                ResultSet rs = pst.executeQuery();
                if (rs.next() && rs.getInt(1) == 0) {
                    return false;
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

}
