package cineverse.servlet;

import cineverse.dao.ShowDAO;
import cineverse.model.Show;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin/insertShowServlet")
public class InsertShowServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
           
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int hallId = Integer.parseInt(request.getParameter("hallId"));
            String[] showTimes = request.getParameterValues("showTime");
            
           
            LocalDate startDate = Date.valueOf(request.getParameter("startDate")).toLocalDate();
            LocalDate endDate = Date.valueOf(request.getParameter("endDate")).toLocalDate();
            
            // Calculate number of days between start and end date
            long daysBetween = ChronoUnit.DAYS.between(startDate, endDate) + 1;
            
            ShowDAO showDAO = new ShowDAO();
            boolean allSuccess = true;
            List<Show> showsToAdd = new ArrayList<>();

            // Create shows for each day
            for (int i = 0; i < daysBetween; i++) {
                LocalDate currentDate = startDate.plusDays(i);
                
                // Create shows for each selected time slot on current date
                for (String showTime : showTimes) {
                    Show show = new Show(
                        movieId,
                        hallId,
                        showTime,
                        Date.valueOf(currentDate),
                        Date.valueOf(currentDate)  
                    );
                    showsToAdd.add(show);
                }
            }

            for (Show show : showsToAdd) {
                if (!showDAO.addShow(show)) {
                    allSuccess = false;
                    break;
                }
            }

            if (allSuccess) {
                response.sendRedirect("addShow.jsp?success=true");
            } else {
                response.sendRedirect("addShow.jsp?error=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addShow.jsp?error=true");
        }
    }
}
