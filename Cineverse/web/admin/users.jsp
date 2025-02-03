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
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .dashboard {
            max-width: 1200px;
            margin: 0 auto;
        }
        .card {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
        }
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 10px;
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
            background-color: #f8f9fa;
            font-weight: bold;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 6px 12px;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-edit {
            background-color: #ffc107;
            color: #000;
        }
        .btn-delete {
            background-color: #dc3545;
            color: #fff;
        }
        .search-bar {
            margin-bottom: 20px;
        }
        .search-bar input {
            padding: 8px;
            width: 300px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .alert {
    padding: 15px;
    margin-bottom: 20px;
    border: 1px solid transparent;
    border-radius: 4px;
    animation: fadeOut 5s forwards;
}

.alert-success {
    color: #155724;
    background-color: #d4edda;
    border-color: #c3e6cb;
}

.alert-danger {
    color: #721c24;
    background-color: #f8d7da;
    border-color: #f5c6cb;
}

@keyframes fadeOut {
    0% { opacity: 1; }
    70% { opacity: 1; }
    100% { opacity: 0; }
}

    </style>
</head>
<body>
    <div class="dashboard">
        <!-- Add this right after the <div class="dashboard"> -->
<% 
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    
    // Clear messages after displaying
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<% if (successMessage != null && !successMessage.isEmpty()) { %>
    <div class="alert alert-success" id="successAlert">
        <%= successMessage %>
    </div>
<% } %>

<% if (errorMessage != null && !errorMessage.isEmpty()) { %>
    <div class="alert alert-danger" id="errorAlert">
        <%= errorMessage %>
    </div>
<% } %>

        <%
            UserDAO userDAO = new UserDAO();
            List<User> allUsers = userDAO.getAllUsers();
            int totalUsers = userDAO.getTotalUsers();
        %>
        
        <!-- Statistics Section -->
        <div class="card">
            <h2>User Statistics</h2>
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-number"><%= totalUsers %></div>
                    <div>Total Users</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">
                      <%
    int activeUserCount = 0;
    for(User user : allUsers) {
        if("user".equals(user.getRole())) {
            activeUserCount++;
        }
    }
%>
<%= activeUserCount %>

                    </div>
                    <div>Active Users</div>
                </div>
                <!-- Add more statistics as needed -->
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
                    <% for(User user : allUsers) { %>
                        <tr>
                            <td><%= user.getId() %></td>
                            <td><%= user.getName() %></td>
                            <td><%= user.getEmail() %></td>
                            <td><%= user.getPhoneNumber() %></td>
                            <td><%= user.getRole() %></td>
                            <td class="action-buttons">
                                <button class="btn btn-edit" onclick="editUser(<%= user.getId() %>)">Edit</button>
                                <button class="btn btn-delete" onclick="deleteUser(<%= user.getId() %>)">Delete</button>
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
                            String topCustomersSQL = 
                                "SELECT u.name, u.email, " +
                                "COUNT(b.booking_id) as booking_count, " +
                                "SUM(b.total_amount) as total_spent, " +
                                "MAX(b.booking_date) as last_booking " +
                                "FROM users u " +
                                "JOIN bookings b ON u.email = b.user_email " +
                                "GROUP BY u.email, u.name " +
                                "ORDER BY total_spent DESC " +
                                "LIMIT 10";
                            
                            pstmt = conn.prepareStatement(topCustomersSQL);
                            rs = pstmt.executeQuery();
                            
                            while(rs.next()) {
                    %>
                                <tr>
                                    <td><%= rs.getString("name") %></td>
                                    <td><%= rs.getString("email") %></td>
                                    <td><%= rs.getInt("booking_count") %></td>
                                    <td>Rs. <%= String.format("%.2f", rs.getDouble("total_spent")) %></td>
                                    <td><%= rs.getTimestamp("last_booking") %></td>
                                </tr>
                    <%
                            }
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            if(rs != null) try { rs.close(); } catch(SQLException e) { }
                            if(pstmt != null) try { pstmt.close(); } catch(SQLException e) { }
                            if(conn != null) try { conn.close(); } catch(SQLException e) { }
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
    if(confirm("Are you sure you want to delete this user?")) {
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
            // Implement edit user functionality
            // You can redirect to an edit page or show a modal
            window.location.href = "editUser.jsp?id=" + userId;
        }

        function deleteUser(userId) {
            if(confirm("Are you sure you want to delete this user?")) {
                // Implement delete functionality using AJAX or form submission
                window.location.href = "deleteUser?id=" + userId;
            }
        }
        document.addEventListener('DOMContentLoaded', function() {
    // Auto-hide alerts after 5 seconds
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            alert.style.display = 'none';
        }, 5000);
    });
});
    </script>
</body>
</html>
