<%@page import="cineverse.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Panel - Sidebar</title>
        <link href="https://fonts.googleapis.com/css2?family=Sharp+Sans:wght@300;400;600&display=swap" rel="stylesheet">
        <link href="../css/sidePanel.css" rel="stylesheet">
    </head>
    <body>

        <div class="sidebar">
            <!-- Sidebar Header -->
            <div class="sidebar-header">
                <img src="../images/logo.png" alt="Cineverse Logo" class="sidebar-logo">
            </div>

            <!-- Sidebar Navigation -->
            <nav class="sidebar-nav">
                <ul>
                    <li><a href="../index.jsp">Website</a></li>
                    <li><a href="addMovie.jsp">Movies</a></li>
                    <li><a href="addShow.jsp">Shows</a></li>
                    <li><a href="manageUser.jsp">User</a></li>
                    <li><a href="#">Payment</a></li>
                    <li><a href="#">Feedback</a></li>
                    <li><a href="#">Report</a></li>
                </ul>
            </nav>
            <form action="${pageContext.request.contextPath}/logout" method="get" class="logout-form">
                <button type="submit" class="logout-btn">Log Out</button>
            </form>

        </div>

    </body>
</html>