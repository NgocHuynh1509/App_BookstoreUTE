package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "books")
public class Books {

    @Id
    @Column(name = "bookId", length = 50)
    private String bookId;

    @Column(name = "title", length = 100, nullable = false)
    @NotNull
    private String title;

    @Column(name = "author", length = 50, nullable = false)
    @NotNull
    private String author;

    @Column(name = "publisher", length = 50, nullable = false)
    @NotNull
    private String publisher;

    @Column(name = "publicationYear")
    private Integer publicationYear; // Đổi sang Integer để có thể nhận giá trị null từ DB

    @Column(name = "description", columnDefinition = "TEXT") // Khớp với kiểu TEXT trong SQL
    private String description;

    @Column(name = "price", precision = 12, scale = 2, nullable = false) // Cập nhật scale = 2
    @NotNull
    @Min(0)
    private BigDecimal price;

    // --- BỔ SUNG MỚI ---
    @Column(name = "original_price", precision = 12, scale = 2)
    @Min(0)
    private BigDecimal originalPrice;

    @Column(name = "isActive")
    private Boolean isActive = true; // Khớp với DEFAULT TRUE

    @Column(name = "soldQuantity") // Thuộc tính "đã bán" bạn yêu cầu
    @Min(0)
    private int soldQuantity = 0;
    // ------------------

    @Column(name = "quantity", nullable = false)
    @NotNull
    @Min(0)
    private int quantity;

    @Column(name = "picture", columnDefinition = "TEXT", nullable = false)
    @NotNull
    private String picture;

    @Column(name = "preview_url", length = 500)
    private String previewUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "categoryId",
            referencedColumnName = "categoryId",
            foreignKey = @ForeignKey(name = "FK_Book_Category")
    )
    private Category category;

    @OneToMany(mappedBy = "book", fetch = FetchType.LAZY)
    private List<OrderDetail> orderDetail_Book = new ArrayList<>();

    @OneToMany(mappedBy = "book", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Review> reviews = new ArrayList<>();

    @OneToMany(mappedBy = "book", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<CartDetail> cartDetails = new ArrayList<>();

    public Books() {}

    // Getters and Setters cho các trường mới
    public BigDecimal getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public int getSoldQuantity() { return soldQuantity; }
    public void setSoldQuantity(int soldQuantity) { this.soldQuantity = soldQuantity; }

    public String getPreviewUrl() { return previewUrl; }
    public void setPreviewUrl(String previewUrl) { this.previewUrl = previewUrl; }

    // Các Getters/Setters cũ
    public String getBookId() { return bookId; }
    public void setBookId(String bookId) { this.bookId = bookId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    public Integer getPublicationYear() { return publicationYear; }
    public void setPublicationYear(Integer publicationYear) { this.publicationYear = publicationYear; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getPicture() { return picture; }
    public void setPicture(String picture) { this.picture = picture; }
    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }
}