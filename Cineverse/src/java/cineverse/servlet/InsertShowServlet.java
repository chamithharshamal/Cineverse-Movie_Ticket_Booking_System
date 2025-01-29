package cineverse.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import cineverse.connection.DbConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@WebServlet("/admin/insertShowServlet")
public class InsertShowServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction

            // Get form parameters
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int hallId = Integer.parseInt(request.getParameter("hallId"));
            String[] showTimes = request.getParameterValues("showTime");
            
            // Validate show times
            if (showTimes == null || showTimes.length == 0) {
                session.setAttribute("messageType", "error");
                session.setAttribute("message", "Please select at least one show time");
                response.sendRedirect(request.getContextPath() + "/admin/addShow.jsp");
                return;
            }

            Date startDate = Date.valueOf(request.getParameter("startDate"));
            Date endDate = Date.valueOf(request.getParameter("endDate"));
            
            // Calculate days between
            LocalDate start = startDate.toLocalDate();
            LocalDate end = endDate.toLocalDate();
            long daysBetween = ChronoUnit.DAYS.between(start, end) + 1;

            try {
                String showSql = "INSERT INTO show_schedule (movie_id, hall_id, show_date, show_time, end_date, status) VALUES (?, ?, ?, ?, ?, 'active')";
                
                try (PreparedStatement pstmt = conn.prepareStatement(showSql, Statement.RETURN_GENERATED_KEYS)) {
                    // Create shows for each day and time slot
                    for (int i = 0; i < daysBetween; i++) {
                        LocalDate currentDate = start.plusDays(i);
                        Date showDate = Date.valueOf(currentDate);
                        
                        for (String showTime : showTimes) {
                            pstmt.setInt(1, movieId);
                            pstmt.setInt(2, hallId);
                            pstmt.setDate(3, showDate);
                            pstmt.setString(4, showTime);
                            pstmt.setDate(5, endDate);
                            pstmt.executeUpdate();

                            // Get the generated show_id and create seats
                            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                                if (generatedKeys.next()) {
                                    int showId = generatedKeys.getInt(1);
                                    insertSeats(conn, showId);
                                }
                            }
                        }
                    }
                }

                conn.commit();
                session.setAttribute("messageType", "success");
                session.setAttribute("message", "Shows added successfully!");

            } catch (SQLException e) {
                conn.rollback();
                session.setAttribute("messageType", "error");
                session.setAttribute("message", "Error adding shows: " + e.getMessage());
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("messageType", "error");
            session.setAttribute("message", "System error: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/addShow.jsp");
    }

    private void insertSeats(Connection conn, int showId) throws SQLException {
        String seatSql = "INSERT INTO seats (show_id, seat_number, is_booked) VALUES (?, ?, 0)";
        try (PreparedStatement seatStmt = conn.prepareStatement(seatSql)) {
            // Create seats for each show (A1 to A21)
            for (int i = 1; i <= 21; i++) {
                seatStmt.setInt(1, showId);
                seatStmt.setString(2, "A" + i);
                seatStmt.addBatch();
            }
            seatStmt.executeBatch();
        }
    }
}
