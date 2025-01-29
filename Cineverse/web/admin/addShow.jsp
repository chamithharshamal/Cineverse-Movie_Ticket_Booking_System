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
        <style>
            #messageContainer {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 1000;
    width: auto;
}

.message {
    padding: 15px 30px;
    border-radius: 5px;
    margin-bottom: 10px;
    animation: fadeIn 0.3s ease-in;
    transition: opacity 0.3s ease-out;
}

.success {
    background-color: #4CAF50;
    color: white;
}

.error {
    background-color: #f44336;
    color: white;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
}

/* Add this to ensure messages are visible over other content */
.message {
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    font-weight: bold;
}

            </style>
    </head>
    <body>
         <div id="messageContainer">
        <%
            String message = (String) session.getAttribute("message");
            String messageType = (String) session.getAttribute("messageType");
            if (message != null) {
                System.out.println("Message found: " + message); // Debug line
        %>
                <div class="message <%= messageType %>" id="messageDiv">
                    <%= message %>
                </div>
        <%
                session.removeAttribute("message");
                session.removeAttribute("messageType");
            }
        %>
    </div>

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
                               min="<%= java.time.LocalDate.now()%>">
                    </div>

                    <div class="form-group">
                        <label for="endDate">End Date:</label>
                        <input type="date" id="endDate" name="endDate" required 
                               min="<%= java.time.LocalDate.now()%>">
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
            const messageContainer = document.getElementById('messageContainer');
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${type}`;
            messageDiv.textContent = message;
            messageContainer.appendChild(messageDiv);

            // Auto-hide after 3 seconds
            setTimeout(() => {
                messageDiv.remove();
            }, 3000);
        }

        // Check for message on page load
        document.addEventListener('DOMContentLoaded', function() {
            const messageDiv = document.getElementById('messageDiv');
            if (messageDiv) {
                setTimeout(() => {
                    messageDiv.style.opacity = '0';
                    setTimeout(() => {
                        messageDiv.remove();
                    }, 300);
                }, 3000);
            }
        });
        </script>
    </body>
</html>
