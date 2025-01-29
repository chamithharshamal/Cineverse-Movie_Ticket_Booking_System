package cineverse.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import cineverse.connection.DbConnection;
import cineverse.model.Show;
import java.sql.*;
import java.time.LocalDate;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/insertShowServlet")
public class InsertShowServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession();
        
        try {
            // Retrieve form data
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int hallId = Integer.parseInt(request.getParameter("hallId"));
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));
            String[] showTimes = request.getParameterValues("showTime");

            if (showTimes == null || showTimes.length == 0) {
                session.setAttribute("message", "Please select at least one show time");
                session.setAttribute("messageType", "error");
                response.sendRedirect("addShow.jsp");
                return;
            }

            try (Connection conn = DbConnection.getConnection()) {
                conn.setAutoCommit(false);

                try {
                    String showSql = "INSERT INTO shows (movie_id, hall_id, show_time, start_date, end_date, status) " +
                                   "VALUES (?, ?, ?, ?, ?, 'active')";
                    
                    try (PreparedStatement pstmt = conn.prepareStatement(showSql, Statement.RETURN_GENERATED_KEYS)) {
                        LocalDate currentDate = startDate;
                        
                        while (!currentDate.isAfter(endDate)) {
                            for (String showTime : showTimes) {
                                pstmt.setInt(1, movieId);
                                pstmt.setInt(2, hallId);
                                pstmt.setString(3, showTime);
                                pstmt.setDate(4, java.sql.Date.valueOf(currentDate));
                                pstmt.setDate(5, java.sql.Date.valueOf(endDate));
                                pstmt.executeUpdate();

                                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                                if (generatedKeys.next()) {
                                    int showId = generatedKeys.getInt(1);
                                    insertSeats(conn, showId);
                                }
                            }
                            currentDate = currentDate.plusDays(1);
                        }
                    }

                    conn.commit();
                    session.setAttribute("message", "Shows and seats added successfully!");
                    session.setAttribute("messageType", "success");

                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }

            } catch (SQLException e) {
                e.printStackTrace();
                session.setAttribute("message", "Error: " + e.getMessage());
                session.setAttribute("messageType", "error");
            }

        } catch (Exception e) {
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect("addShow.jsp");
    }

    private void insertSeats(Connection conn, int showId) throws SQLException {
        String seatSql = "INSERT INTO seats (show_id, seat_number, is_booked) VALUES (?, ?, 0)";
        try (PreparedStatement seatStmt = conn.prepareStatement(seatSql)) {
            char[] rows = {'A', 'B', 'C', 'D'};
            for (char row : rows) {
                for (int i = 1; i <= 10; i++) {
                    seatStmt.setInt(1, showId);
                    seatStmt.setString(2, row + String.valueOf(i));
                    seatStmt.addBatch();
                }
            }
            seatStmt.executeBatch();
        }
    }
}
