package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.CartDetail;
import com.hcmute.bookstore.Entity.CartDetailId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface CartDetailRepository extends JpaRepository<CartDetail, CartDetailId> {
}