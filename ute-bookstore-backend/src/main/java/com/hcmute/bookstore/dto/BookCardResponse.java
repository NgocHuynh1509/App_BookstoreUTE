package com.hcmute.bookstore.dto;

import java.math.BigDecimal;

public class BookCardResponse {
    private String id;
    private String title;
    private String author_name;
    private String cover_image;
    private BigDecimal price;
    private BigDecimal original_price;
    private Integer sold_quantity;
    private Double discount_percent;

    public BookCardResponse() {
    }

    public BookCardResponse(
            String id,
            String title,
            String author_name,
            String cover_image,
            BigDecimal price,
            BigDecimal original_price,
            Integer sold_quantity,
            Double discount_percent
    ) {
        this.id = id;
        this.title = title;
        this.author_name = author_name;
        this.cover_image = cover_image;
        this.price = price;
        this.original_price = original_price;
        this.sold_quantity = sold_quantity;
        this.discount_percent = discount_percent;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getAuthor_name() {
        return author_name;
    }

    public String getCover_image() {
        return cover_image;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public BigDecimal getOriginal_price() {
        return original_price;
    }

    public Integer getSold_quantity() {
        return sold_quantity;
    }

    public Double getDiscount_percent() {
        return discount_percent;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setAuthor_name(String author_name) {
        this.author_name = author_name;
    }

    public void setCover_image(String cover_image) {
        this.cover_image = cover_image;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public void setOriginal_price(BigDecimal original_price) {
        this.original_price = original_price;
    }

    public void setSold_quantity(Integer sold_quantity) {
        this.sold_quantity = sold_quantity;
    }

    public void setDiscount_percent(Double discount_percent) {
        this.discount_percent = discount_percent;
    }
}