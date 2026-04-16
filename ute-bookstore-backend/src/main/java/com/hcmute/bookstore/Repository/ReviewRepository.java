package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, String> {

    List<Review> findByBook_BookId(String bookId);
    int countByBook_BookId(String bookId);

    Optional<Review> findByCustomer_CustomerIdAndBook_BookId(String customerId, String bookId);

}