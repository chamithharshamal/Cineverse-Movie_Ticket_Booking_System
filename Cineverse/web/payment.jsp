<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.model.Show"%>
<%@page import="cineverse.dao.ShowDAO"%>
<%@page import="cineverse.dao.MovieDAO"%>

<%
  
    boolean hasError = false;
    String errorMessage = "";

  
    String showIdParam = request.getParameter("showId");
    String selectedSeats = request.getParameter("seats");


    if (showIdParam == null) {
        errorMessage += "Missing parameter: 'showId'. ";
        hasError = true;
    }
    if (selectedSeats == null) {
        errorMessage += "Missing parameter: 'seats'. ";
        hasError = true;
    }


    if (hasError) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("<script>console.error(`" + errorMessage + "`);</script>"); 
        System.err.println("ERROR: " + errorMessage); 
        out.print("Error: " + errorMessage); 
        return;
    }

    int showId = 0;
    try {
        showId = Integer.parseInt(showIdParam);
    } catch (NumberFormatException e) {
        errorMessage = "Invalid 'showId'. It must be a valid integer.";
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("<script>console.error(`" + errorMessage + "`);</script>"); 
        System.err.println("ERROR: " + errorMessage); 
        out.print("Error: " + errorMessage); 
        return;
    }

    ShowDAO showDAO = new ShowDAO();
    MovieDAO movieDAO = new MovieDAO();

    Show show = showDAO.getShowById(showId);
    if (show == null) {
        errorMessage = "No show found for ID: " + showId;
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        out.print("<script>console.error(`" + errorMessage + "`);</script>");
        System.err.println("ERROR: " + errorMessage);
        out.print("Error: " + errorMessage);
        return;
    }

    Movie movie = movieDAO.getMovieById(show.getMovieId());
    if (movie == null) {
        errorMessage = "No movie found for ID: " + show.getMovieId();
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        out.print("<script>console.error(`" + errorMessage + "`);</script>");
        System.err.println("ERROR: " + errorMessage);
        out.print("Error: " + errorMessage);
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Checkout - Payment</title>
</head>
<body>
    <h1>Checkout Summary</h1>
    <p>Movie: <%= movie.getMovieName() %></p>
    <p>Selected Seats: <%= selectedSeats %></p>
    <% 
        // Calculate Total Amount
        double adultPrice = movie.getAdultTicketPrice();
        int seatCount = selectedSeats.split(",").length;
        double totalAmount = seatCount * adultPrice;
        double totalAmountInUSD = totalAmount / 300.0;
        String formattedTotalAmountInUSD = String.format("%.2f", totalAmountInUSD);
    %>
    <p>Total Amount (INR): Rs. <%= totalAmount %></p>
    <p>Total Amount (USD): $<%= formattedTotalAmountInUSD %></p>

    <div id="paypal-button-container"></div>

    <script src="https://www.paypal.com/sdk/js?client-id=YOUR_PAYPAL_CLIENT_ID&currency=USD"></script>
    <script>
        paypal.Buttons({
            createOrder: function(data, actions) {
                return actions.order.create({
                    purchase_units: [{
                        amount: {
                            value: '<%= formattedTotalAmountInUSD %>'
                        }
                    }]
                });
            },
            onApprove: function(data, actions) {
                return actions.order.capture().then(function(details) {
                    alert('Payment successful! Redirecting...');
                    window.location.href = 'confirmation.jsp';
                });
            }
        }).render('#paypal-button-container');
    </script>
</body>
</html>
