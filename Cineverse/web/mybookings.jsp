<%@page import="java.util.*"%>
<%@page import="java.time.*"%>
<%@page import="cineverse.model.*"%>
<%@page import="cineverse.dao.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>My Bookings | Cineverse</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="css/mybookings.css" rel="stylesheet">
    </head>
    <body>
        <%
            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            BookingDAO bookingDAO = new BookingDAO();
            MovieDAO movieDAO = new MovieDAO();
            List<Booking> allBookings = bookingDAO.getBookingsByUserEmail(currentUser.getEmail());

            List<Booking> futureBookings = new ArrayList<Booking>();
            List<Booking> pastBookings = new ArrayList<Booking>();

            LocalDateTime now = LocalDateTime.now();

            for (Booking booking : allBookings) {
                LocalDateTime bookingDateTime = booking.getBookingDate().toLocalDateTime();
                if (bookingDateTime.isAfter(now)) {
                    futureBookings.add(booking);
                } else {
                    pastBookings.add(booking);
                }
            }
        %>

        <div class="container py-5">
            <h2 class="mb-4">My Bookings</h2>

            <!-- Future Bookings Section -->
            <% if (futureBookings.isEmpty()) { %>
            <div class="no-bookings">
                <i class="fas fa-ticket-alt fa-2x mb-3"></i>
                <p>No upcoming bookings found</p>
            </div>
            <% } else { %>
            <% for (Booking booking : futureBookings) {
                    Movie movie = movieDAO.getMovieById(booking.getMovieId());
            %>
            <div class="booking-card future-booking">
                <div class="booking-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Booking #<%= booking.getBookingId()%></h5>
                    <span class="status-badge">
                        <%= booking.getPaymentStatus()%>
                    </span>
                </div>
                <div class="booking-details">
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Movie:</strong> <%= movie != null ? movie.getMovieName() : "N/A"%></p>
                            <p><strong>Hall:</strong> <%= booking.getHallName()%></p>
                            <p><strong>Seats:</strong> <%= booking.getSelectedSeats()%></p>
                            <p><strong>Date:</strong> <%= booking.getBookingDate()%></p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Tickets:</strong> 
                                <%= booking.getAdultCount()%> Adult(s), 
                                <%= booking.getChildCount()%> Child(ren)
                            </p>
                            <p><strong>Total Amount:</strong> Rs. <%= String.format("%.2f", booking.getTotalAmount())%></p>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
            <% } %>

            <!-- Past Bookings Section -->
            <h3 class="mb-4">Past Bookings</h3>
            <% if (pastBookings.isEmpty()) { %>
            <div class="no-bookings">
                <i class="fas fa-history fa-2x mb-3"></i>
                <p>No past bookings found</p>
            </div>
            <% } else { %>
            <% for (Booking booking : pastBookings) {
                    Movie movie = movieDAO.getMovieById(booking.getMovieId());
            %>
            <div class="booking-card past-booking">
                <div class="booking-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Booking #<%= booking.getBookingId()%></h5>
                    <span class="status-badge">
                        <%= booking.getPaymentStatus()%>
                    </span>
                </div>
                <div class="booking-details">
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Movie:</strong> <%= movie != null ? movie.getMovieName() : "N/A"%></p> 
                            <p><strong>Hall:</strong> <%= booking.getHallName()%></p>
                            <p><strong>Seats:</strong> <%= booking.getSelectedSeats()%></p>
                            <p><strong>Date:</strong> <%= booking.getBookingDate()%></p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Tickets:</strong> 
                                <%= booking.getAdultCount()%> Adult(s), 
                                <%= booking.getChildCount()%> Child(ren)
                            </p>
                            <p><strong>Total Amount:</strong> Rs. <%= String.format("%.2f", booking.getTotalAmount())%></p>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
            <% }%>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
