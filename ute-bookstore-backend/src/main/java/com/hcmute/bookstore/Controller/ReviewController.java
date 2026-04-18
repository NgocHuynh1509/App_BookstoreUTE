package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.ReviewService;
import com.hcmute.bookstore.dto.CreateReviewRequest;
import com.hcmute.bookstore.dto.CreateReviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping("/reviews")
    public CreateReviewResponse createReview(
            @RequestBody CreateReviewRequest request,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return reviewService.createReview(email, request);
    }
}