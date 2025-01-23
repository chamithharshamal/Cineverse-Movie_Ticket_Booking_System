<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shows Management</title>
    <link href="../css/addShow.css" rel="stylesheet">
</head>
<body>
       <div class="container">
            <div class="left">
                <jsp:include page="../admin/sidePanel.jsp" />
            </div>
<div class="right">
                <header>
                    <h1>Shows Management</h1>
                </header>
                <form id="movie-form" class="movie-form" action="insertShowServlet" method="post">
                    <label for="movie-id">Movie ID:</label>
                    <input
                        type="text"
                        id="movieId"
                        name="movieId"
                        required
                        /><br /><br />

                    <label for="hallNo">Hall No:</label>
                    <select id="hallNo" name="hallId">
                        <option value=""></option>
                        <option value="1">Marquee Hall</option>
                        <option value="2">Premiere Lounge</option>
                         <option value="3">Stardust Auditorium</option>
                    </select>

                    <label>Time Slots:</label>
                    <div class="timeslot">
                    <div>
                        <input type="checkbox" id="time1" name="showTime" value="10.00 AM">
                        <label for="time1">10.00 AM</label>
                    </div>
                    <div>
                        <input type="checkbox" id="time2" name="showTime" value="12.30 PM">
                        <label for="time2">12.30 PM</label>
                    </div>
                    <div>
                        <input type="checkbox" id="time3" name="showTime" value="3.30 PM">
                        <label for="time3">3.30 PM</label>
                    </div>
                         <div>
                        <input type="checkbox" id="time4" name="showTime" value="6.00 PM">
                        <label for="time3">6.00 PM</label>
                    </div>
                    </div>
                    <br /> <br />
                    <label for="startDate">Start Date:</label>
                    <input type="date" id="startDate" name="startDate"> <br /> <br />

                    <label for="endDate">End Date:</label>
                    <input type="date" id="endDate" name="endDate"> 
                    <br /> <br />
                    <button type="submit">Save</button>
                    <button type="button">Cancel</button>
                </form>
            </div>
        </div>
        <!-- Footer -->
        <footer>
            <p>&copy; 2024 Movie Management System. All rights reserved.</p>
        </footer>

</body>
</html>
