<%@page import="cineverse.connection.DbConnection"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="cineverse.dao.UserDAO" %>
<%@ page import="cineverse.model.User" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
    <head>
        <title>User Management - Admin Dashboard</title>
        <link href="../css/users.css" rel="stylesheet">
    </head>
    <body>
        <div class="container">
            <div class="left">
                <jsp:include page="sidePanel.jsp" />
            </div>

            <div class="right">
                <%
                    String successMessage = (String) session.getAttribute("successMessage");
                    String errorMessage = (String) session.getAttribute("errorMessage");

                    session.removeAttribute("successMessage");
                    session.removeAttribute("errorMessage");
                %>

                <% if (successMessage != null && !successMessage.isEmpty()) {%>
                <div class="alert alert-success" id="successAlert">
                    <%= successMessage%>
                </div>
                <% } %>

                <% if (errorMessage != null && !errorMessage.isEmpty()) {%>
                <div class="alert alert-danger" id="errorAlert">
                    <%= errorMessage%>
                </div>
                <% } %>

                <%
                    UserDAO userDAO = new UserDAO();
                    List<User> allUsers = userDAO.getAllUsers();
                    int totalUsers = userDAO.getTotalUsers();
                %>

                <!-- Statistics Section -->
                <div class="card1">
                    <h2>User Statistics</h2>
                    <div class="stats">
                        <div class="stat-card">
                            <div class="stat-number"><%= totalUsers%></div>
                            <div>Total Users</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">
                                <%
                                    int activeUserCount = 0;
                                    for (User user : allUsers) {
                                        if ("user".equals(user.getRole())) {
                                            activeUserCount++;
                                        }
                                    }
                                %>
                                <%= activeUserCount%>

                            </div>
                            <div>Active Users</div>
                        </div>
                    </div>
                </div>

                <!-- All Users Section -->
                <div class="card">
                    <div class="header">
                        <h2>All Users</h2>
                        <div class="search-bar">
                            <input type="text" id="searchUsers" placeholder="Search users..." onkeyup="searchUsers()">
                        </div>
                    </div>
                    <table id="usersTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User user : allUsers) {%>
                            <tr>
                                <td><%= user.getId()%></td>
                                <td><%= user.getName()%></td>
                                <td><%= user.getEmail()%></td>
                                <td><%= user.getPhoneNumber()%></td>
                                <td><%= user.getRole()%></td>
                                <td class="action-buttons">
                                    <button class="btn btn-edit" onclick="editUser(<%= user.getId()%>)">Edit</button>
                                    <button class="btn btn-delete" onclick="deleteUser(<%= user.getId()%>)">Delete</button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Top Customers Section -->
                <div class="card">
                    <h2>Top Customers</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Total Bookings</th>
                                <th>Total Spent</th>
                                <th>Last Booking</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                PreparedStatement pstmt = null;
                                ResultSet rs = null;

                                try {
                                    conn = DbConnection.getConnection();
                                    String topCustomersSQL
                                            = "SELECT u.name, u.email, "
                                            + "COUNT(b.booking_id) as booking_count, "
                                            + "SUM(b.total_amount) as total_spent, "
                                            + "MAX(b.booking_date) as last_booking "
                                            + "FROM users u "
                                            + "JOIN bookings b ON u.email = b.user_email "
                                            + "GROUP BY u.email, u.name "
                                            + "ORDER BY total_spent DESC "
                                            + "LIMIT 10";

                                    pstmt = conn.prepareStatement(topCustomersSQL);
                                    rs = pstmt.executeQuery();

                                    while (rs.next()) {
                            %>
                            <tr>
                                <td><%= rs.getString("name")%></td>
                                <td><%= rs.getString("email")%></td>
                                <td><%= rs.getInt("booking_count")%></td>
                                <td>Rs. <%= String.format("%.2f", rs.getDouble("total_spent"))%></td>
                                <td><%= rs.getTimestamp("last_booking")%></td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if (rs != null) {
                                        try {
                                            rs.close();
                                        } catch (SQLException e) {
                                        }
                                    }
                                    if (pstmt != null) {
                                        try {
                                            pstmt.close();
                                        } catch (SQLException e) {
                                        }
                                    }
                                    if (conn != null) {
                                        try {
                                            conn.close();
                                        } catch (SQLException e) {
                                        }
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- Add this form at the bottom of your users.jsp -->
            <form id="deleteUserForm" action="DeleteUserServlet" method="POST" style="display: none;">
                <input type="hidden" id="userIdToDelete" name="userId">
            </form>

            <script>
                function deleteUser(userId) {
                    if (confirm("Are you sure you want to delete this user?")) {
                        document.getElementById("userIdToDelete").value = userId;
                        document.getElementById("deleteUserForm").submit();
                    }
                }
            </script>

            <script>
                function searchUsers() {
                    var input = document.getElementById("searchUsers");
                    var filter = input.value.toUpperCase();
                    var table = document.getElementById("usersTable");
                    var tr = table.getElementsByTagName("tr");

                    for (var i = 1; i < tr.length; i++) {
                        var td = tr[i].getElementsByTagName("td");
                        var found = false;
                        for (var j = 0; j < td.length; j++) {
                            var cell = td[j];
                            if (cell) {
                                var textValue = cell.textContent || cell.innerText;
                                if (textValue.toUpperCase().indexOf(filter) > -1) {
                                    found = true;
                                    break;
                                }
                            }
                        }
                        tr[i].style.display = found ? "" : "none";
                    }
                }

                function editUser(userId) {
                    //Yet to be Implement edit user functionality
                    window.location.href = "editUser.jsp?id=" + userId;
                }

                function deleteUser(userId) {
                    if (confirm("Are you sure you want to delete this user?")) {
                        //Yet to be Implement delete functionality using AJAX or form submission
                        window.location.href = "deleteUser?id=" + userId;
                    }
                }
                document.addEventListener('DOMContentLoaded', function () {
                    // Auto-hide alerts after 5 seconds
                    var alerts = document.querySelectorAll('.alert');
                    alerts.forEach(function (alert) {
                        setTimeout(function () {
                            alert.style.display = 'none';
                        }, 5000);
                    });
                });
            </script>
    </body>
</html>
