package com.hcmute.bookstore.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderDirectRequest {
    private String user_id;
    private String shipping_address_id;

    // Dùng DTO item riêng hoặc dùng lại CartItemDTO nhưng đảm bảo kiểu dữ liệu chuẩn
    private List<DirectItemDTO> items;

    private BigDecimal total_price;
    private Integer discount_points; // Integer thay vì int để nhận được null/0
    private String discount_coupon;
    private BigDecimal final_total;
    private String payment_method;
    private String address;


}

