
package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "wishlist",
        uniqueConstraints = {
                @UniqueConstraint(name = "uq_wishlist", columnNames = {"customerId", "bookId"})
        }
)
public class Wishlist {

    @Id
    @Column(name = "id", length = 50) // Đổi sang String và giới hạn độ dài
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "customerId",
            referencedColumnName = "customerId",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_wishlist_customer")
    )
    @NotNull
    private Customers customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "bookId",
            referencedColumnName = "bookId",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_wishlist_book")
    )
    @NotNull
    private Books book;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        // Nếu bạn muốn tự động tạo UUID khi lưu mà không cần set thủ công
        if (this.id == null) {
            this.id = java.util.UUID.randomUUID().toString();
        }
    }

    public Wishlist() {}

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Customers getCustomer() {
        return customer;
    }

    public void setCustomer(Customers customer) {
        this.customer = customer;
    }

    public Books getBook() {
        return book;
    }

    public void setBook(Books book) {
        this.book = book;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}