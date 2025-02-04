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
    <script src="https://www.paypal.com/sdk/js?client-id=_your_paypal_sdk_id_"></script>
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
    
     session.setAttribute("bookingMovieId", movie.getMovieId());
    session.setAttribute("bookingHallName", show.getHallName());

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
             <!--   <div class="total-amount">
                    <span>Total Amount</span>
                    <span>Rs. <%= String.format("%.2f", totalAmount) %></span>
                </div> -->
            </div>
        </div>

       <div class="payment-section">
    <h2>Payment</h2>
    <div class="paypal-section">
        <div class="amount-display">
            <div class="lkr-amount">
                Amount (LKR): Rs. <%= String.format("%.2f", totalAmount) %>
            </div>
            <div class="usd-amount">
                Amount (USD): $<span id="usdAmount"><%= String.format("%.2f", totalAmount / 300.0) %></span>
            </div>
        </div>
        <div id="paypal-button-container">
           
        </div>
    </div>
    <div class="payment-actions">
        <form action="BookingServlet" method="post">
        <button type="submit" id="confirmBooking" class="confirm-button">
            Confirm Booking
        </button>
        </form>
    </div>
</div>

    </div>
             <script>
    const totalAmount = <%= totalAmount %>; // Get the total amount from JSP
    const convertedAmount = (totalAmount / 300).toFixed(2); // Convert LKR to USD

    paypal.Buttons({
        createOrder: function(data, actions) {
            console.log('Total Amount (LKR):', totalAmount);
            console.log('Converted Amount (USD):', convertedAmount);

            return actions.order.create({
                purchase_units: [{
                    amount: {
                        value: convertedAmount,
                        currency_code: 'USD'
                    },
                    description: 'Movie Ticket Booking - Cineverse'
                }]
            });
        },
        onApprove: function(data, actions) {
            return actions.order.capture().then(function(orderData) {
                console.log('Payment Completed - Order Data:', orderData);
                
                // Enable and show the confirm booking button
                const confirmButton = document.getElementById('confirmBooking');
                confirmButton.classList.add('active');
                confirmButton.disabled = false;
                
                // Show success message
                alert('Payment completed successfully! Please click Confirm Booking to complete your reservation.');
                
                // Set payment status
                paymentComplete = true;
            });
        },
        onError: function(err) {
            console.error('PayPal Error Details:', {
                name: err.name,
                message: err.message,
                stack: err.stack
            });
            alert('Payment failed: ' + (err.message || 'An error occurred during payment. Please try again.'));
        },
        onCancel: function(data) {
            console.log('Payment Cancelled:', data);
            alert('Payment was cancelled. Please try again if you wish to complete your booking.');
        }
    }).render('#paypal-button-container');

    // Confirm booking button handler
    document.getElementById('confirmBooking').addEventListener('click', function() {
        if (paymentComplete) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'PaymentServlet';
            
            const formData = {
                'showId': '<%= showId %>',
                'seats': '<%= String.join(",", selectedSeats) %>',
                'adults': '<%= adultCount %>',
                'children': '<%= childCount %>',
                'totalAmount': '<%= totalAmount %>',
                'paymentStatus': 'COMPLETED'
            };

            // Create hidden fields
            Object.entries(formData).forEach(([name, value]) => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = name;
                input.value = value;
                form.appendChild(input);
            });

            document.body.appendChild(form);
            form.submit();
        }
    });
</script>
    <script>
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
                    window.location.href = 'selectSeats.jsp';
                }
            }, 1000);
        }

        window.onload = function () {
            let tenMinutes = 60 * 10,
                display = document.querySelector('#timer');
            startTimer(tenMinutes, display);
        };

    </script>
</body>
</html>
