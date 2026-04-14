package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.CartDetail;
import com.hcmute.bookstore.Entity.CartDetailId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface CartDetailRepository extends JpaRepository<CartDetail, CartDetailId> {
    List<CartDetail> findByCart_CartId(String cartId);
}