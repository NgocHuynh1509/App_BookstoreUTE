package com.hcmute.bookstore.dto;

import lombok.*;
import java.math.BigDecimal;

@Data // Tự động tạo Getter, Setter, toString, equals, hashCode
@NoArgsConstructor // Tạo constructor không tham số
@AllArgsConstructor // Tạo constructor đầy đủ tham số
public class CartItemDTO {
    private String id;
    private String book_id;
    private String title;
    private BigDecimal price;
    private int quantity;
    private String cover_image;
    private int stock;
}