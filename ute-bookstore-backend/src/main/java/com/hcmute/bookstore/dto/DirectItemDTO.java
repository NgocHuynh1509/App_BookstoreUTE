package com.hcmute.bookstore.dto;

import lombok.Data;

import java.math.BigDecimal;

// Không cần fromCart ở đây vì đây là API Mua ngay riêng biệt
@Data
public class DirectItemDTO {
    private String book_id;
    private Integer quantity; // Integer thay vì int
    private BigDecimal price; // BigDecimal thay vì double/int
}