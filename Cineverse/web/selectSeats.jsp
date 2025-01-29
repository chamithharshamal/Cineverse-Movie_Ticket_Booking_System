<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="cineverse.model.Seat"%>
<%@page import="cineverse.model.Show"%>
<%@page import="cineverse.dao.ShowDAO"%>
<%@page import="cineverse.dao.SeatDAO"%>
<%@page import="java.util.List"%>
<%@page import="cineverse.model.Movie"%>
<%@page import="cineverse.dao.MovieDAO"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Seats - Cineverse</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="css/selectSeats.css" rel="stylesheet">
</head>
<body>
  <%
    int showId = Integer.parseInt(request.getParameter("showId"));
    ShowDAO showDAO = new ShowDAO();
    MovieDAO movieDAO = new MovieDAO();
    SeatDAO seatDAO = new SeatDAO();
    
    Show show = showDAO.getShowById(showId);
    Movie movie = movieDAO.getMovieById(show.getMovieId()); // Get the movie object
    List<Seat> seats = seatDAO.getSeatsByShowId(showId);
%>
    <div class="seat-selection-container">
        <div class="screen-container">
            <div class="screen"></div>
            <p class="screen-text">Screen</p>
        </div>

        <div class="seats-container">
            <% 
                char[] rows = {'A', 'B', 'C', 'D'};
                for(char row : rows) {
            %>
            <div class="seat-row">
                <div class="row-label"><%= row %></div>
                <% 
                    for(int i = 1; i <= 10; i++) {
                        String seatNumber = row + String.valueOf(i);
                        boolean isBooked = false;
                        
                        // Find if seat is booked
                        for(Seat seat : seats) {
                            if(seat.getSeatNumber().equals(seatNumber)) {
                                isBooked = seat.isBooked();
                                break;
                            }
                        }
                %>
                <div class="seat <%= isBooked ? "booked" : "" %>" 
                     data-seat="<%= seatNumber %>"
                     onclick="selectSeat(this)">
                    <%= seatNumber %>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <div class="legend">
            <div class="legend-item">
                <div class="legend-box available"></div>
                <span>Available</span>
            </div>
            <div class="legend-item">
                <div class="legend-box selected"></div>
                <span>Selected</span>
            </div>
            <div class="legend-item">
                <div class="legend-box booked"></div>
                <span>Booked</span>
            </div>
        </div>
        <div class="type-container">
<div id="ticketTypeSelection"  class="ticket-type-container">
    <h3>Select Ticket Types</h3>
    <p>Selected Seats: <span id="totalSeatsSelected">0</span></p>
    <div class="ticket-type-controls">
        <div class="ticket-type">
            <label>Adults (Rs. <%= movie.getAdultTicketPrice() %>)</label>
            <div class="quantity-control">
                <button type="button" onclick="adjustTicketCount('adult', -1)">-</button>
                <input type="number" id="adultCount" value="0" readonly>
                <button type="button" onclick="adjustTicketCount('adult', 1)">+</button>
            </div>
        </div>
        <div class="ticket-type">
            <label>Children (Rs. <%= movie.getChildTicketPrice() %>)</label>
            <div class="quantity-control">
                <button type="button" onclick="adjustTicketCount('child', -1)">-</button>
                <input type="number" id="childCount" value="0" readonly>
                <button type="button" onclick="adjustTicketCount('child', 1)">+</button>
            </div>
        </div>
    </div>
    <p id="ticketTypeError" class="error-message"></p>
</div>

        <div class="booking-summary">
            <h3>Selected Seats: <span id="selectedSeatsText">None</span></h3>
            <h3>Total Amount: Rs. <span id="totalAmount">0</span></h3>
            <button id="proceedButton" class="proceed-button" disabled 
                    onclick="proceedToBooking()">
                Proceed to Payment
            </button>
        </div>
    </div>
    </div>
    <script>
        let selectedSeats = [];
const adultPrice = <%= movie.getAdultTicketPrice() %>;
const childPrice = <%= movie.getChildTicketPrice() %>;
let adultCount = 0;
let childCount = 0;

function selectSeat(seatElement) {
    if(seatElement.classList.contains('booked')) return;
    
    const seatNumber = seatElement.dataset.seat;
    
    if(seatElement.classList.contains('selected')) {
        seatElement.classList.remove('selected');
        selectedSeats = selectedSeats.filter(seat => seat !== seatNumber);
    } else {
        seatElement.classList.add('selected');
        selectedSeats.push(seatNumber);
    }
    
    updateBookingSummary();
    updateTicketTypeSection();
}

function updateTicketTypeSection() {
    const ticketTypeSection = document.getElementById('ticketTypeSelection');
    const totalSeatsSelected = document.getElementById('totalSeatsSelected');
    
    if(selectedSeats.length > 0) {
        ticketTypeSection.style.display = 'block';
        totalSeatsSelected.textContent = selectedSeats.length;
        // Reset counts when seats change
        adultCount = 0;
        childCount = 0;
        document.getElementById('adultCount').value = 0;
        document.getElementById('childCount').value = 0;
        updateBookingSummary();
    } else {
        ticketTypeSection.style.display = 'none';
    }
}

function adjustTicketCount(type, change) {
    const totalSeats = selectedSeats.length;
    const currentTotal = adultCount + childCount;
    
    if(type === 'adult') {
        if(change > 0 && currentTotal >= totalSeats) return;
        if(change < 0 && adultCount <= 0) return;
        adultCount += change;
        document.getElementById('adultCount').value = adultCount;
    } else {
        if(change > 0 && currentTotal >= totalSeats) return;
        if(change < 0 && childCount <= 0) return;
        childCount += change;
        document.getElementById('childCount').value = childCount;
    }
    
    updateBookingSummary();
    validateTicketCounts();
}

function validateTicketCounts() {
    const totalSeats = selectedSeats.length;
    const currentTotal = adultCount + childCount;
    const errorElement = document.getElementById('ticketTypeError');
    const proceedButton = document.getElementById('proceedButton');
    
    if(currentTotal < totalSeats) {
        errorElement.textContent = `Please select ${totalSeats - currentTotal} more ticket type(s)`;
        proceedButton.disabled = true;
    } else if(currentTotal > totalSeats) {
        errorElement.textContent = 'Total tickets cannot exceed selected seats';
        proceedButton.disabled = true;
    } else {
        errorElement.textContent = '';
        proceedButton.disabled = false;
    }
}

function updateBookingSummary() {
    const selectedSeatsText = document.getElementById('selectedSeatsText');
    const totalAmountText = document.getElementById('totalAmount');
    
    if(selectedSeats.length > 0) {
        selectedSeatsText.textContent = selectedSeats.join(', ');
        const totalAmount = (adultCount * adultPrice) + (childCount * childPrice);
        totalAmountText.textContent = totalAmount.toFixed(2);
    } else {
        selectedSeatsText.textContent = 'None';
        totalAmountText.textContent = '0';
    }
}

function proceedToBooking() {
    if(selectedSeats.length > 0 && (adultCount + childCount) === selectedSeats.length) {
        const queryString = `showId=<%= showId %>&seats=${selectedSeats.join(',')}&adults=${adultCount}&children=${childCount}`;
        window.location.href = `payment.jsp?${queryString}`;
    }
}

    </script>
</body>
</html>
