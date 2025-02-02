package cineverse.model;

import java.sql.Timestamp;

public class Booking {
    private int bookingId;
    private String userEmail;
    private int movieId;
    private int showId;
    private String selectedSeats;
    private String hallName;
    private int adultCount;
    private int childCount;
    private double totalAmount;
    private Timestamp bookingDate;
    private String paymentStatus;

    // Default constructor
    public Booking() {}

    // Constructor with parameters
    public Booking(String userEmail, int movieId, int showId, String selectedSeats, 
                  String hallName, int adultCount, int childCount, double totalAmount) {
        this.userEmail = userEmail;
        this.movieId = movieId;
        this.showId = showId;
        this.selectedSeats = selectedSeats;
        this.hallName = hallName;
        this.adultCount = adultCount;
        this.childCount = childCount;
        this.totalAmount = totalAmount;
    }

    // Getters and Setters
    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public int getMovieId() {
        return movieId;
    }

    public void setMovieId(int movieId) {
        this.movieId = movieId;
    }

    public int getShowId() {
        return showId;
    }

    public void setShowId(int showId) {
        this.showId = showId;
    }

    public String getSelectedSeats() {
        return selectedSeats;
    }

    public void setSelectedSeats(String selectedSeats) {
        this.selectedSeats = selectedSeats;
    }

    public String getHallName() {
        return hallName;
    }

    public void setHallName(String hallName) {
        this.hallName = hallName;
    }

    public int getAdultCount() {
        return adultCount;
    }

    public void setAdultCount(int adultCount) {
        this.adultCount = adultCount;
    }

    public int getChildCount() {
        return childCount;
    }

    public void setChildCount(int childCount) {
        this.childCount = childCount;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Timestamp getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(Timestamp bookingDate) {
        this.bookingDate = bookingDate;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
}
