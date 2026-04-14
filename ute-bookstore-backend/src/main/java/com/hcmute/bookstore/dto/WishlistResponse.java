package com.hcmute.bookstore.dto;

public class WishlistResponse {
    private String book_id;

    public WishlistResponse() {
    }

    public WishlistResponse(String book_id) {
        this.book_id = book_id;
    }

    public String getBook_id() {
        return book_id;
    }
}