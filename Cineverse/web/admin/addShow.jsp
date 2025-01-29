<%@page import="cineverse.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%
    HttpSession userSession = request.getSession(false);
    User user = (User) userSession.getAttribute("user");
    if (!"admin".equals(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shows Management</title>
    <link href="../css/addShow.css" rel="stylesheet">
</head>
<body>
    <%
        String message = (String) session.getAttribute("message");
        String messageType = (String) session.getAttribute("messageType");
        if (message != null) {
            session.removeAttribute("message");
            session.removeAttribute("messageType");
    %>
    <div class="message <%= messageType %>">
        <%= message %>
    </div>
    <%
        }
    %>

    <div class="container">
        <div class="left">
            <jsp:include page="sidePanel.jsp" />
        </div>
        <div class="right">
            <header>
                <h1>Shows Management</h1>
            </header>
            <form id="movie-form" action="insertShowServlet" method="post" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="movieId">Movie ID:</label>
                    <input type="number" id="movieId" name="movieId" required />
                </div>

                <div class="form-group">
                    <label for="hallNo">Hall No:</label>
                    <select id="hallNo" name="hallId" required>
                        <option value="">Select Hall</option>
                        <option value="1">Marquee Hall</option>
                        <option value="2">Premiere Lounge</option>
                        <option value="3">Stardust Auditorium</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Time Slots:</label>
                    <div class="timeslot">
                        <div>
                            <input type="checkbox" id="time1" name="showTime" value="10.00 AM">
                            <label for="time1">10:00 AM</label>
                        </div>
                        <div>
                            <input type="checkbox" id="time2" name="showTime" value="12.30 PM">
                            <label for="time2">12:30 PM</label>
                        </div>
                        <div>
                            <input type="checkbox" id="time3" name="showTime" value="3.30 PM">
                            <label for="time3">3:30 PM</label>
                        </div>
                        <div>
                            <input type="checkbox" id="time4" name="showTime" value="6.00 PM">
                            <label for="time4">6:00 PM</label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="startDate">Start Date:</label>
                    <input type="date" id="startDate" name="startDate" required 
                           min="<%= java.time.LocalDate.now() %>">
                </div>

                <div class="form-group">
                    <label for="endDate">End Date:</label>
                    <input type="date" id="endDate" name="endDate" required 
                           min="<%= java.time.LocalDate.now() %>">
                </div>

                <div class="form-actions">
                    <button type="submit">Save</button>
                    <button type="reset">Reset</button>
                </div>
            </form>
        </div>
    </div>
 <!-- Footer -->
        <footer>
            <p>&copy; 2024 Movie Management System. All rights reserved.</p>
        </footer>
    <script>
        function validateForm() {
            // Get form elements
            const movieId = document.getElementById('movieId').value;
            const hallNo = document.getElementById('hallNo').value;
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;
            const timeSlots = document.querySelectorAll('input[name="showTime"]:checked');

            // Basic validation
            if (!movieId || !hallNo || !startDate || !endDate) {
                showMessage('Please fill in all required fields', 'error');
                return false;
            }

            // Validate time slots
            if (timeSlots.length === 0) {
                showMessage('Please select at least one time slot', 'error');
                return false;
            }

            // Date validation
            const startDateTime = new Date(startDate);
            const endDateTime = new Date(endDate);
            const today = new Date();
            today.setHours(0, 0, 0, 0);

            if (startDateTime < today) {
                showMessage('Start date cannot be in the past', 'error');
                return false;
            }

            if (endDateTime < startDateTime) {
                showMessage('End date must be after or equal to start date', 'error');
                return false;
            }

            return true;
        }

        function showMessage(message, type) {
            // Create message element if it doesn't exist
            let messageDiv = document.querySelector('.message');
            if (!messageDiv) {
                messageDiv = document.createElement('div');
                messageDiv.className = 'message';
                document.body.insertBefore(messageDiv, document.body.firstChild);
            }

            // Set message content and style
            messageDiv.textContent = message;
            messageDiv.className = 'message ' + type;
            messageDiv.style.display = 'block';

            // Hide message after 3 seconds
            setTimeout(() => {
                messageDiv.style.display = 'none';
            }, 3000);
        }

        // Set minimum date for date inputs
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('startDate').min = today;
            document.getElementById('endDate').min = today;
        });
    </script>
</body>
</html>
