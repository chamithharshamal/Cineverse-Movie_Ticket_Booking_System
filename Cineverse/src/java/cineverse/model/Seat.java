package cineverse.model;

public class Seat {
    private int seatId;
    private int showId;
    private String seatNumber;
    private boolean isBooked;

    // Default constructor
    public Seat() {
    }

    // Constructor with parameters
    public Seat(int showId, String seatNumber) {
        this.showId = showId;
        this.seatNumber = seatNumber;
        this.isBooked = false;
    }

    // Getters and Setters
    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public int getShowId() {
        return showId;
    }

    public void setShowId(int showId) {
        this.showId = showId;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public boolean isBooked() {
        return isBooked;
    }

    public void setBooked(boolean booked) {
        isBooked = booked;
    }
}
