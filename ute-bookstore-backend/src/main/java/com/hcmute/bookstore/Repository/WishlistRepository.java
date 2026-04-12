package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Wishlist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface WishlistRepository extends JpaRepository<Wishlist, String> {


}