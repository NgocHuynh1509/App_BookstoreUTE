package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Entity
@Table(name = "point_transactions")
public class PointTransaction {

    @Id
    @Column(name = "id", length = 50) // Đổi sang String
    private String id;

    @Column(name = "reward_points", nullable = false)
    @NotNull
    private Integer rewardPoints;

    @Column(name = "type", length = 50)
    private String type;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "customerId",
            referencedColumnName = "customerId",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_point_tx_customer")
    )
    @NotNull
    private Customers customer;

    // Tự động gán thời gian hiện tại khi tạo mới (tương ứng DEFAULT CURRENT_TIMESTAMP)
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public PointTransaction() {}

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Integer getRewardPoints() {
        return rewardPoints;
    }

    public void setRewardPoints(Integer rewardPoints) {
        this.rewardPoints = rewardPoints;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Customers getCustomer() {
        return customer;
    }

    public void setCustomer(Customers customer) {
        this.customer = customer;
    }
}