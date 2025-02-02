package cineverse.servlet;

import cineverse.dao.BookingDAO;
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

    public void init() {
        bookingDAO = new BookingDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            // Get user email from session
            String userEmail = ((User) session.getAttribute("user")).getEmail();
            
            // Get booking details from session
            Integer showId = (Integer) session.getAttribute("bookingShowId");
            Integer movieId = (Integer) session.getAttribute("bookingMovieId");
            String[] selectedSeats = (String[]) session.getAttribute("bookingSeats");
            String hallName = (String) session.getAttribute("bookingHallName");
            Integer adultCount = (Integer) session.getAttribute("bookingAdultCount");
            Integer childCount = (Integer) session.getAttribute("bookingChildCount");
            Double totalAmount = (Double) session.getAttribute("bookingTotalAmount");

            // Validate all required data is present
            if (userEmail == null || showId == null || movieId == null || 
                selectedSeats == null || hallName == null || 
                adultCount == null || childCount == null || totalAmount == null) {
                throw new ServletException("Missing required booking information");
            }

            // Create new booking
            Booking booking = new Booking(
                userEmail,
                movieId,
                showId,
                String.join(",", selectedSeats),
                hallName,
                adultCount,
                childCount,
                totalAmount
            );

            // Save booking to database
            int bookingId = bookingDAO.createBooking(booking);

            if (bookingId > 0) {
                // Clear booking-related session attributes
              /*  session.removeAttribute("bookingShowId");
                session.removeAttribute("bookingMovieId");
                session.removeAttribute("bookingSeats");
                session.removeAttribute("bookingHallName");
                session.removeAttribute("bookingAdultCount");
                session.removeAttribute("bookingChildCount");
                session.removeAttribute("bookingTotalAmount");
*/
                // Store booking ID in session for confirmation page
                session.setAttribute("lastBookingId", bookingId);

                // Redirect to confirmation page
                response.sendRedirect("bookingConfirmation.jsp");
            } else {
                throw new ServletException("Failed to create booking");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=" + e.getMessage());
        }
    }
}
