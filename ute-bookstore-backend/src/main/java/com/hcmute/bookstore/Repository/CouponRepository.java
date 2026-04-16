package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;


@Repository
public interface CouponRepository extends JpaRepository<Coupon, String> {

    // Coupon riêng của user
    List<Coupon> findByCustomer_CustomerIdAndExpiryDateAfter(String customerId, LocalDateTime now);

    // Coupon public (customer = null)
    List<Coupon> findByCustomerIsNullAndExpiryDateAfter(LocalDateTime now);

    Optional<Coupon> findByCode(String code);
}