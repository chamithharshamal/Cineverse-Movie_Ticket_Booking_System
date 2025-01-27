<%@page import="java.time.LocalTime"%>
<%@page import="java.nio.file.Paths"%>
<%@page import="java.nio.file.Files"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.Map"%>
<%@page import="java.time.LocalDate"%>
<%@page import="cineverse.model.Show"%>
<%@page import="java.util.List"%>
<%@page import="cineverse.dao.ShowDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Movie Details - Cineverse</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/css/booking.css" rel="stylesheet">
        <style>
            <%= new String(Files.readAllBytes(Paths.get(application.getRealPath("/css/booking.css"))))%>
        </style>

    </head>
    <body>
        <%
             LocalDate currentDate = LocalDate.now();
    
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            MovieDAO movieDAO = new MovieDAO();
            ShowDAO showDAO = new ShowDAO();
            Movie movie = movieDAO.getMovieById(movieId);

            if (movie == null) {
                response.sendRedirect("index.jsp");
                return;
            }
        %>

        <div class="movie-details-container">
            <div class="movie-hero">
                <img src="<%= movie.getImagePath()%>" alt="<%= movie.getMovieName()%> Banner">
            </div>

            <div class="movie-info-grid">
                <div class="movie-poster">
                    <img src="<%= movie.getImagePath()%>" alt="<%= movie.getMovieName()%> Poster">
                </div>

                <div class="movie-info">
                    <h1 class="movie-title"><%= movie.getMovieName()%></h1>

                    <div class="movie-meta">
                        <div class="meta-item">
                            <i class="fas fa-film"></i>
                            <span><%= movie.getLanguage()%></span>
                        </div>
                        <div class="meta-item">
                            <i class="fas fa-star"></i>
                            <span><%= movie.getRating()%></span>
                        </div>
                        <div class="meta-item">
                            <i class="fas fa-clock"></i>
                            <span>Now Showing</span>
                        </div>
                    </div>

                    <div class="movie-description">
                        <p><%= movie.getContent()%></p>
                    </div>

                    <div class="pricing-section">
                        <h3>Ticket Pricing</h3>
                        <div class="price-item">
                            <span>Adult Ticket</span>
                            <span>Rs.<%= movie.getAdultTicketPrice()%></span>
                        </div>
                        <div class="price-item">
                            <span>Child Ticket</span>
                            <span>Rs.<%= movie.getChildTicketPrice()%></span>
                        </div>
                    </div>

                    <div class="booking-actions">

                        <button class="btn btn-secondary" onclick="playTrailer('<%= movie.getTrailerLink()%>')">
                            Watch Trailer
                        </button>
                    </div>
                </div>

            </div>
            <div class="shows-section">
                <h2 class="shows-header">Available Shows</h2>

                <%
                    Map<LocalDate, List<Show>> showsByDate = showDAO.getAvailableShowsByMovie(movieId);
                    if (showsByDate.isEmpty()) {
                %>
                <p class="no-shows">No shows available for this movie.</p>
                <%
                } else {
                %>
                <div class="date-container">
                    <%
                        for (LocalDate date : showsByDate.keySet()) {
                            boolean isToday = date.equals(LocalDate.now());
                    %>
                    <div class="date-block <%= isToday ? "active" : ""%>" data-date="<%= date%>">
                        <p class="day"><%= date.format(DateTimeFormatter.ofPattern("EEE"))%></p>
                        <p class="date"><%= date.format(DateTimeFormatter.ofPattern("d"))%></p>
                        <p class="month"><%= date.format(DateTimeFormatter.ofPattern("MMM"))%></p>
                    </div>
                    <%
                        }
                    %>
                </div>
<div class="shows-grid">
    <%
        LocalDate firstDate = showsByDate.keySet().iterator().next();
        List<Show> firstDateShows = showsByDate.get(firstDate);
        LocalTime currentTime = LocalTime.now();
        
        for (Show show : firstDateShows) {
            // Parse time manually
            String showTimeStr = show.getShowTime(); // Example: "3.30 PM"
            String[] timeParts = showTimeStr.split(" "); // Split into ["3.30", "PM"]
            String[] timeNumbers = timeParts[0].split("\\."); // Split into ["3", "30"]
            int hours = Integer.parseInt(timeNumbers[0]);
            int minutes = Integer.parseInt(timeNumbers[1]);
            
            // Convert to 24-hour format
            if (timeParts[1].equals("PM") && hours != 12) {
                hours += 12;
            } else if (timeParts[1].equals("AM") && hours == 12) {
                hours = 0;
            }
            
            LocalTime showTime = LocalTime.of(hours, minutes);
            boolean isPastShow = LocalDate.now().equals(firstDate) && 
                               showTime.isBefore(currentTime);
    %>
    <div class="show-card <%= isPastShow ? "show-expired" : "" %>">
        <h3 class="show-time"><%= show.getShowTime()%></h3>
        <p class="hall-info"><%= show.getHallName()%></p>
        <button class="book-button" 
                <%= isPastShow ? "disabled" : "" %>
                onclick="<%= isPastShow ? "" : "location.href='selectSeats.jsp?showId=" + show.getShowId() + "'" %>">
            <%= isPastShow ? "Not Available" : "Book Now" %>
        </button>
    </div>
    <%
        }
    %>
</div>

                <%
                    }
                %>
            </div>
        </div>

        <!-- Trailer Modal -->
        <div class="trailer-modal" id="trailerModal">
            <div class="modal-content">
                <button class="close-modal" onclick="closeTrailer()">✕</button>
                <div class="video-container">
                    <iframe id="trailerVideo" allowfullscreen></iframe>
                </div>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function() {
            const dateBlocks = document.querySelectorAll('.date-block');
            const showsGrid = document.querySelector('.shows-grid');
            // Create JavaScript object to store shows by date
            const showsByDate = {
            <%
                    boolean isFirst = true;
                    for (Map.Entry<LocalDate, List<Show>> entry : showsByDate.entrySet()) {
                        String dateKey = entry.getKey().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
                        if (!isFirst) {
                            out.print(",");
                        }
                        isFirst = false;
            %>
            "<%= dateKey%>": [
            <%
                            List<Show> shows = entry.getValue();
                            for (int i = 0; i < shows.size(); i++) {
                                Show show = shows.get(i);
                                if (i > 0) {
                                    out.print(",");
                                }
            %>
            {
            "showId": <%= show.getShowId()%>,
                    "showTime": "<%= show.getShowTime()%>",
                    "hallName": "<%= show.getHallName()%>"
            }
            <%
                            }
            %>
            ]
            <%
                    }
            %>
            };
            dateBlocks.forEach(function(block) {
            block.addEventListener('click', function() {
            dateBlocks.forEach(function(b) {
            b.classList.remove('active');
            });
            this.classList.add('active');
            const selectedDate = this.dataset.date;
            updateShowsGrid(selectedDate);
            });
            });
            
     function updateShowsGrid(date) {
    const shows = showsByDate[date];
    showsGrid.innerHTML = '';
    
    if (shows && shows.length > 0) {
        const now = new Date();
        const today = now.toISOString().split('T')[0];
        
        for (var i = 0; i < shows.length; i++) {
            var show = shows[i];
            
            // Parse time manually
            var timeParts = show.showTime.split(' '); // Split "3.30 PM" into ["3.30", "PM"]
            var timeNumbers = timeParts[0].split('.'); // Split "3.30" into ["3", "30"]
            var hours = parseInt(timeNumbers[0]);
            var minutes = parseInt(timeNumbers[1]);
            var ampm = timeParts[1];
            
            // Convert to 24-hour format
            if (ampm === 'PM' && hours !== 12) {
                hours += 12;
            } else if (ampm === 'AM' && hours === 12) {
                hours = 0;
            }
            
            var showDate = new Date(date);
            showDate.setHours(hours, minutes, 0, 0);
            
            var isPastShow = date === today && showDate < now;
            
            var showCard = 
                '<div class="show-card ' + (isPastShow ? 'show-expired' : '') + '">' +
                    '<h3 class="show-time">' + show.showTime + '</h3>' +
                    '<p class="hall-info">' + show.hallName + '</p>' +
                    '<button class="book-button" ' + 
                    (isPastShow ? 'disabled' : '') + ' ' +
                    (isPastShow ? '' : 'onclick="location.href=\'selectSeats.jsp?showId=' + show.showId + '\'"') +
                    '>' +
                    (isPastShow ? 'Not Available' : 'Book Now') +
                    '</button>' +
                '</div>';
            showsGrid.innerHTML += showCard;
        }
    } else {
        showsGrid.innerHTML = '<p class="no-shows">No shows available for this date.</p>';
    }
}



            });
            
            // Trailer functions
            function playTrailer(trailerUrl) {
            const modal = document.getElementById('trailerModal');
            const videoFrame = document.getElementById('trailerVideo');
            if (trailerUrl.includes('youtube.com/watch?v=')) {
            trailerUrl = trailerUrl.replace('watch?v=', 'embed/');
            }
            videoFrame.src = trailerUrl;
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            }

            function closeTrailer() {
            const modal = document.getElementById('trailerModal');
            const videoFrame = document.getElementById('trailerVideo');
            videoFrame.src = '';
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
            }
function hasTimePassed(date, showTime) {
    const now = new Date();
    const showDateTime = new Date(date + ' ' + showTime);
    return now > showDateTime;
}

        </script>
    </body>
</html>
