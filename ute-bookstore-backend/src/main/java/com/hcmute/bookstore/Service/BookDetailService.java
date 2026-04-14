package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Entity.Review;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.ReviewRepository;
import com.hcmute.bookstore.dto.BookDetailResponse;
import com.hcmute.bookstore.dto.ReviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookDetailService {

    private final BooksRepository bookRepository;
    private final ReviewRepository reviewRepository;

    public BookDetailResponse getBookDetail(String bookId) {
        Books book = bookRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sách"));

        int reviewsCount = reviewRepository.countByBook_BookId(bookId);

        return new BookDetailResponse(
                book.getBookId(),
                book.getTitle(),
                book.getAuthor(),
                book.getPicture(),
                book.getPrice(),
                book.getOriginalPrice(),
                book.getDescription(),
                book.getQuantity(),
                book.getCategory() != null ? book.getCategory().getCategoryName() : null,
                book.getPublisher(),
                book.getSoldQuantity(),
                reviewsCount
        );
    }

    public List<ReviewResponse> getReviewsByBook(String bookId) {
        List<Review> reviews = reviewRepository.findByBook_BookId(bookId);

        return reviews.stream()
                .map(r -> new ReviewResponse(
                        r.getCustomer() != null ? r.getCustomer().getFullName() : "Ẩn danh",
                        r.getRating(),
                        r.getComment()
                ))
                .toList();
    }
}