package com.hcmute.bookstore.dto;

public class ReviewResponse {
    private String full_name;
    private Integer rating;
    private String comment;

    public ReviewResponse() {
    }

    public ReviewResponse(String full_name, Integer rating, String comment) {
        this.full_name = full_name;
        this.rating = rating;
        this.comment = comment;
    }

    public String getFull_name() { return full_name; }
    public Integer getRating() { return rating; }
    public String getComment() { return comment; }
}