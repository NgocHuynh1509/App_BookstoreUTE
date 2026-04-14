package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.BookService;
import com.hcmute.bookstore.dto.BookCardResponse;
import com.hcmute.bookstore.dto.CategoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class HomeController {

    private final BookService bookService;

    @GetMapping("/categories")
    public List<CategoryResponse> getCategories() {
        return bookService.getAllCategories();
    }

    @GetMapping("/books")
    public List<BookCardResponse> getBooks(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer limit
    ) {
        return bookService.getBooks(category, page, limit);
    }

    @GetMapping("/books/best-sellers")
    public List<BookCardResponse> getBestSellers(
            @RequestParam(defaultValue = "10") int limit
    ) {
        return bookService.getBestSellers(limit);
    }

    @GetMapping("/books/top-discount")
    public List<BookCardResponse> getTopDiscountBooks(
            @RequestParam(defaultValue = "20") int limit
    ) {
        return bookService.getTopDiscountBooks(limit);
    }

    @GetMapping("/books/{id}/similar")
    public List<BookCardResponse> getSimilarBooks(
            @PathVariable("id") String id,
            @RequestParam(defaultValue = "10") int limit
    ) {
        return bookService.getSimilarBooks(id, limit);
    }
}