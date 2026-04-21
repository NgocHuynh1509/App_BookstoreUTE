package com.hcmute.bookstore.dto;

public class ReviewSummaryResponse {
    private Double averageRating;
    private Integer reviewCount;

    public ReviewSummaryResponse() {
    }

    public ReviewSummaryResponse(Double averageRating, Integer reviewCount) {
        this.averageRating = averageRating;
        this.reviewCount = reviewCount;
    }

    public Double getAverageRating() {
        return averageRating;
    }

    public Integer getReviewCount() {
        return reviewCount;
    }
}

