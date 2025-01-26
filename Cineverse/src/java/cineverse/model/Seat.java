
package cineverse.model;


public class Seat {
    private int seatId;
    private Show show;
    private String seatNumber;
    private boolean isBooked;
    
    public Seat(){}
    
    public Seat(int seatId, Show show, String seatNumber, boolean isBooked) {
        this.seatId = seatId;
        this.show = show;
        this.seatNumber = seatNumber;
        this.isBooked = isBooked;
    }

    public Seat(String string, boolean aBoolean) {
       
    }

    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public Show getShow() {
        return show;
    }

    public void setShow(Show show) {
        this.show = show;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public boolean isIsBooked() {
        return isBooked;
    }

    public void setIsBooked(boolean isBooked) {
        this.isBooked = isBooked;
    }

    
}
