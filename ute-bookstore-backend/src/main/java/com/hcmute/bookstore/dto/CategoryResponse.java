package com.hcmute.bookstore.dto;

public class CategoryResponse {
    private String id;
    private String name;

    public CategoryResponse() {
    }

    public CategoryResponse(String id, String name) {
        this.id = id;
        this.name = name;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}