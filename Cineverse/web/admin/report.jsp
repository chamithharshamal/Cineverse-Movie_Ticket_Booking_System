<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="cineverse.connection.DbConnection" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Dashboard Analytics</title>
        <link href="../css/report.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>
    <body>
        <div class="container">
            <div class="left">
                <jsp:include page="sidePanel.jsp" />
            </div>

            <div class="right">
                <div class="section-title">Dashboard Analytics</div>

                <div class="stats-grid">
                    <%
                        int totalBookings = 0;
                        double totalRevenue = 0.0;
                        int adultTickets = 0;
                        int childTickets = 0;

                        try {
                            Connection conn = DbConnection.getConnection();
                            String sql = "SELECT COUNT(*) as bookings, SUM(total_amount) as revenue, "
                                    + "SUM(adult_count) as adult, SUM(child_count) as child FROM bookings";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            ResultSet rs = pstmt.executeQuery();

                            if (rs.next()) {
                                totalBookings = rs.getInt("bookings");
                                totalRevenue = rs.getDouble("revenue");
                                adultTickets = rs.getInt("adult");
                                childTickets = rs.getInt("child");
                            }
                            rs.close();
                            pstmt.close();
                            conn.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>

                    <div class="stat-card">
                        <div class="stat-label">Total Bookings</div>
                        <div class="stat-number"><%= totalBookings%></div> 
                    </div>
                    <div class="stat-card">
                         <div class="stat-label">Total Revenue</div>
                        <div class="stat-number">Rs. <%= String.format("%.2f", totalRevenue)%></div>
                    </div>
                    <div class="stat-card">
                         <div class="stat-label">Adult Tickets</div>
                        <div class="stat-number"><%= adultTickets%></div>
                    </div>
                    <div class="stat-card">
                          <div class="stat-label">Child Tickets</div>
                        <div class="stat-number"><%= childTickets%></div>
                    </div>
                </div>

                <div class="chart-container">
                    <canvas id="revenueByDayChart"></canvas>
                </div>

                <div class="chart-container">
                    <canvas id="ticketDistributionChart"></canvas>
                </div>

                <div class="chart-container">
                    <canvas id="hallPerformanceChart"></canvas>
                </div>

                <div class="chart-container">
                    <canvas id="monthlyRevenueChart"></canvas>
                </div>
                <!-- Recent Bookings Table -->
                <div class="table-container">
                    <div class="section-title">Recent Bookings</div>
                    <table>
                        <thead>
                            <tr>
                                <th>Booking ID</th>
                                <th>User Email</th>
                                <th>Movie</th>
                                <th>Amount</th>
                                <th>Seats</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection conn = DbConnection.getConnection();
                                    String recentBookingsSQL
                                            = "SELECT b.booking_id, b.user_email, m.movie_name, "
                                            + "b.total_amount, b.selected_seats, b.booking_date "
                                            + "FROM bookings b "
                                            + "JOIN movies m ON b.movie_id = m.movie_id "
                                            + "ORDER BY b.booking_date DESC LIMIT 5";

                                    PreparedStatement pstmt = conn.prepareStatement(recentBookingsSQL);
                                    ResultSet rs = pstmt.executeQuery();

                                    SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");

                                    while (rs.next()) {
                            %>
                            <tr>
                                <td><%= rs.getInt("booking_id")%></td>
                                <td><%= rs.getString("user_email")%></td>
                                <td><%= rs.getString("movie_name")%></td>
                                <td>Rs. <%= String.format("%.2f", rs.getDouble("total_amount"))%></td>
                                <td><%= rs.getString("selected_seats")%></td>
                                <td><%= dateFormat.format(rs.getTimestamp("booking_date"))%></td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    pstmt.close();
                                    conn.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <!-- Top Performing Movies Table -->
                <div class="table-container">
                    <div class="section-title">Top Performing Movies</div>
                    <table>
                        <thead>
                            <tr>
                                <th>Movie</th>
                                <th>Total Bookings</th>
                                <th>Total Revenue</th>

                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection conn = DbConnection.getConnection();
                                    String topMoviesSQL = "SELECT "
                                            + "m.movie_name, "
                                            + "COUNT(b.booking_id) as booking_count, "
                                            + "SUM(b.total_amount) as total_revenue "
                                            + "FROM movies m "
                                            + "LEFT JOIN bookings b ON m.movie_id = b.movie_id "
                                            + "GROUP BY m.movie_id, m.movie_name "
                                            + "ORDER BY booking_count DESC "
                                            + "LIMIT 5";

                                    PreparedStatement pstmt = conn.prepareStatement(topMoviesSQL);
                                    ResultSet rs = pstmt.executeQuery();

                                    while (rs.next()) {
                            %>
                            <tr>
                                <td><%= rs.getString("movie_name")%></td>
                                <td><%= rs.getInt("booking_count")%></td>
                                <td>Rs. <%= String.format("%.2f", rs.getDouble("total_revenue"))%></td>

                            </tr>
                            <%
                                    }
                                    rs.close();
                                    pstmt.close();
                                    conn.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </tbody>
                    </table>
                </div>

            </div>

            <script>
                <%
                    // Revenue by Day
                    Map<String, Double> revenueByDay = new HashMap<String, Double>();
                    StringBuilder dayLabels = new StringBuilder();
                    StringBuilder dayData = new StringBuilder();

                    try {
                        Connection conn = DbConnection.getConnection();
                        String sql = "SELECT DAYNAME(booking_date) as day_name, SUM(total_amount) as revenue "
                                + "FROM bookings GROUP BY DAYNAME(booking_date) "
                                + "ORDER BY FIELD(DAYNAME(booking_date), 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        ResultSet rs = pstmt.executeQuery();

                        boolean first = true;
                        while (rs.next()) {
                            if (!first) {
                                dayLabels.append(", ");
                                dayData.append(", ");
                            }
                            dayLabels.append("'").append(rs.getString("day_name")).append("'");
                            dayData.append(rs.getDouble("revenue"));
                            first = false;
                        }
                        rs.close();
                        pstmt.close();
                        conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>

        new Chart(document.getElementById('revenueByDayChart'), {
            type: 'bar',
            data: {
                labels: [<%= dayLabels.toString()%>],
                datasets: [{
                        label: 'Revenue by Day',
                        data: [<%= dayData.toString()%>],
                        backgroundColor: 'rgba(184, 139, 74, 0.8)',
                        borderColor: 'rgba(184, 139, 74, 1)',
                        borderWidth: 1
                    }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            color: '#ffffff'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#ffffff'
                        }
                    }
                },
                plugins: {
                    legend: {
                        labels: {
                            color: '#ffffff'
                        }
                    }
                }
            }
        });

        // Ticket Distribution Chart
        new Chart(document.getElementById('ticketDistributionChart'), {
            type: 'pie',
            data: {
                labels: ['Adult Tickets', 'Child Tickets'],
                datasets: [{
                        data: [<%= adultTickets%>, <%= childTickets%>],
                        backgroundColor: [
                            'rgba(184, 139, 74, 0.8)',
                            'rgba(120, 90, 48, 0.8)'
                        ]
                    }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        labels: {
                            color: '#ffffff'
                        }
                    }
                }
            }
        });

                <%
                    // Hall Performance
                    StringBuilder hallLabels = new StringBuilder();
                    StringBuilder hallData = new StringBuilder();

                    try {
                        Connection conn = DbConnection.getConnection();
                        String sql = "SELECT h.hall_name, COUNT(b.booking_id) as booking_count "
                                + "FROM halls h LEFT JOIN shows s ON h.hall_id = s.hall_id "
                                + "LEFT JOIN bookings b ON s.show_id = b.show_id "
                                + "GROUP BY h.hall_id, h.hall_name";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        ResultSet rs = pstmt.executeQuery();

                        boolean first = true;
                        while (rs.next()) {
                            if (!first) {
                                hallLabels.append(", ");
                                hallData.append(", ");
                            }
                            hallLabels.append("'").append(rs.getString("hall_name")).append("'");
                            hallData.append(rs.getInt("booking_count"));
                            first = false;
                        }
                        rs.close();
                        pstmt.close();
                        conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>

        new Chart(document.getElementById('hallPerformanceChart'), {
            type: 'bar',
            data: {
                labels: [<%= hallLabels.toString()%>],
                datasets: [{
                        label: 'Bookings per Hall',
                        data: [<%= hallData.toString()%>],
                        backgroundColor: 'rgba(184, 139, 74, 0.8)',
                        borderColor: 'rgba(184, 139, 74, 1)',
                        borderWidth: 1
                    }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            color: '#ffffff'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#ffffff'
                        }
                    }
                },
                plugins: {
                    legend: {
                        labels: {
                            color: '#ffffff'
                        }
                    }
                }
            }
        });

                <%
                    // Monthly Revenue
                    StringBuilder monthLabels = new StringBuilder();
                    StringBuilder monthData = new StringBuilder();

                    try {
                        Connection conn = DbConnection.getConnection();
                        String sql = "SELECT DATE_FORMAT(booking_date, '%M %Y') as month, SUM(total_amount) as revenue "
                                + "FROM bookings GROUP BY DATE_FORMAT(booking_date, '%Y-%m') "
                                + "ORDER BY booking_date DESC LIMIT 6";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        ResultSet rs = pstmt.executeQuery();

                        boolean first = true;
                        while (rs.next()) {
                            if (!first) {
                                monthLabels.append(", ");
                                monthData.append(", ");
                            }
                            monthLabels.append("'").append(rs.getString("month")).append("'");
                            monthData.append(rs.getDouble("revenue"));
                            first = false;
                        }
                        rs.close();
                        pstmt.close();
                        conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>

        new Chart(document.getElementById('monthlyRevenueChart'), {
            type: 'line',
            data: {
                labels: [<%= monthLabels.toString()%>],
                datasets: [{
                        label: 'Monthly Revenue Trend',
                        data: [<%= monthData.toString()%>],
                        borderColor: 'rgba(184, 139, 74, 1)',
                        backgroundColor: 'rgba(184, 139, 74, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            color: '#ffffff'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#ffffff'
                        }
                    }
                },
                plugins: {
                    legend: {
                        labels: {
                            color: '#ffffff'
                        }
                    }
                }
            }
        });
            </script>

        </div>
        <footer>
            <p>&copy; 2024 Movie Management System. All rights reserved.</p>
        </footer>
    </body>
</html>
