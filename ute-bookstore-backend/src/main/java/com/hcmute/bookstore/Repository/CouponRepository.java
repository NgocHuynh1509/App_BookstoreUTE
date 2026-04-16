package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;


@Repository
public interface CouponRepository extends JpaRepository<Coupon, String> {
    // Thêm dòng này để tìm kiếm Coupon theo mã code
    Optional<Coupon> findByCode(String code);


}