package com.hcmute.bookstore.dto;

// Trong package com.hcmute.bookstore.dto
public class AddToCartRequest {
    private String bookId;
    private int quantity;

    // Getters and Setters
    public String getBookId() { return bookId; }
    public void setBookId(String bookId) { this.bookId = bookId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}
