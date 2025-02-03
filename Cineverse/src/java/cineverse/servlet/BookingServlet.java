package cineverse.servlet;

import cineverse.connection.EmailService;
import cineverse.dao.BookingDAO;
import cineverse.dao.SeatDAO;
import cineverse.model.Booking;
import cineverse.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {

    private BookingDAO bookingDAO;
    private SeatDAO seatDAO;

    public void init() {
        bookingDAO = new BookingDAO();
        seatDAO = new SeatDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        try {
            // Get user from session
            User user = (User) session.getAttribute("user");
            if (user == null) {
                throw new ServletException("User not logged in");
            }

            Integer showId = (Integer) session.getAttribute("bookingShowId");
            Integer movieId = (Integer) session.getAttribute("bookingMovieId");
            String[] selectedSeats = (String[]) session.getAttribute("bookingSeats");
            String hallName = (String) session.getAttribute("bookingHallName");
            Integer adultCount = (Integer) session.getAttribute("bookingAdultCount");
            Integer childCount = (Integer) session.getAttribute("bookingChildCount");
            Double totalAmount = (Double) session.getAttribute("bookingTotalAmount");

            if (showId == null || movieId == null || selectedSeats == null
                    || hallName == null || adultCount == null || childCount == null
                    || totalAmount == null) {
                throw new ServletException("Missing required booking information");
            }

            // Create booking object
            Booking booking = new Booking(
                    user.getEmail(),
                    movieId,
                    showId,
                    String.join(",", selectedSeats),
                    hallName,
                    adultCount,
                    childCount,
                    totalAmount
            );

            if (!seatDAO.areSeatsAvailable(showId, selectedSeats)) {
                throw new ServletException("Selected seats are no longer available");
            }

            // Create booking
            int bookingId = bookingDAO.createBooking(booking);
            if (bookingId <= 0) {
                throw new ServletException("Failed to create booking");
            }

            // Update seats status
            boolean seatsUpdated = bookingDAO.updateSeatsStatus(showId, selectedSeats);
            if (!seatsUpdated) {
                throw new ServletException("Failed to update seats status");
            }

            String emailSubject = "Booking Confirmation - CineVerse";
            String emailBody = createEmailBody(booking, bookingId, user.getName());

            new Thread(() -> {
                EmailService.sendEmail(user.getEmail(), emailSubject, emailBody);
            }).start();

            session.setAttribute("lastBookingId", bookingId);

            // Clear booking session attributes
            session.removeAttribute("bookingShowId");
            session.removeAttribute("bookingMovieId");
            session.removeAttribute("bookingSeats");
            session.removeAttribute("bookingHallName");
            session.removeAttribute("bookingAdultCount");
            session.removeAttribute("bookingChildCount");
            session.removeAttribute("bookingTotalAmount");

            response.sendRedirect("bookingConfirmation.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message="
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    private String createEmailBody(Booking booking, int bookingId, String username) {
        StringBuilder html = new StringBuilder();
        html.append("<html><body>");
        html.append("<h2>Thank you for your booking at CineVerse!</h2>");
        html.append("<p>Dear ").append(username).append(",</p>");
        html.append("<p>Your booking has been confirmed. Here are your booking details:</p>");
        html.append("<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px;'>");
        html.append("<p><strong>Booking ID:</strong> ").append(bookingId).append("</p>");
        html.append("<p><strong>Hall:</strong> ").append(booking.getHallName()).append("</p>");
        html.append("<p><strong>Seats:</strong> ").append(booking.getSelectedSeats()).append("</p>");
        html.append("<p><strong>Adults:</strong> ").append(booking.getAdultCount()).append("</p>");
        html.append("<p><strong>Children:</strong> ").append(booking.getChildCount()).append("</p>");
        html.append("<p><strong>Total Amount:</strong> Rs. ").append(String.format("%.2f", booking.getTotalAmount())).append("</p>");
        html.append("</div>");
        html.append("<p>Please arrive at least 15 minutes before the show time.</p>");
        html.append("<p>Enjoy your movie!</p>");
        html.append("<p>Best regards,<br>CineVerse Team</p>");
        html.append("</body></html>");
        return html.toString();
    }
}
