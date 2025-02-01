<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.model.Show"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%@page import="cineverse.dao.ShowDAO"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - Cineverse</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://www.paypal.com/sdk/js?client-id=YOUR_PAYPAL_CLIENT_ID&currency=INR"></script>
      <link href="css/payment.css" rel="stylesheet">
         
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer showId = (Integer) session.getAttribute("bookingShowId");
    String[] selectedSeats = (String[]) session.getAttribute("bookingSeats");
    Integer adultCount = (Integer) session.getAttribute("bookingAdultCount");
    Integer childCount = (Integer) session.getAttribute("bookingChildCount");
    Double totalAmount = (Double) session.getAttribute("bookingTotalAmount");
    
    ShowDAO showDAO = new ShowDAO();
    MovieDAO movieDAO = new MovieDAO();
    Show show = showDAO.getShowById(showId);
    Movie movie = movieDAO.getMovieById(show.getMovieId());

    if (showId == null || selectedSeats == null || adultCount == null || 
        childCount == null || totalAmount == null) {
        response.sendRedirect("error.jsp?message=Invalid booking session");
        return;
    }
%>

</head>
<body>
    <div class="payment-container">
        <div class="booking-summary">
            <h2>Booking Summary</h2>
            
            <div class="timer-container">
                <p>Time remaining to complete payment</p>
                <div class="timer" id="timer">10:00</div>
            </div>

            <div class="booking-details">
                <div class="detail-item">
                    <span class="detail-label">Movie</span>
                    <span class="detail-value"><%= movie.getMovieName() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Date</span>
                    <span class="detail-value"><%= show.getStartDate() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Time</span>
                    <span class="detail-value"><%= show.getShowTime() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Hall</span>
                    <span class="detail-value"><%= show.getHallName() %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Selected Seats</span>
                    <span class="detail-value"><%= String.join(", ", selectedSeats) %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Adult Tickets</span>
                    <span class="detail-value"><%= adultCount %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Child Tickets</span>
                    <span class="detail-value"><%= childCount %></span>
                </div>
                <div class="total-amount">
                    <span>Total Amount</span>
                    <span>Rs. <%= String.format("%.2f", totalAmount) %></span>
                </div>
            </div>
        </div>

        <div class="payment-section">
            <h2>Payment Method</h2>
            <div class="payment-methods">
                <div class="payment-method">
                    <input type="radio" id="card" name="paymentMethod" value="card">
                    <label for="card">Credit/Debit Card</label>
                </div>
                <div class="payment-method">
                    <input type="radio" id="upi" name="paymentMethod" value="upi">
                    <label for="upi">UPI</label>
                </div>
                <div class="payment-method">
                    <input type="radio" id="paypal" name="paymentMethod" value="paypal" checked>
                    <label for="paypal">PayPal</label>
                </div>
            </div>

            <div id="paypal-button-container"></div>
        </div>
    </div>

    <script>
        // Timer functionality
        function startTimer(duration, display) {
            let timer = duration, minutes, seconds;
            let countdown = setInterval(function () {
                minutes = parseInt(timer / 60, 10);
                seconds = parseInt(timer % 60, 10);

                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;

                display.textContent = minutes + ":" + seconds;

                if (--timer < 0) {
                    clearInterval(countdown);
                    window.location.href = 'timeout.jsp';
                }
            }, 1000);
        }

        window.onload = function () {
            let tenMinutes = 60 * 10,
                display = document.querySelector('#timer');
            startTimer(tenMinutes, display);
        };

        // PayPal integration
        paypal.Buttons({
            createOrder: function(data, actions) {
                return actions.order.create({
                    purchase_units: [{
                        amount: {
                            value: '<%= totalAmount %>'
                        }
                    }]
                });
            },
            onApprove: function(data, actions) {
                return actions.order.capture().then(function(details) {
                   
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'ProcessPaymentServlet';

                    // Add hidden fields
                    const addHiddenField = (name, value) => {
                        const field = document.createElement('input');
                        field.type = 'hidden';
                        field.name = name;
                        field.value = value;
                        form.appendChild(field);
                    };

                    addHiddenField('showId', '<%= showId %>');
                    addHiddenField('seats', '<%= String.join(",", selectedSeats) %>');
                    addHiddenField('adults', '<%= adultCount %>');
                    addHiddenField('children', '<%= childCount %>');
                    addHiddenField('totalAmount', '<%= totalAmount %>');
                    addHiddenField('paymentMethod', 'paypal');
                    addHiddenField('paymentId', details.id);

                    document.body.appendChild(form);
                    form.submit();
                });
            }
        }).render('#paypal-button-container');
    </script>
</body>
</html>
