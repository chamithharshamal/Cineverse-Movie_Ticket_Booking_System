<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message"); 
    }
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
          <div id="message" class="message"></div>
        
        <div class="container">
            <div class="left">
                <jsp:include page="sidePanel.jsp" />
            </div>

            <div class="right">
                <header>
                    <h1>Movie Management</h1>
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
    <div class="movie-table-container">
    <h2>Current Movies</h2>
    <table class="movie-table">
        <thead>
            <tr>
                <th>Image</th>
                <th>Movie ID</th>
                <th>Name</th>
                <th>Language</th>
                <th>Rating</th>
                <th>Status</th>
                <th>Adult Price</th>
                <th>Child Price</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
                MovieDAO movieDAO = new MovieDAO();
                List<Movie> allMovies = movieDAO.getAllMovies();
                if (allMovies != null && !allMovies.isEmpty()) {
                    for (Movie movie : allMovies) {
            %>
            <tr>
                <td>
                    <img src="<%=movie.getImagePath()%>" 
                         alt="<%= movie.getMovieName()%>" 
                         class="movie-thumbnail">
                </td>
                <td><%= movie.getMovieId()%></td>
                <td><%= movie.getMovieName()%></td>
                <td><%= movie.getLanguage()%></td>
                <td><%= movie.getRating()%></td>
                <td><%= movie.getStatus()%></td>
                <td>Rs.<%= movie.getAdultTicketPrice()%></td>
                <td>Rs.<%= movie.getChildTicketPrice()%></td>
                <td>
                    <button onclick="editMovie(<%= movie.getMovieId()%>)" class="edit-btn">Edit</button>
                    <button onclick="deleteMovie(<%= movie.getMovieId()%>)" class="delete-btn">Delete</button>
                </td>
            </tr>
            <%
                }
            } else {
            %>
            <tr>
                <td colspan="9" class="no-movies">No movies available at the moment.</td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>
</div>
            </div>
        </div>

        <footer>
            <p>&copy; 2025 Cineverse. All Rights Reserved.</p>
        </footer>
<script>
    function showMessage(text) {
        const messageDiv = document.getElementById('message');
        messageDiv.textContent = text;
        messageDiv.style.display = 'block';
        
     
        setTimeout(() => {
            messageDiv.style.display = 'none';
        }, 4000);
    }

   
    function preventDoubleSubmission(form) {
        if (form.submitted) {
            showMessage('Form already submitted. Please wait...');
            return false;
        }
        form.submitted = true;
        form.querySelector('.submit-btn').disabled = true;
        return true;
    }

    document.querySelector('.movie-form').onsubmit = function(e) {
        const adultPrice = document.getElementById('adult-ticket-price').value;
        const childPrice = document.getElementById('child-ticket-price').value;
        
        if (parseFloat(childPrice) > parseFloat(adultPrice)) {
            showMessage('Child ticket price cannot be higher than adult ticket price');
            e.preventDefault();
            return false;
        }
        return true;
    };

    document.addEventListener('DOMContentLoaded', function() {
        <% if (message != null && !message.isEmpty()) { %>
            showMessage('<%= message %>');
        <% } %>
    });
</script>

    </body>
</html>
