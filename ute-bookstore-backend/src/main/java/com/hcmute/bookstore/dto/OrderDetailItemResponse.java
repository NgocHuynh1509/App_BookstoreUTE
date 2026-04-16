package com.hcmute.bookstore.dto;

import java.math.BigDecimal;

public class OrderDetailItemResponse {
    private String book_id;
    private String title;
    private int quantity;
    private BigDecimal price;

    public OrderDetailItemResponse(String book_id, String title, int quantity, BigDecimal price) {
        this.book_id = book_id;
        this.title = title;
        this.quantity = quantity;
        this.price = price;
    }

    public String getBook_id() {
        return book_id;
    }

    public String getTitle() {
        return title;
    }

    public int getQuantity() {
        return quantity;
    }

    public BigDecimal getPrice() {
        return price;
    }
}