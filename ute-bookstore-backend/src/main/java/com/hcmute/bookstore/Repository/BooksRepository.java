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
    java.util.Optional<Books> findTopByBookIdStartingWithOrderByBookIdDesc(String prefix);

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

    @org.springframework.data.jpa.repository.Query(
            "select coalesce(sum(b.quantity), 0) from Books b"
    )
    Long sumStockQuantity();

    @org.springframework.data.jpa.repository.Query(
            "select c.categoryName, count(b) from Books b left join b.category c group by c.categoryName"
    )
    java.util.List<Object[]> countBooksByCategory();

    @org.springframework.data.jpa.repository.Query(
            """
            select b from Books b
            left join b.category c
            where b.isActive = true
              and b.quantity > 0
              and (
                lower(b.title) like lower(concat('%', :keyword, '%'))
                or lower(b.author) like lower(concat('%', :keyword, '%'))
                or lower(b.description) like lower(concat('%', :keyword, '%'))
                or lower(c.categoryName) like lower(concat('%', :keyword, '%'))
              )
            """
    )
    List<Books> searchForAi(@org.springframework.data.repository.query.Param("keyword") String keyword,
                            org.springframework.data.domain.Pageable pageable);

    @org.springframework.data.jpa.repository.Query(
            """
            select b from Books b
            left join b.category c
            where b.isActive = true
              and b.quantity > 0
              and lower(c.categoryName) like lower(concat('%', :categoryKeyword, '%'))
              and (
                lower(b.title) like lower(concat('%', :keyword, '%'))
                or lower(b.description) like lower(concat('%', :keyword, '%'))
                or lower(b.author) like lower(concat('%', :keyword, '%'))
              )
            order by b.soldQuantity desc
            """
    )
    List<Books> searchByCategory(
            @org.springframework.data.repository.query.Param("categoryKeyword") String categoryKeyword,
            @org.springframework.data.repository.query.Param("keyword") String keyword,
            org.springframework.data.domain.Pageable pageable
    );

    @org.springframework.data.jpa.repository.Query(
            """
            select b from Books b
            left join b.category c
            where b.isActive = true
              and b.quantity > 0
              and lower(c.categoryName) like lower(concat('%', :categoryName, '%'))
            order by b.soldQuantity desc
            """
    )
    List<Books> findByCategoryNameOrderBySoldQuantity(
            @org.springframework.data.repository.query.Param("categoryName") String categoryName,
            org.springframework.data.domain.Pageable pageable
    );
}