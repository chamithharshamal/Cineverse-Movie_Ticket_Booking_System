<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String message = (String) session.getAttribute("message");
    String messageType = (String) session.getAttribute("messageType");
    session.removeAttribute("message");
    session.removeAttribute("messageType");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Movie Management</title>
        <link href="../css/sidePanel.css" rel="stylesheet">
    </head>
    <body>
        <div class="container">
            <div class="left">
                <jsp:include page="sidePanel.jsp" />
            </div>

            <div class="right">
                <header>
                    <h1>Movie Management</h1>
                    <a href="#add-movie-form" class="add-btn">Add New Movie</a>
                </header>

                <!-- Add Movie Form Section -->
                <div id="add-movie-form" class="form-section">
                    <h2>Add New Movie</h2>
                  <form class="movie-form" action="${pageContext.request.contextPath}/admin/AddMovieServlet" 
      method="post" enctype="multipart/form-data" onsubmit="return preventDoubleSubmission(this);">
    <input type="hidden" name="submission_token" value="<%= System.currentTimeMillis() %>">

                        <div class="form-group">
                            <label for="movie-id">Movie ID:</label>
                            <input type="number" id="movie-id" name="movie-id" required />
                        </div>

                        <div class="form-group">
                            <label for="movie-name">Movie Name:</label>
                            <input type="text" id="movie-name" name="movie-name" required />
                        </div>

                        <div class="form-group">
                            <label for="movie-language">Language:</label>
                            <select id="movie-language" name="movie-language" required>
                                <option value="">Select Language</option>
                                <option value="english">English</option>
                                <option value="hindi">Hindi</option>
                                <option value="tamil">Tamil</option>
                                <option value="telugu">Telugu</option>
                                <option value="malayalam">Malayalam</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="movie-content">Description:</label>
                            <textarea id="movie-content" name="movie-content" required></textarea>
                        </div>

                        <div class="form-group">
                            <label for="movie-trailer">Trailer Link:</label>
                            <input type="url" id="movie-trailer" name="movie-trailer" required />
                        </div>

                        <div class="form-group">
                            <label for="movie-image">Movie Image:</label>
                            <input type="file" id="movie-image" name="movie-image" accept="image/*" required />
                        </div>

                        <div class="form-group">
                            <label for="movie-rating">Rating:</label>
                            <select id="movie-rating" name="movie-rating" required>
                                <option value="">Select Rating</option>
                                <option value="G">G (General Audience)</option>
                                <option value="PG">PG (Parental Guidance)</option>
                                <option value="PG-13">PG-13 (Parental Guidance for children under 13)</option>
                                <option value="R">R (Restricted)</option>
                                <option value="NC-17">NC-17 (Adults Only)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="movie-status">Status:</label>
                            <select id="movie-status" name="movie-status" required>
                                <option value="">Select Status</option>
                                <option value="now-showing">Now Showing</option>
                                <option value="coming-soon">Coming Soon</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="adult-ticket-price">Adult Ticket Price (Rs.):</label>
                            <input type="number" id="adult-ticket-price" name="adult-ticket-price" 
                                   min="0" step="0.01" required />
                        </div>

                        <div class="form-group">
                            <label for="child-ticket-price">Child Ticket Price (Rs.):</label>
                            <input type="number" id="child-ticket-price" name="child-ticket-price" 
                                   min="0" step="0.01" required />
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="submit-btn">Save Movie</button>
                            <button type="reset" class="reset-btn">Reset</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <footer>
            <p>&copy; 2025 Cineverse. All Rights Reserved.</p>
        </footer>

        <script>
            window.onload = function() {
                const message = "${message}";
                const messageType = "${messageType}";
                
                if (message) {
                    alert(message);
                }
            };
            
       
            function deleteMovie(movieId) {
                if (confirm('Are you sure you want to delete this movie?')) {
                    window.location.href = 'deleteMovie?id=' + movieId;
                }
            }
            
            document.querySelector('.movie-form').onsubmit = function(e) {
                const adultPrice = document.getElementById('adult-ticket-price').value;
                const childPrice = document.getElementById('child-ticket-price').value;
                
                if (parseFloat(childPrice) > parseFloat(adultPrice)) {
                    alert('Child ticket price cannot be higher than adult ticket price');
                    e.preventDefault();
                    return false;
                }
                return true;
            };
            
             function preventDoubleSubmission(form) {
        if (form.submitted) {
            alert('Form already submitted. Please wait...');
            return false;
        }
        
        form.submitted = true;
        form.querySelector('.submit-btn').disabled = true;
        return true;
    }

    window.onload = function() {
        const message = "<%= message %>";
        if (message && message !== "null") {
            alert(message);
        }
    };
    
    if (window.history.replaceState) {
        window.history.replaceState(null, null, window.location.href);
    }
        </script>
        <script>
    window.onload = function() {
        const message = "<%= message %>";
        if (message && message !== "null") {
            alert(message);
        }
    };
</script>
    </body>
</html>
