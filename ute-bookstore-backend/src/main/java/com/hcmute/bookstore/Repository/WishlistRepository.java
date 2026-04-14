package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Wishlist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


@Repository
public interface WishlistRepository extends JpaRepository<Wishlist, String> {

    List<Wishlist> findByCustomer_CustomerId(String customerId);
    Optional<Wishlist> findByCustomer_CustomerIdAndBook_BookId(String customerId, String bookId);
    void deleteByCustomer_CustomerIdAndBook_BookId(String customerId, String bookId);


}