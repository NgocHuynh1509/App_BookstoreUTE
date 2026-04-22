package com.hcmute.bookstore.dto.admin;

public class CategoryResponse {
    private String categoryId;
    private String categoryName;
    private int bookCount;

    public CategoryResponse() {
    }

    public CategoryResponse(String categoryId, String categoryName, int bookCount) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.bookCount = bookCount;
    }

    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getBookCount() {
        return bookCount;
    }

    public void setBookCount(int bookCount) {
        this.bookCount = bookCount;
    }
}