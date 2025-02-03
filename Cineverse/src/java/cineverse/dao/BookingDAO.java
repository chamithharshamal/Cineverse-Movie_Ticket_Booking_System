package cineverse.dao;

import cineverse.model.Booking;
import cineverse.connection.DbConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    private Connection connection;

    public BookingDAO() {
        connection = DbConnection.getConnection();
    }

    public int createBooking(Booking booking) {
        String sql = "INSERT INTO bookings (user_email, movie_id, show_id, selected_seats, "
                + "hall_name, adult_count, child_count, total_amount, payment_status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, booking.getUserEmail());
            stmt.setInt(2, booking.getMovieId());
            stmt.setInt(3, booking.getShowId());
            stmt.setString(4, booking.getSelectedSeats());
            stmt.setString(5, booking.getHallName());
            stmt.setInt(6, booking.getAdultCount());
            stmt.setInt(7, booking.getChildCount());
            stmt.setDouble(8, booking.getTotalAmount());
            stmt.setString(9, "COMPLETED");

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating booking failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating booking failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }

    public Booking getBookingById(int bookingId) {
        String sql = "SELECT * FROM bookings WHERE booking_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, bookingId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractBookingFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Booking> getBookingsByUserEmail(String userEmail) {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE user_email = ? ORDER BY booking_date DESC";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, userEmail);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    private Booking extractBookingFromResultSet(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setBookingId(rs.getInt("booking_id"));
        booking.setUserEmail(rs.getString("user_email"));
        booking.setMovieId(rs.getInt("movie_id"));
        booking.setShowId(rs.getInt("show_id"));
        booking.setSelectedSeats(rs.getString("selected_seats"));
        booking.setHallName(rs.getString("hall_name"));
        booking.setAdultCount(rs.getInt("adult_count"));
        booking.setChildCount(rs.getInt("child_count"));
        booking.setTotalAmount(rs.getDouble("total_amount"));
        booking.setBookingDate(rs.getTimestamp("booking_date"));
        booking.setPaymentStatus(rs.getString("payment_status"));
        return booking;
    }

    public boolean updateSeatsStatus(int showId, String[] seatNumbers) {
        String updateSql = "UPDATE seats SET is_booked = 1 WHERE show_id = ? AND seat_number = ? AND is_booked = 0";
        String checkSql = "SELECT COUNT(*) FROM seats WHERE show_id = ? AND seat_number = ? AND is_booked = 0";

        try {

            connection.setAutoCommit(false);

            try (PreparedStatement checkStmt = connection.prepareStatement(checkSql)) {
                for (String seatNumber : seatNumbers) {
                    checkStmt.setInt(1, showId);
                    checkStmt.setString(2, seatNumber);
                    ResultSet rs = checkStmt.executeQuery();
                    rs.next();
                    if (rs.getInt(1) == 0) {
                        // If any seat is not available, rollback and return false
                        connection.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement updateStmt = connection.prepareStatement(updateSql)) {
                for (String seatNumber : seatNumbers) {
                    updateStmt.setInt(1, showId);
                    updateStmt.setString(2, seatNumber);
                    updateStmt.addBatch();
                }

                int[] results = updateStmt.executeBatch();

                // Verify all updates were successful
                boolean allSuccessful = true;
                for (int result : results) {
                    if (result != 1) {
                        allSuccessful = false;
                        break;
                    }
                }

                if (allSuccessful) {
                    connection.commit();
                    return true;
                } else {
                    connection.rollback();
                    return false;
                }
            }
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

}
