package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Entity.Category;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.CategoryRepository;
import com.hcmute.bookstore.Repository.ReviewRepository;
import com.hcmute.bookstore.dto.admin.AdminBookRequest;
import com.hcmute.bookstore.dto.admin.AdminBookResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminProductService {

    private final BooksRepository booksRepository;
    private final CategoryRepository categoryRepository;
    private final ReviewRepository reviewRepository;

    public Page<AdminBookResponse> getBooks(String search, String categoryId, Pageable pageable) {
        Page<Books> page;
        if (search != null && !search.isBlank() && categoryId != null && !categoryId.isBlank()) {
            page = booksRepository.findByTitleContainingIgnoreCaseAndCategory_CategoryId(
                    search.trim(),
                    categoryId.trim(),
                    pageable
            );
        } else if (search != null && !search.isBlank()) {
            page = booksRepository.findByTitleContainingIgnoreCase(search.trim(), pageable);
        } else if (categoryId != null && !categoryId.isBlank()) {
            page = booksRepository.findByCategory_CategoryId(categoryId.trim(), pageable);
        } else {
            page = booksRepository.findAll(pageable);
        }

        return page.map(this::toResponse);
    }

    public AdminBookResponse create(AdminBookRequest request) {
        if (booksRepository.existsById(request.getBookId())) {
            throw new RuntimeException("BookId đã tồn tại");
        }

        Books book = new Books();
        book.setBookId(request.getBookId());
        applyRequest(book, request);

        return toResponse(booksRepository.save(book));
    }

    public AdminBookResponse update(String bookId, AdminBookRequest request) {
        Books book = booksRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sách"));

        applyRequest(book, request);
        return toResponse(booksRepository.save(book));
    }

    public void delete(String bookId) {
        if (!booksRepository.existsById(bookId)) {
            throw new RuntimeException("Không tìm thấy sách");
        }
        booksRepository.deleteById(bookId);
    }

    private void applyRequest(Books book, AdminBookRequest request) {
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thể loại"));

        book.setTitle(request.getTitle());
        book.setAuthor(request.getAuthor());
        book.setPublisher(request.getPublisher());
        book.setPublicationYear(request.getPublicationYear());
        book.setDescription(request.getDescription());
        book.setPrice(request.getPrice());
        book.setOriginalPrice(request.getOriginalPrice());
        book.setQuantity(request.getQuantity());
        book.setPicture(request.getPicture());
        book.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);
        book.setCategory(category);
    }

    private AdminBookResponse toResponse(Books book) {
        AdminBookResponse response = new AdminBookResponse();
        response.setBookId(book.getBookId());
        response.setTitle(book.getTitle());
        response.setAuthor(book.getAuthor());
        response.setPublisher(book.getPublisher());
        response.setPublicationYear(book.getPublicationYear());
        response.setDescription(book.getDescription());
        response.setPrice(book.getPrice());
        response.setOriginalPrice(book.getOriginalPrice());
        response.setQuantity(book.getQuantity());
        response.setSoldQuantity(book.getSoldQuantity());
        response.setIsActive(book.getIsActive());
        response.setPicture(book.getPicture());
        if (book.getCategory() != null) {
            response.setCategoryId(book.getCategory().getCategoryId());
            response.setCategoryName(book.getCategory().getCategoryName());
        }
        final Double averageRating = reviewRepository.findAverageRatingByBookId(book.getBookId());
        final int reviewCount = reviewRepository.countByBook_BookId(book.getBookId());
        response.setAverageRating(averageRating != null ? averageRating : 0.0);
        response.setReviewCount(reviewCount);
        return response;
    }
}
