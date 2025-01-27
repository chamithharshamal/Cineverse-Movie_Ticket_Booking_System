<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

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
                    <%                        Movie movieToEdit = (Movie) request.getAttribute("movieToEdit");
                    %>

                    <form class="movie-form" action="${pageContext.request.contextPath}/admin/EditMovieServlet" 
                          method="post" enctype="multipart/form-data" onsubmit="return validateForm(this);">
                        <input type="hidden" name="action" value="<%= movieToEdit != null ? "update" : "add"%>">

                        <input type="hidden" name="submission_token" value="<%= System.currentTimeMillis()%>">

                        <div class="form-group">
                            <label for="movie-id">Movie ID:</label>
                            <input type="number" id="movie-id" name="movie-id" 
                                   value="<%= movieToEdit != null ? movieToEdit.getMovieId() : ""%>" 
                                   <%= movieToEdit != null ? "readonly" : ""%> required />
                        </div>

                        <div class="form-group">
                            <label for="movie-name">Movie Name:</label>
                            <input type="text" id="movie-name" name="movie-name" 
                                   value="<%= movieToEdit != null ? movieToEdit.getMovieName() : ""%>" required />
                        </div>

                        <div class="form-group">
                            <label for="movie-language">Language:</label>
                            <select id="movie-language" name="movie-language" required>
                                <option value="">Select Language</option>
                                <option value="english" <%= movieToEdit != null && "english".equals(movieToEdit.getLanguage()) ? "selected" : ""%>>English</option>
                                <option value="hindi" <%= movieToEdit != null && "hindi".equals(movieToEdit.getLanguage()) ? "selected" : ""%>>Hindi</option>
                                <option value="tamil" <%= movieToEdit != null && "tamil".equals(movieToEdit.getLanguage()) ? "selected" : ""%>>Tamil</option>
                                <option value="telugu" <%= movieToEdit != null && "telugu".equals(movieToEdit.getLanguage()) ? "selected" : ""%>>Telugu</option>
                                <option value="malayalam" <%= movieToEdit != null && "malayalam".equals(movieToEdit.getLanguage()) ? "selected" : ""%>>Malayalam</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="movie-content">Description:</label>
                            <textarea id="movie-content" name="movie-content" required><%= movieToEdit != null ? movieToEdit.getContent() : ""%></textarea>
                        </div>

                        <div class="form-group">
                            <label for="movie-trailer">Trailer Link:</label>
                            <input type="url" id="movie-trailer" name="movie-trailer" 
                                   value="<%= movieToEdit != null ? movieToEdit.getTrailerLink() : ""%>" required />
                        </div>

                        <div class="form-group">
                            <label for="movie-image">Movie Image:</label>
                            <input type="file" id="movie-image" name="movie-image" accept="image/*" 
                                   <%= movieToEdit == null ? "required" : ""%> />
                            <% if (movieToEdit != null) {%>
                            <p>Current image: <%= movieToEdit.getImagePath()%></p>
                            <input type="hidden" name="current-image" value="<%= movieToEdit.getImagePath()%>" />
                            <% }%>
                        </div>

                        <div class="form-group">
                            <label for="movie-rating">Rating:</label>
                            <select id="movie-rating" name="movie-rating" required>
                                <option value="">Select Rating</option>
                                <option value="G" <%= movieToEdit != null && "G".equals(movieToEdit.getRating()) ? "selected" : ""%>>G (General Audience)</option>
                                <option value="PG" <%= movieToEdit != null && "PG".equals(movieToEdit.getRating()) ? "selected" : ""%>>PG (Parental Guidance)</option>
                                <option value="PG-13" <%= movieToEdit != null && "PG-13".equals(movieToEdit.getRating()) ? "selected" : ""%>>PG-13 (Parental Guidance for children under 13)</option>
                                <option value="R" <%= movieToEdit != null && "R".equals(movieToEdit.getRating()) ? "selected" : ""%>>R (Restricted)</option>
                                <option value="NC-17" <%= movieToEdit != null && "NC-17".equals(movieToEdit.getRating()) ? "selected" : ""%>>NC-17 (Adults Only)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="movie-status">Status:</label>
                            <select id="movie-status" name="movie-status" required>
                                <option value="">Select Status</option>
                                <option value="now-showing" <%= movieToEdit != null && "now-showing".equals(movieToEdit.getStatus()) ? "selected" : ""%>>Now Showing</option>
                                <option value="coming-soon" <%= movieToEdit != null && "coming-soon".equals(movieToEdit.getStatus()) ? "selected" : ""%>>Coming Soon</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="adult-ticket-price">Adult Ticket Price (Rs.):</label>
                            <input type="number" id="adult-ticket-price" name="adult-ticket-price" 
                                   value="<%= movieToEdit != null ? movieToEdit.getAdultTicketPrice() : ""%>"
                                   min="0" step="0.01" required />
                        </div>

                        <div class="form-group">
                            <label for="child-ticket-price">Child Ticket Price (Rs.):</label>
                            <input type="number" id="child-ticket-price" name="child-ticket-price" 
                                   value="<%= movieToEdit != null ? movieToEdit.getChildTicketPrice() : ""%>"
                                   min="0" step="0.01" required />
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="submit-btn">
                                <%= movieToEdit != null ? "Update Movie" : "Save Movie"%>
                            </button>
                            <button type="reset" class="reset-btn" onclick="resetForm()">Reset</button>
                            <% if (movieToEdit != null) { %>
                            <button type="button" class="cancel-btn" onclick="window.location.href = '${pageContext.request.contextPath}/admin/addMovie.jsp'">Cancel</button>
                            <% } %>
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
                                    <img src="../<%=movie.getImagePath()%>" 
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
                                    <form action="${pageContext.request.contextPath}/admin/EditMovieServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="fetchMovie">
                                        <input type="hidden" name="movieId" value="<%= movie.getMovieId()%>">
                                        <button type="submit" class="edit-btn">Edit</button>
                                    </form>

                                    <form action="${pageContext.request.contextPath}/admin/DeleteMovieServlet" method="post" style="display:inline;"
                                          onsubmit="return confirm('Are you sure you want to delete this movie?');">
                                        <input type="hidden" name="movieId" value="<%= movie.getMovieId()%>">
                                        <button type="submit" class="delete-btn">Delete</button>
                                    </form>
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
            setTimeout(() = > {  // Fixed arrow function syntax
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
            return validateForm(form); // Combine with form validation
            }

            function validateForm(form) {
            console.log('Validating form...');
            // Get form values
            const movieId = form['movie-id'].value;
            const movieName = form['movie-name'].value;
            const adultPrice = parseFloat(form['adult-ticket-price'].value);
            const childPrice = parseFloat(form['child-ticket-price'].value);
            // Basic validation
            if (!movieId || !movieName) {
            showMessage('Movie ID and Name are required!');
            return false;
            }

            if (childPrice > adultPrice) {
            showMessage('Child ticket price cannot be higher than adult ticket price!');
            return false;
            }

            // Log form submission
            console.log('Form validation passed. Submitting...');
            return true;
            }

            function resetForm() {
            if (confirm('Are you sure you want to reset the form?')) {
            document.querySelector('.movie-form').reset();
            window.location.href = '${pageContext.request.contextPath}/admin/addMovie.jsp';
            }
            }

            // Event Listeners
            document.addEventListener('DOMContentLoaded', function() {
            // Initialize form submission handler
            const movieForm = document.querySelector('.movie-form');
            if (movieForm) {
            movieForm.addEventListener('submit', function(e) {
            if (!preventDoubleSubmission(this)) {
            e.preventDefault();
            }
            });
            }

            // Show message if exists
            <% if (message != null && !message.isEmpty()) {%>
            showMessage('<%= message%>');
            <% }%>
            });
        </script>


    </body>
</html>
