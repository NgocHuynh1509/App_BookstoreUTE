package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.CartDetail;
import com.hcmute.bookstore.Entity.CartDetailId;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface CartDetailRepository extends JpaRepository<CartDetail, CartDetailId> {
    List<CartDetail> findByCart_CartId(String cartId);
    // Xóa các item đã mua
    @Modifying
    @Query("DELETE FROM CartDetail cd WHERE cd.cart.cartId = :cartId AND cd.book.bookId IN :bookIds")
    void deleteByCartIdAndBookIds(@Param("cartId") String cartId, @Param("bookIds") List<String> bookIds);

}