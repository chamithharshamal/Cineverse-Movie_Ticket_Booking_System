<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.model.Show"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%@page import="cineverse.dao.ShowDAO"%>
<%@ page import="cineverse.dao.BookingDAO" %>
<%@ page import="cineverse.model.Booking" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmation - Cineverse</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="css/confirmation.css" rel="stylesheet">
    <script src="https://kit.fontawesome.com/your-font-awesome-kit.js"></script>
</head>
<body>
    <div class="confirmation-container">
        <%
            try {
                Integer bookingId = (Integer) session.getAttribute("lastBookingId");
                
                if (bookingId != null) {
                    BookingDAO bookingDAO = new BookingDAO();
                    Booking booking = bookingDAO.getBookingById(bookingId);
                    
                    if (booking != null) {
                        ShowDAO showDAO = new ShowDAO();
                        MovieDAO movieDAO = new MovieDAO();
                        
                        Show show = showDAO.getShowById(booking.getShowId());
                        
                        if (show != null) {
                            Movie movie = movieDAO.getMovieById(booking.getMovieId());
                            
                            if (movie != null) {
                                SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
                                SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
        %>
                                <h1>Booking Confirmed!</h1>
                                <div class="ticket">
                                    <div class="ticket-header">
                                        <img src="<%= movie.getImagePath() %>" alt="<%= movie.getMovieName() %>" onerror="this.src='images/default-movie.jpg'">
                                        <div class="movie-title"><%= movie.getMovieName() %></div>
                                    </div>

                                    <div class="ticket-body">
                                        <div class="ticket-info">
                                            <div class="info-item">
                                                <span class="info-label">Date</span>
                                                <span class="info-value"><%= dateFormat.format(show.getStartDate()) %></span>
                                            </div>
                                            <div class="info-item">
                                                <span class="info-label">Time</span>
                                                <span class="info-value"><%= show.getShowTime() %></span>
                                            </div>
                                            <div class="info-item">
                                                <span class="info-label">Hall</span>
                                                <span class="info-value"><%= booking.getHallName() %></span>
                                            </div>
                                            <div class="info-item">
                                                <span class="info-label">Seats</span>
                                                <span class="info-value"><%= booking.getSelectedSeats() %></span>
                                            </div>
                                            <div class="info-item">
                                                <span class="info-label">Adult Tickets</span>
                                                <span class="info-value"><%= booking.getAdultCount() %></span>
                                            </div>
                                            <div class="info-item">
                                                <span class="info-label">Child Tickets</span>
                                                <span class="info-value"><%= booking.getChildCount() %></span>
                                            </div>
                                            <div class="info-item">
                                                <span class="info-label">Total Amount</span>
                                                <span class="info-value">Rs. <%= String.format("%.2f", booking.getTotalAmount()) %></span>
                                            </div>
                                            <div class="info-item">
                                                <span class="info-label">Booking Date</span>
                                                <span class="info-value"><%= dateFormat.format(booking.getBookingDate()) %></span>
                                            </div>
                                        </div>

                                        <div class="qr-code">
                                            <img src="https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=CINEVERSE-BOOKING-<%= booking.getBookingId() %>" 
                                                 alt="QR Code">
                                        </div>
                                        
                                        <div class="ticket-footer">
                                            <p>Thank you for choosing Cineverse!</p>
                                            <p>Please arrive 15 minutes before showtime.</p>
                                            <p>This ticket is valid only for the specified show time and date.</p>
                                        </div>

                                        <div class="ticket-watermark">CINEVERSE</div>
                                        <div class="status-badge">Confirmed</div>
                                        <div class="booking-id">Booking ID: #<%= booking.getBookingId() %></div>
                                    </div>
                                </div>

                                <div class="action-buttons">
                                    <a href="downloadTicket?bookingId=<%= booking.getBookingId() %>" class="button">
                                        <i class="fas fa-download"></i> Download Ticket
                                    </a>
                                    <a href="index.jsp" class="button">
                                        <i class="fas fa-home"></i> Back to Home
                                    </a>
                                </div>
        <%
                            } else {
                                throw new Exception("Movie details not found");
                            }
                        } else {
                            throw new Exception("Show details not found");
                        }
                    } else {
                        throw new Exception("Booking details not found");
                    }
                } else {
                    throw new Exception("No booking ID found in session");
                }
            } catch (Exception e) {
        %>
                <div class="error-container">
                    <h2>Error</h2>
                    <p class="error-message"><%= e.getMessage() %></p>
                    <div class="action-buttons">
                        <a href="index.jsp" class="button">
                            <i class="fas fa-home"></i> Back to Home
                        </a>
                    </div>
                </div>
        <%
            }
        %>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const ticket = document.querySelector('.ticket');
            if (ticket) {
                ticket.style.opacity = '0';
                ticket.style.transform = 'translateY(20px)';
                setTimeout(() => {
                    ticket.style.transition = 'all 0.8s ease';
                    ticket.style.opacity = '1';
                    ticket.style.transform = 'translateY(0)';
                }, 100);
            }
        });
    </script>
</body>
</html>
