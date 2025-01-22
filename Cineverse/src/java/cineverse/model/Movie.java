package cineverse.model;

public class Movie {
    private int movieId;
    private String movieName;
    private String language;
    private String content;
    private String trailerLink;
    private String imagePath;
    private String rating;
    private String status;
    private double adultTicketPrice;
    private double childTicketPrice;

    // Default constructor
    public Movie() {
    }

    // Constructor with parameters
    public Movie(int movieId, String movieName, String language, String content,
                String trailerLink, String imagePath, String rating, String status,
                double adultTicketPrice, double childTicketPrice) {
        this.movieId = movieId;
        this.movieName = movieName;
        this.language = language;
        this.content = content;
        this.trailerLink = trailerLink;
        this.imagePath = imagePath;
        this.rating = rating;
        this.status = status;
        this.adultTicketPrice = adultTicketPrice;
        this.childTicketPrice = childTicketPrice;
    }

    // Getters and Setters
    public int getMovieId() {
        return movieId;
    }

    public void setMovieId(int movieId) {
        this.movieId = movieId;
    }

    public String getMovieName() {
        return movieName;
    }

    public void setMovieName(String movieName) {
        this.movieName = movieName;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getTrailerLink() {
        return trailerLink;
    }

    public void setTrailerLink(String trailerLink) {
        this.trailerLink = trailerLink;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getRating() {
        return rating;
    }

    public void setRating(String rating) {
        this.rating = rating;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getAdultTicketPrice() {
        return adultTicketPrice;
    }

    public void setAdultTicketPrice(double adultTicketPrice) {
        this.adultTicketPrice = adultTicketPrice;
    }

    public double getChildTicketPrice() {
        return childTicketPrice;
    }

    public void setChildTicketPrice(double childTicketPrice) {
        this.childTicketPrice = childTicketPrice;
    }
}
