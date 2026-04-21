package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.BookDetailService;
import com.hcmute.bookstore.dto.BookDetailResponse;
import com.hcmute.bookstore.dto.ReviewResponse;
import com.hcmute.bookstore.dto.ReviewSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class BookDetailController {

    private final BookDetailService bookDetailService;

    @GetMapping("/books/{id}")
    public BookDetailResponse getBookDetail(@PathVariable("id") String id) {
        return bookDetailService.getBookDetail(id);
    }

    @GetMapping("/reviews/book/{id}")
    public List<ReviewResponse> getReviewsByBook(@PathVariable("id") String id) {
        return bookDetailService.getReviewsByBook(id);
    }

    @GetMapping("/reviews/book/{id}/summary")
    public ReviewSummaryResponse getReviewSummary(@PathVariable("id") String id) {
        return bookDetailService.getReviewSummary(id);
    }
}