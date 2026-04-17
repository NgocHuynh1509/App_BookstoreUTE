package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.CouponService;
import com.hcmute.bookstore.dto.CouponResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/coupons")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;

    @GetMapping("/available/{userId}")
    public List<CouponResponse> getAvailableCoupons(
            @PathVariable String userId,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return couponService.getAvailableCoupons(userId, email);
    }
}