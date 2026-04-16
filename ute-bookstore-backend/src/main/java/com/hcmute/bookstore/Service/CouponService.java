package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Coupon;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.CouponRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.dto.CouponResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CouponService {

    private final CouponRepository couponRepository;
    private final UsersRepository usersRepository;

    public List<CouponResponse> getAvailableCoupons(String userIdFromClient, String emailFromToken) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        if (user.getCustomer() == null) {
            throw new RuntimeException("Không tìm thấy thông tin khách hàng");
        }

        String customerId = user.getCustomer().getCustomerId();

        if (!customerId.equals(userIdFromClient)) {
            throw new RuntimeException("Bạn không có quyền xem coupon của tài khoản này");
        }

        LocalDateTime now = LocalDateTime.now();

        List<Coupon> privateCoupons = couponRepository
                .findByCustomer_CustomerIdAndExpiryDateAfter(customerId, now);

        List<Coupon> publicCoupons = couponRepository
                .findByCustomerIsNullAndExpiryDateAfter(now);

        List<Coupon> allCoupons = new ArrayList<>();
        allCoupons.addAll(privateCoupons);
        allCoupons.addAll(publicCoupons);

        // chống trùng code nếu có
        Map<String, Coupon> uniqueByCode = new LinkedHashMap<>();
        for (Coupon coupon : allCoupons) {
            if (coupon.getCode() == null || coupon.getCode().isBlank()) continue;
            if (!isCouponUsable(coupon)) continue;
            uniqueByCode.putIfAbsent(coupon.getCode(), coupon);
        }

        return uniqueByCode.values().stream()
                .map(this::toResponse)
                .toList();
    }

    public Coupon findValidCouponByCode(String code) {
        if (code == null || code.isBlank()) {
            throw new RuntimeException("Mã giảm giá không hợp lệ");
        }

        Coupon coupon = couponRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã giảm giá"));

        if (!isCouponUsable(coupon)) {
            throw new RuntimeException("Mã giảm giá đã hết hạn hoặc đã dùng hết");
        }

        return coupon;
    }

    private boolean isCouponUsable(Coupon coupon) {
        if (coupon == null) return false;

        if (coupon.getExpiryDate() == null || coupon.getExpiryDate().isBefore(LocalDateTime.now())) {
            return false;
        }

        Integer usedCount = coupon.getUsedCount() == null ? 0 : coupon.getUsedCount();
        Integer usageLimit = coupon.getUsageLimit();

        return usageLimit == null || usedCount < usageLimit;
    }

    private CouponResponse toResponse(Coupon coupon) {
        return new CouponResponse(
                coupon.getId(),
                coupon.getCode(),
                coupon.getDiscountPercent(),
                coupon.getDiscountAmount(),
                coupon.getMinOrderValue(),
                coupon.getMaxDiscount(),
                coupon.getExpiryDate(),
                coupon.getUsageLimit(),
                coupon.getUsedCount() == null ? 0 : coupon.getUsedCount()
        );
    }
}