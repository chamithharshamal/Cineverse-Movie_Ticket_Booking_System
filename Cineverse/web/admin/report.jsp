<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="cineverse.connection.DbConnection" %>

<!DOCTYPE html>
<html>
<head>
    <title>Booking Reports - Admin Dashboard</title>
    <style>
        .dashboard {
            padding: 20px;
            font-family: Arial, sans-serif;
        }
        .card {
            background: white;
            padding: 20px;
            margin: 10px 0;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f5f5f5;
        }
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .summary-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
        }
        .number {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
        }
        
        /* Add to your existing style section */
.chart-container {
    height: 300px;
    margin: 20px 0;
}

.percentage-bar {
    height: 20px;
    background: #e9ecef;
    border-radius: 10px;
    overflow: hidden;
}

.percentage-bar-fill {
    height: 100%;
    background: #007bff;
    transition: width 0.3s ease;
}

.grid-2 {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
}

@media (max-width: 768px) {
    .grid-2 {
        grid-template-columns: 1fr;
    }
}

    </style>
</head>
<body>
    <div class="dashboard">
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DbConnection.getConnection();

                if(conn != null) {
                    // 1. Today's Summary
                    String todaySummarySQL = 
                        "SELECT COUNT(*) as total_bookings, " +
                        "SUM(total_amount) as total_revenue, " +
                        "SUM(adult_count) as adult_tickets, " +
                        "SUM(child_count) as child_tickets " +
                        "FROM bookings " +
                        "WHERE DATE(booking_date) = CURDATE()";

                    pstmt = conn.prepareStatement(todaySummarySQL);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
        %>
                        <div class="card">
                            <h2>Today's Summary</h2>
                            <div class="summary-grid">
                                <div class="summary-item">
                                    <div class="number"><%= rs.getInt("total_bookings") %></div>
                                    <div>Total Bookings</div>
                                </div>
                                <div class="summary-item">
                                    <div class="number">Rs. <%= String.format("%.2f", rs.getDouble("total_revenue")) %></div>
                                    <div>Revenue</div>
                                </div>
                                <div class="summary-item">
                                    <div class="number"><%= rs.getInt("adult_tickets") %></div>
                                    <div>Adult Tickets</div>
                                </div>
                                <div class="summary-item">
                                    <div class="number"><%= rs.getInt("child_tickets") %></div>
                                    <div>Child Tickets</div>
                                </div>
                            </div>
                        </div>
        <%
                    }
                    
                    // Close previous resources
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();

                    // 2. Recent Bookings
                    String recentBookingsSQL = 
                        "SELECT b.booking_id, b.user_email, m.movie_name, " +
                        "b.selected_seats, b.total_amount, b.booking_date " +
                        "FROM bookings b " +
                        "JOIN movies m ON b.movie_id = m.movie_id " +
                        "ORDER BY b.booking_date DESC LIMIT 10";

                    pstmt = conn.prepareStatement(recentBookingsSQL);
                    rs = pstmt.executeQuery();
        %>
                    <div class="card">
                        <h2>Recent Bookings</h2>
                        <table>
                            <tr>
                                <th>Booking ID</th>
                                <th>User Email</th>
                                <th>Movie</th>
                                <th>Seats</th>
                                <th>Amount</th>
                                <th>Date</th>
                            </tr>
                            <% while (rs.next()) { %>
                                <tr>
                                    <td><%= rs.getInt("booking_id") %></td>
                                    <td><%= rs.getString("user_email") %></td>
                                    <td><%= rs.getString("movie_name") %></td>
                                    <td><%= rs.getString("selected_seats") %></td>
                                    <td>Rs. <%= String.format("%.2f", rs.getDouble("total_amount")) %></td>
                                    <td><%= new SimpleDateFormat("dd-MM-yyyy HH:mm").format(rs.getTimestamp("booking_date")) %></td>
                                </tr>
                            <% } %>
                        </table>
                    </div>
        <%
                    // Close previous resources
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();

                    // 3. Popular Movies
                    String popularMoviesSQL = 
                        "SELECT m.movie_name, COUNT(b.booking_id) as booking_count, " +
                        "SUM(b.total_amount) as total_revenue " +
                        "FROM bookings b " +
                        "JOIN movies m ON b.movie_id = m.movie_id " +
                        "GROUP BY m.movie_id, m.movie_name " +
                        "ORDER BY booking_count DESC LIMIT 5";

                    pstmt = conn.prepareStatement(popularMoviesSQL);
                    rs = pstmt.executeQuery();
        %>
        
                    <div class="card">
                        <h2>Popular Movies</h2>
                        <table>
                            <tr>
                                <th>Movie</th>
                                <th>Total Bookings</th>
                                <th>Revenue</th>
                            </tr>
                            <% while (rs.next()) { %>
                                <tr>
                                    <td><%= rs.getString("movie_name") %></td>
                                    <td><%= rs.getInt("booking_count") %></td>
                                    <td>Rs. <%= String.format("%.2f", rs.getDouble("total_revenue")) %></td>
                                </tr>
                            <% } %>
                        </table>
                    </div>
                        <!-- Add these sections after your existing reports -->

<%
    // 5. Revenue by Day of Week
    String dowSQL = 
        "SELECT DAYNAME(booking_date) as day_name, " +
        "COUNT(*) as booking_count, " +
        "SUM(total_amount) as total_revenue " +
        "FROM bookings " +
        "WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
        "GROUP BY DAYNAME(booking_date) " +
        "ORDER BY FIELD(DAYNAME(booking_date), 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')";

    pstmt = conn.prepareStatement(dowSQL);
    rs = pstmt.executeQuery();
%>
<div class="card">
    <h2>Revenue by Day of Week (Last 30 Days)</h2>
    <table>
        <tr>
            <th>Day</th>
            <th>Bookings</th>
            <th>Revenue</th>
            <th>Average per Booking</th>
        </tr>
        <% while (rs.next()) { 
            double revenue = rs.getDouble("total_revenue");
            int bookings = rs.getInt("booking_count");
            double average = bookings > 0 ? revenue / bookings : 0;
        %>
            <tr>
                <td><%= rs.getString("day_name") %></td>
                <td><%= bookings %></td>
                <td>Rs. <%= String.format("%.2f", revenue) %></td>
                <td>Rs. <%= String.format("%.2f", average) %></td>
            </tr>
        <% } %>
    </table>
</div>

<%
    // Close previous resources
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();

    // 6. Hall Performance Report
    String hallSQL = 
        "SELECT h.hall_name, " +
        "COUNT(DISTINCT b.booking_id) as total_bookings, " +
        "SUM(b.total_amount) as revenue, " +
        "COUNT(DISTINCT s.show_id) as total_shows " +
        "FROM halls h " +
        "LEFT JOIN shows s ON h.hall_id = s.hall_id " +
        "LEFT JOIN bookings b ON s.show_id = b.show_id " +
        "GROUP BY h.hall_id, h.hall_name";

    pstmt = conn.prepareStatement(hallSQL);
    rs = pstmt.executeQuery();
%>
<div class="card">
    <h2>Hall Performance Report</h2>
    <table>
        <tr>
            <th>Hall Name</th>
            <th>Total Shows</th>
            <th>Total Bookings</th>
            <th>Revenue</th>
        </tr>
        <% while (rs.next()) { %>
            <tr>
                <td><%= rs.getString("hall_name") %></td>
                <td><%= rs.getInt("total_shows") %></td>
                <td><%= rs.getInt("total_bookings") %></td>
                <td>Rs. <%= String.format("%.2f", rs.getDouble("revenue")) %></td>
            </tr>
        <% } %>
    </table>
</div>

<%
    // Close previous resources
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();

    // 7. Ticket Type Distribution
    String ticketSQL = 
        "SELECT " +
        "SUM(adult_count) as total_adult, " +
        "SUM(child_count) as total_child, " +
        "SUM(total_amount) as total_revenue " +
        "FROM bookings " +
        "WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)";

    pstmt = conn.prepareStatement(ticketSQL);
    rs = pstmt.executeQuery();
    
    if (rs.next()) {
        int totalAdult = rs.getInt("total_adult");
        int totalChild = rs.getInt("total_child");
        int totalTickets = totalAdult + totalChild;
        double totalRevenue = rs.getDouble("total_revenue");
%>
<div class="card">
    <h2>Ticket Distribution (Last 30 Days)</h2>
    <div class="summary-grid">
        <div class="summary-item">
            <div class="number"><%= totalAdult %></div>
            <div>Adult Tickets (<%= String.format("%.1f%%", (totalAdult * 100.0 / totalTickets)) %>)</div>
        </div>
        <div class="summary-item">
            <div class="number"><%= totalChild %></div>
            <div>Child Tickets (<%= String.format("%.1f%%", (totalChild * 100.0 / totalTickets)) %>)</div>
        </div>
        <div class="summary-item">
            <div class="number"><%= totalTickets %></div>
            <div>Total Tickets</div>
        </div>
        <div class="summary-item">
            <div class="number">Rs. <%= String.format("%.2f", totalRevenue/totalTickets) %></div>
            <div>Average Ticket Price</div>
        </div>
    </div>
</div>
<%
    }

    // Close previous resources
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();

    // 8. Top Customers
    String customerSQL = 
        "SELECT user_email, " +
        "COUNT(*) as booking_count, " +
        "SUM(total_amount) as total_spent, " +
        "MAX(booking_date) as last_booking " +
        "FROM bookings " +
        "GROUP BY user_email " +
        "ORDER BY total_spent DESC " +
        "LIMIT 10";

    pstmt = conn.prepareStatement(customerSQL);
    rs = pstmt.executeQuery();
%>
<div class="card">
    <h2>Top Customers</h2>
    <table>
        <tr>
            <th>Email</th>
            <th>Total Bookings</th>
            <th>Total Spent</th>
            <th>Last Booking</th>
        </tr>
        <% while (rs.next()) { %>
            <tr>
                <td><%= rs.getString("user_email") %></td>
                <td><%= rs.getInt("booking_count") %></td>
                <td>Rs. <%= String.format("%.2f", rs.getDouble("total_spent")) %></td>
                <td><%= new SimpleDateFormat("dd-MM-yyyy").format(rs.getTimestamp("last_booking")) %></td>
            </tr>
        <% } %>
    </table>
</div>
        <%
                }
            } catch (Exception e) {
                out.println("<div class='card'><h2>Error</h2><p>Database error: " + e.getMessage() + "</p></div>");
                e.printStackTrace();
            } finally {
                // Close all resources in finally block
                if (rs != null) {
                    try { rs.close(); } catch (SQLException e) { }
                }
                if (pstmt != null) {
                    try { pstmt.close(); } catch (SQLException e) { }
                }
                if (conn != null) {
                    try { conn.close(); } catch (SQLException e) { }
                }
            }
        %>
    </div>
    
</body>
</html>
