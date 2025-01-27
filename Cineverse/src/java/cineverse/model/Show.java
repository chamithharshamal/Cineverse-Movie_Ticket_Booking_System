package cineverse.model;

import java.sql.Date;

public class Show {
    private int showId;
    private int movieId;
    private int hallId;
    private String showTime;
    private Date startDate;
    private Date endDate;
    private String status;
    private String hallName;
    

    // Default constructor
    public Show() {
        this.status = "active";
    }

    // Constructor for creating new shows
    public Show(int movieId, int hallId, String showTime, Date startDate, Date endDate) {
        this.movieId = movieId;
        this.hallId = hallId;
        this.showTime = showTime;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = "active";
    }

    // Getters and Setters
    public int getShowId() {
        return showId;
    }

    public void setShowId(int showId) {
        this.showId = showId;
    }

    public int getMovieId() {
        return movieId;
    }

    public void setMovieId(int movieId) {
        this.movieId = movieId;
    }

    public int getHallId() {
        return hallId;
    }

    public void setHallId(int hallId) {
        this.hallId = hallId;
    }

    public String getShowTime() {
        return showTime;
    }

    public void setShowTime(String showTime) {
        this.showTime = showTime;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getHallName() {
        return hallName;
    }

    public void setHallName(String hallName) {
        this.hallName = hallName;
    }
}
