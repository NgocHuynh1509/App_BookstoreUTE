package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Books;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import org.springframework.data.domain.Pageable;
import java.util.List;

@Repository
public interface BooksRepository extends JpaRepository<Books, String> {

    List<Books> findByIsActiveTrue();

    List<Books> findByIsActiveTrueAndCategory_CategoryId(String categoryId);

    List<Books> findByIsActiveTrueOrderBySoldQuantityDesc(Pageable pageable);

    List<Books> findByIsActiveTrueAndCategory_CategoryIdAndBookIdNot(String categoryId, String bookId, Pageable pageable);
}