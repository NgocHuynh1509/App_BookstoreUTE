package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Entity.Category;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.CategoryRepository;
import com.hcmute.bookstore.dto.BookCardResponse;
import com.hcmute.bookstore.dto.CategoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BooksRepository bookRepository;
    private final CategoryRepository categoryRepository;

    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAll()
                .stream()
                .map(this::toCategoryResponse)
                .toList();
    }

    public List<BookCardResponse> getBooks(String categoryId, Integer page, Integer limit) {
        List<Books> books;

        if (categoryId != null && !categoryId.isBlank()) {
            books = bookRepository.findByIsActiveTrueAndCategory_CategoryId(categoryId);
        } else {
            books = bookRepository.findByIsActiveTrue();
        }

        List<BookCardResponse> mapped = books.stream()
                .map(this::toBookCardResponse)
                .toList();

        if (page == null || limit == null) {
            return mapped;
        }

        int from = Math.max((page - 1) * limit, 0);
        int to = Math.min(from + limit, mapped.size());

        if (from >= mapped.size()) {
            return List.of();
        }

        return mapped.subList(from, to);
    }

    public List<BookCardResponse> getBestSellers(int limit) {
        return bookRepository.findByIsActiveTrueOrderBySoldQuantityDesc(PageRequest.of(0, limit))
                .stream()
                .map(this::toBookCardResponse)
                .toList();
    }

    public List<BookCardResponse> getTopDiscountBooks(int limit) {
        return bookRepository.findByIsActiveTrue()
                .stream()
                .map(this::toBookCardResponse)
                .filter(book -> book.getDiscount_percent() != null && book.getDiscount_percent() > 0)
                .sorted(Comparator.comparing(BookCardResponse::getDiscount_percent).reversed())
                .limit(limit)
                .toList();
    }

    public List<BookCardResponse> getSimilarBooks(String bookId, int limit) {
        Books currentBook = bookRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sách"));

        if (currentBook.getCategory() == null) {
            return List.of();
        }

        return bookRepository.findByIsActiveTrueAndCategory_CategoryIdAndBookIdNot(
                        currentBook.getCategory().getCategoryId(),
                        currentBook.getBookId(),
                        PageRequest.of(0, limit)
                )
                .stream()
                .map(this::toBookCardResponse)
                .toList();
    }

    private CategoryResponse toCategoryResponse(Category category) {
        return new CategoryResponse(
                category.getCategoryId(),
                category.getCategoryName()
        );
    }

    private BookCardResponse toBookCardResponse(Books book) {
        BigDecimal price = book.getPrice();
        BigDecimal originalPrice = book.getOriginalPrice();
        Double discountPercent = calculateDiscountPercent(price, originalPrice);

        return new BookCardResponse(
                book.getBookId(),
                book.getTitle(),
                book.getAuthor(),
                book.getPicture(),
                price,
                originalPrice,
                book.getSoldQuantity(),
                discountPercent
        );
    }

    private Double calculateDiscountPercent(BigDecimal price, BigDecimal originalPrice) {
        if (price == null || originalPrice == null) {
            return 0.0;
        }

        if (originalPrice.compareTo(BigDecimal.ZERO) <= 0) {
            return 0.0;
        }

        if (originalPrice.compareTo(price) <= 0) {
            return 0.0;
        }

        BigDecimal discount = originalPrice.subtract(price)
                .multiply(BigDecimal.valueOf(100))
                .divide(originalPrice, 2, RoundingMode.HALF_UP);

        return discount.doubleValue();
    }
}