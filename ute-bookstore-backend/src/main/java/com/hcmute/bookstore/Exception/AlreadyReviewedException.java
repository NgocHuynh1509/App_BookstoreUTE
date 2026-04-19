package com.hcmute.bookstore.Exception;

import com.hcmute.bookstore.dto.MyReviewResponse;
import lombok.Getter;

@Getter
public class AlreadyReviewedException extends RuntimeException {
    private final MyReviewResponse review;

    public AlreadyReviewedException(String message, MyReviewResponse review) {
        super(message);
        this.review = review;
    }
}