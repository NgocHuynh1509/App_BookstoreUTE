package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.BookRecommendService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/recommend")
@RequiredArgsConstructor
public class RecommendController {

    private final BookRecommendService bookRecommendService;

    @GetMapping("/{bookId}")
    public ResponseEntity<String> recommend(@PathVariable String bookId) {
        String result = bookRecommendService.recommendBooks(bookId);
        return ResponseEntity.ok(result);
    }
}