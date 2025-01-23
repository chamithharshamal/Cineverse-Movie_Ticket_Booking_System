<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Movie Details - Cineverse</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="css/booking.css" rel="stylesheet">
</head>
<body>
    <%
        int movieId = Integer.parseInt(request.getParameter("movieId"));
        MovieDAO movieDAO = new MovieDAO();
        Movie movie = movieDAO.getMovieById(movieId);
        
        if (movie == null) {
            response.sendRedirect("index.jsp");
            return;
        }
    %>

    <div class="movie-details-container">
        <div class="movie-hero">
            <img src="<%= movie.getImagePath() %>" alt="<%= movie.getMovieName() %> Banner">
        </div>

        <div class="movie-info-grid">
            <div class="movie-poster">
                <img src="<%= movie.getImagePath() %>" alt="<%= movie.getMovieName() %> Poster">
            </div>

            <div class="movie-info">
                <h1 class="movie-title"><%= movie.getMovieName() %></h1>

                <div class="movie-meta">
                    <div class="meta-item">
                        <i class="fas fa-film"></i>
                        <span><%= movie.getLanguage() %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-star"></i>
                        <span><%= movie.getRating() %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-clock"></i>
                        <span>Now Showing</span>
                    </div>
                </div>

                <div class="movie-description">
                    <p><%= movie.getContent() %></p>
                </div>

                <div class="pricing-section">
                    <h3>Ticket Pricing</h3>
                    <div class="price-item">
                        <span>Adult Ticket</span>
                        <span>Rs.<%= movie.getAdultTicketPrice() %></span>
                    </div>
                    <div class="price-item">
                        <span>Child Ticket</span>
                        <span>Rs.<%= movie.getChildTicketPrice() %></span>
                    </div>
                </div>

                <div class="booking-actions">
                    <button class="btn btn-primary" onclick="location.href='selectSeats.jsp?movieId=<%= movie.getMovieId() %>'">
                        Select Seats
                    </button>
                    <button class="btn btn-secondary" onclick="playTrailer('<%= movie.getTrailerLink() %>')">
                        Watch Trailer
                    </button>
                </div>
            </div>
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
    </script>
</body>
</html>
