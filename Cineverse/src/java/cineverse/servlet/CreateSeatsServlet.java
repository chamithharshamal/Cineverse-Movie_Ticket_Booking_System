package cineverse.servlet;

import cineverse.dao.SeatDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CreateSeatsServlet")
public class CreateSeatsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int showId = Integer.parseInt(request.getParameter("showId"));
        
        SeatDAO seatDAO = new SeatDAO();
        boolean success = seatDAO.createSeatsForShow(showId);
        
        response.setContentType("application/json");
        response.getWriter().write("{\"success\": " + success + "}");
    }
}
