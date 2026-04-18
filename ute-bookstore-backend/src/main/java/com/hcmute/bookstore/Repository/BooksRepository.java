package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Books;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BooksRepository extends JpaRepository<Books, String> {

    List<Books> findByIsActiveTrue();

    List<Books> findByIsActiveTrueAndCategory_CategoryId(String categoryId);

    List<Books> findByIsActiveTrueOrderBySoldQuantityDesc(Pageable pageable);

    List<Books> findByIsActiveTrueAndCategory_CategoryIdAndBookIdNot(String categoryId, String bookId, Pageable pageable);

    Page<Books> findByTitleContainingIgnoreCase(String title, Pageable pageable);

    Page<Books> findByCategory_CategoryId(String categoryId, Pageable pageable);

    Page<Books> findByTitleContainingIgnoreCaseAndCategory_CategoryId(
            String title,
            String categoryId,
            Pageable pageable
    );

    long countByQuantityLessThanEqual(int quantity);
}