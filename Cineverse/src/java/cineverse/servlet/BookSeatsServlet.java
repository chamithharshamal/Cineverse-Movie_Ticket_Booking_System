package cineverse.servlet;

import cineverse.dao.SeatDAO;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/BookSeatsServlet")
public class BookSeatsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int showId = Integer.parseInt(request.getParameter("showId"));
        String[] seatNumbers = request.getParameter("seats").split(",");
        List<String> seats = Arrays.asList(seatNumbers);
        
        SeatDAO seatDAO = new SeatDAO();
        boolean success = seatDAO.bookSeats(showId, seats);
        
        if (success) {
            response.sendRedirect("confirmation.jsp");
        } else {
            response.sendRedirect("error.jsp");
        }
    }
}
