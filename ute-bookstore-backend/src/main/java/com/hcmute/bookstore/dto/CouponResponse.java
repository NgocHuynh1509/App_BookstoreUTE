package com.hcmute.bookstore.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CouponResponse {
    private String id;
    private String code;
    private Integer discount_percent;
    private Integer discount_amount;
    private Integer min_order_value;
    private Integer max_discount;
    private LocalDateTime expiry_date;
    private Integer usage_limit;
    private Integer used_count;
}