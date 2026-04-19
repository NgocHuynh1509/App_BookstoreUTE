package com.hcmute.bookstore.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MyReviewResponse {
    private String reviewId;
    private String bookId;
    private String orderId;
    private Integer rating;
    private String comment;
    private String creationDate;
    private boolean reviewed;
}