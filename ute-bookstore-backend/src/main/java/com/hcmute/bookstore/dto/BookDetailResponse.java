package com.hcmute.bookstore.dto;

import java.math.BigDecimal;

public class BookDetailResponse {
    private String id;
    private String title;
    private String author_name;
    private String cover_image;
    private BigDecimal price;
    private BigDecimal original_price;
    private String description;
    private Integer stock;
    private String category_name;
    private String publisher_name;
    private Integer buyersCount;
    private Integer reviewsCount;
    private String preview_url;

    public BookDetailResponse() {
    }

    public BookDetailResponse(
            String id,
            String title,
            String author_name,
            String cover_image,
            BigDecimal price,
            BigDecimal original_price,
            String description,
            Integer stock,
            String category_name,
            String publisher_name,
            Integer buyersCount,
            Integer reviewsCount,
            String preview_url
    ) {
        this.id = id;
        this.title = title;
        this.author_name = author_name;
        this.cover_image = cover_image;
        this.price = price;
        this.original_price = original_price;
        this.description = description;
        this.stock = stock;
        this.category_name = category_name;
        this.publisher_name = publisher_name;
        this.buyersCount = buyersCount;
        this.reviewsCount = reviewsCount;
        this.preview_url = preview_url;
    }

    public String getId() { return id; }
    public String getTitle() { return title; }
    public String getAuthor_name() { return author_name; }
    public String getCover_image() { return cover_image; }
    public BigDecimal getPrice() { return price; }
    public BigDecimal getOriginal_price() { return original_price; }
    public String getDescription() { return description; }
    public Integer getStock() { return stock; }
    public String getCategory_name() { return category_name; }
    public String getPublisher_name() { return publisher_name; }
    public Integer getBuyersCount() { return buyersCount; }
    public Integer getReviewsCount() { return reviewsCount; }
    public String getPreview_url() { return preview_url; }
}