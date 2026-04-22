package com.hcmute.bookstore.dto;

public class ReviewResponse {
    private String full_name;
    private Integer rating;
    private String comment;
    private String creation_date;

    public ReviewResponse() {
    }

    public ReviewResponse(String full_name, Integer rating, String comment, String creation_date) {
        this.full_name = full_name;
        this.rating = rating;
        this.comment = comment;
        this.creation_date = creation_date;
    }

    public String getFull_name() { return full_name; }
    public Integer getRating() { return rating; }
    public String getComment() { return comment; }
    public String getCreation_date() { return creation_date; }
}