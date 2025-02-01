package cineverse.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
         
            int showId = Integer.parseInt(request.getParameter("showId"));
            String[] selectedSeats = request.getParameter("seats").split(",");
            String[] seatIds = request.getParameter("seatIds").split(",");
            int adultCount = Integer.parseInt(request.getParameter("adults"));
            int childCount = Integer.parseInt(request.getParameter("children"));
            double totalAmount = Double.parseDouble(request.getParameter("totalAmount"));
            
           
            HttpSession session = request.getSession();
            session.setAttribute("bookingShowId", showId);
            session.setAttribute("bookingSeats", selectedSeats);
            session.setAttribute("bookingSeatsIds", seatIds);
            session.setAttribute("bookingAdultCount", adultCount);
            session.setAttribute("bookingChildCount", childCount);
            session.setAttribute("bookingTotalAmount", totalAmount);
            
           
            response.sendRedirect("payment.jsp");
            
        } catch (NumberFormatException e) {
            response.sendRedirect("error.jsp?message=Invalid booking parameters");
        }
    }
}
