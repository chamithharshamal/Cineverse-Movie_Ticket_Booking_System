<%-- 
    Document   : index
    Created on : Jan 20, 2025, 11:12:49 AM
    Author     : Dell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Movie Ticket Booking</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
        <link href="css/index.css" rel="stylesheet">

    </head>
    <body>
        <header>
            <div class="logo">Cineverse</div>
            <input type="text" placeholder="Search for movies...">
            <div class="right-section">
                <button class="login-btn">Login</button>
                <button class="login-btn">Sign Up</button>
                <div class="dropdown">
                    <div class="menu-icon" onclick="toggleDropdown(event)">☰</div>
                    <div class="dropdown-content" id="dropdownContent">
                        <a href="#"><i class="fas fa-home"></i> Home</a>
                        <a href="#"><i class="fas fa-ticket-alt"></i> My Bookings</a>
                        <a href="#"><i class="fas fa-user"></i> Profile</a>
                        <a href="#"><i class="fas fa-cog"></i> Settings</a>
                        <a href="#"><i class="fas fa-sign-out-alt"></i> Logout</a>
                    </div>
                </div>
            </div>
        </header>

        <div class="banner">
            <div class="carousel" id="carousel">
                <img src="image1.jpg" alt="" class="active">
                <img src="image2.jpg" alt="">
                <img src="image3.jpg" alt="">
            </div>
            <div class="carousel-controls">
                <button onclick="prevSlide()">❮</button>
                <button onclick="nextSlide()">❯</button>
            </div>
        </div>

        <section class="now-showing">
            <h2 class="section-title">Now Showing</h2>
            <div class="movie-container">
                <div class="movie-card">
                    <img src="movie.jpg" alt="">
                    <div class="info">
                        <h3>Pushpa 2: The Rule</h3>
                        <p>Telugu</p>
                    </div>
                    <div class="button-group">
                        <button class="book-btn">Book Now</button>
                        <button class="trailer-btn" onclick="playTrailer('https://www.youtube.com/embed/your-video-id')">Watch Trailer</button>
                    </div>
                </div>  
            </div>
        </section>

        <section class="coming-soon">
            <h2 class="section-title">Coming Soon</h2>
            <div class="movie-container">
                <div class="movie-card">
                    <img src="movie2.jpg" alt="Coming Soon Movie">
                    <div class="info">
                        <h3>Upcoming Movie</h3>
                        <p></p>
                        <div class="button-group">
                        <button class="book-btn">Notify Me</button>
                        <button class="trailer-btn" onclick="playTrailer('https://www.youtube.com/embed/your-video-id')">Watch Trailer</button>
                    </div>
                    </div>
                </div>
                <!-- Add more movie cards -->
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
    const slides = document.querySelectorAll('.carousel img');

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

 
    function toggleDropdown(event) {
        event.stopPropagation();
        const dropdown = document.getElementById('dropdownContent');
        dropdown.classList.toggle('show');
    }

   
    document.addEventListener('click', function(event) {
        const dropdown = document.getElementById('dropdownContent');
        const menuIcon = document.querySelector('.menu-icon');
        
        if (!menuIcon.contains(event.target) && !dropdown.contains(event.target)) {
            dropdown.classList.remove('show');
        }
    });

  
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
</script>

      
    </body>
</html>

