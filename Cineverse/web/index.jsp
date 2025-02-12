<%-- 
    Document   : index
    Created on : Jan 20, 2025, 11:12:49 AM
    Author     : Dell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Movie Ticket Booking</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
        <link href="css/index.css" rel="stylesheet">

    </head>
    <%

        String userEmail = null;
        String userName = null;
        boolean isLoggedIn = false;

        if (session.getAttribute("user") != null) {
            isLoggedIn = true;
            cineverse.model.User user = (cineverse.model.User) session.getAttribute("user");
            userName = user.getName();
        } else {

            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if (cookie.getName().equals("userEmail")) {
                        userEmail = cookie.getValue();
                    }
                }

                if (userEmail != null) {
                    cineverse.dao.UserDAO userDao = new cineverse.dao.UserDAO();
                    cineverse.model.User user = userDao.getUserByEmail(userEmail);
                    if (user != null) {
                        isLoggedIn = true;
                        userName = user.getName();
                        session.setAttribute("user", user);
                    }
                }
            }
        }

        if (!isLoggedIn && request.getParameter("protected") != null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <body>
        <header>
            <div class="logo">Cineverse</div>
            <input type="text" placeholder="Search for movies...">
            <div class="right-section">
                <% if (isLoggedIn) {%>
                <div class="user-info">
                    <span>Welcome, <%= userName%></span>
                    <div class="dropdown">
                        <div class="menu-icon" onclick="toggleDropdown(event)">☰</div>
                        <div class="dropdown-content" id="dropdownContent">
                            <a href="index.jsp"><i class="fas fa-home"></i> Home</a>
                            <a href="mybookings.jsp"><i class="fas fa-ticket-alt"></i> My Bookings</a>
                            <a href="profile.jsp"><i class="fas fa-user"></i> Profile</a>
                            <a href="settings.jsp"><i class="fas fa-cog"></i> Settings</a>
                            <a href="#" onclick="logout()"><i class="fas fa-sign-out-alt"></i> Logout</a>
                        </div>
                    </div>
                </div>
                <% } else { %>
                <a href="login.jsp" class="login-btn">Login</a>
                <% } %>
            </div>
        </header>
        <%
            MovieDAO movieDAO = new MovieDAO();
            List<Movie> allMovies = movieDAO.getAllMovies();
            List<Movie> nowShowingMovies = movieDAO.getMoviesByStatus("now-showing");
            List<Movie> comingSoonMovies = movieDAO.getMoviesByStatus("coming-soon");
        %>


        <div class="banner">
            <div class="carousel" id="carousel">
                <%
                    int carouselLimit = Math.min(3, allMovies.size());
                    for (int i = 0; i < carouselLimit; i++) {
                        Movie movie = allMovies.get(i);
                %>
                <div class="slide-container <%= i == 0 ? "active" : ""%>">
                    <img src="<%= movie.getImagePath()%>" alt="<%= movie.getMovieName()%>" class="background-image">
                    <img src="<%= movie.getImagePath()%>" alt="<%= movie.getMovieName()%>" class="main-image">
                </div>
                <% } %>
            </div>

            <div class="carousel-controls">
                <button onclick="prevSlide()">❮</button>
                <button onclick="nextSlide()">❯</button>
            </div>
        </div>


        <section class="now-showing">
            <h2 class="section-title">Now Showing</h2>
            <div class="movie-container">
                <% for (Movie movie : nowShowingMovies) {%>
                <div class="movie-card">
                    <img src="<%= movie.getImagePath()%>" alt="<%= movie.getMovieName()%>">
                    <div class="info">
                        <h3><%= movie.getMovieName()%></h3>
                        <p><%= movie.getLanguage()%></p>
                    </div>
                    <div class="button-group">
                        <button class="book-btn" onclick="location.href = 'booking.jsp?movieId=<%= movie.getMovieId()%>'">Book Now</button>
                        <button class="trailer-btn" onclick="playTrailer('<%= movie.getTrailerLink()%>')">Watch Trailer</button>
                    </div>
                </div>
                <% } %>
            </div>
        </section>


        <section class="coming-soon">
            <h2 class="section-title">Coming Soon</h2>
            <div class="movie-container">
                <% for (Movie movie : comingSoonMovies) {%>
                <div class="movie-card">
                    <img src="<%= movie.getImagePath()%>" alt="<%= movie.getMovieName()%>">
                    <div class="info">
                        <h3><%= movie.getMovieName()%></h3>
                        <p><%= movie.getLanguage()%></p>
                    </div>
                    <div class="button-group">
                        <button class="book-btn">Notify Me</button>
                        <button class="trailer-btn" onclick="playTrailer('<%= movie.getTrailerLink()%>')">Watch Trailer</button>
                    </div>
                </div>
                <% }%>
            </div>
        </section>

        <br><br>
        <footer>
            &copy; 2025 <a href="#">Cineverse</a>. All Rights Reserved.
        </footer>
        <div class="trailer-modal" id="trailerModal">
            <div class="modal-content">
                <button class="close-modal" onclick="closeTrailer()">✕</button>
                <div class="video-container">
                    <iframe id="trailerVideo" allowfullscreen></iframe>
                </div>
            </div>
        </div>
        <script>
            let currentSlide = 0;
            const slides = document.querySelectorAll('.carousel .slide-container');
            function showSlide(index) {

            slides.forEach(function(slide) {
            slide.classList.remove('active');
            });
            const totalSlides = slides.length;
            currentSlide = (index + totalSlides) % totalSlides;
            slides[currentSlide].classList.add('active');
            }

            function nextSlide() {
            showSlide(currentSlide + 1);
            }

            function prevSlide() {
            showSlide(currentSlide - 1);
            }

            setInterval(nextSlide, 5000);
            showSlide(0);
            function playTrailer(trailerUrl) {
            const modal = document.getElementById('trailerModal');
            const videoFrame = document.getElementById('trailerVideo');
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


            document.getElementById('trailerModal').addEventListener('click', function(e) {
            if (e.target === this) {
            closeTrailer();
            }
            });
            showSlide(0);
            function logout() {

            document.cookie = "userEmail=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
            document.cookie = "userPassword=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
            document.cookie = "rememberMe=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
            window.location.href = 'logout';
            }

            function playTrailer(trailerUrl) {
            const modal = document.getElementById('trailerModal');
            const videoFrame = document.getElementById('trailerVideo');
            // Check if the URL is a valid YouTube URL and modify if needed
            if (trailerUrl.includes('youtube.com/watch?v=')) {
            trailerUrl = trailerUrl.replace('watch?v=', 'embed/');
            }
            videoFrame.src = trailerUrl;
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            }

        </script>


    </body>
</html>

