<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
                </header>

                <h3>Add New Movie</h3>
                <form id="movie-form" class="movie-form" action="addMovie" method="post" enctype="multipart/form-data">
                    <label for="movie-id">Movie ID:</label>
                    <input
                        type="number"
                        id="movie-id"
                        name="movie-id"
                        required
                    />

                    <label for="movie-name">Movie Name:</label>
                    <input
                        type="text"
                        id="movie-name"
                        name="movie-name"
                        required
                    />

                    <label for="movie-language">Movie Language:</label>
                    <select id="movie-language" name="movie-language" required>
                        <option value="english">English</option>
                        <option value="hindi">Hindi</option>
                        <option value="tamil">Tamil</option>
                        <option value="telugu">Telugu</option>
                        <option value="malayalam">Malayalam</option>
                    </select>

                    <label for="movie-content">Movie Content:</label>
                    <textarea id="movie-content" name="movie-content" required></textarea>

                    <label for="movie-trailer">Movie Trailer Link:</label>
                    <input
                        type="text"
                        id="movie-trailer"
                        name="movie-trailer"
                        required
                    />

                    <!-- Image Upload Section -->
                    <div class="image-upload">
                        <label for="movie-image">Upload Movie Flyer Image:</label>
                        <input
                            type="file"
                            id="movie-image"
                            name="movie-image"
                            accept="image/*"
                            required
                        />
                    </div>

                    <!-- Movie Rating Section -->
                    <div class="rating-section">
                        <label for="movie-rating">Movie Rating:</label>
                        <select id="movie-rating" name="movie-rating" required>
                            <option value="G">G (General Audience)</option>
                            <option value="PG">PG (Parental Guidance)</option>
                            <option value="PG-13">PG-13 (Parental Guidance for children under 13)</option>
                            <option value="R">R (Restricted)</option>
                            <option value="NC-17">NC-17 (Adults Only)</option>
                        </select>
                    </div>

                    <!-- Movie Status -->
                    <label for="movie-status">Movie Status:</label>
                    <select id="movie-status" name="movie-status" required>
                        <option value="now-showing">Now Showing</option>
                        <option value="coming-soon">Coming Soon</option>
                    </select>

                    <!-- Ticket Pricing Section -->
                    <div class="ticket-pricing">
                        <h4>Ticket Pricing</h4>
                        
                        <label for="adult-ticket-price">Adult Ticket Price (18+):</label>
                        <div class="price-input">
                            <span class="currency">Rs.</span>
                            <input
                                type="number"
                                id="adult-ticket-price"
                                name="adult-ticket-price"
                                min="0"
                                step="0.10"
                                required
                            />
                        </div>

                        <label for="child-ticket-price">Child Ticket Price (Below 18):</label>
                        <div class="price-input">
                            <span class="currency">Rs.</span>
                            <input
                                type="number"
                                id="child-ticket-price"
                                name="child-ticket-price"
                                min="0"
                                step="0.10"
                                required
                            />
                        </div>
                    </div>

                    <div class="form-buttons">
                        <button type="submit">Save Movie</button>
                        <button type="button">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <footer>
            &copy; 2025 <a href="#">Cineverse</a>. All Rights Reserved.
        </footer>
    </body>
</html>
