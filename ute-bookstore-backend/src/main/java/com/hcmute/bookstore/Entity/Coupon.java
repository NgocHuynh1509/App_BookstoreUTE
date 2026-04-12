package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.time.LocalDateTime;

@Entity
@Table(name = "coupons")
public class Coupon {

    @Id
    @Column(name = "id", length = 50) // Đổi sang String
    private String id;

    @Column(name = "code", unique = true, length = 50)
    private String code;

    @Column(name = "discount_percent")
    @Min(0)
    @Max(100)
    private Integer discountPercent;

    @Column(name = "discount_amount")
    @Min(0)
    private Integer discountAmount;

    @Column(name = "min_order_value")
    @Min(0)
    private Integer minOrderValue;

    @Column(name = "max_discount")
    @Min(0)
    private Integer maxDiscount;

    @Column(name = "expiry_date")
    private LocalDateTime expiryDate;

    @Column(name = "usage_limit")
    @Min(0)
    private Integer usageLimit;

    @Column(name = "used_count")
    private Integer usedCount = 0; // Khớp với DEFAULT 0

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "customerId",
            referencedColumnName = "customerId",
            foreignKey = @ForeignKey(name = "fk_coupon_customer")
    )
    private Customers customer; // Để null được vì SQL cho phép NULL

    public Coupon() {}

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public Integer getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(Integer discountPercent) { this.discountPercent = discountPercent; }

    public Integer getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(Integer discountAmount) { this.discountAmount = discountAmount; }

    public Integer getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(Integer minOrderValue) { this.minOrderValue = minOrderValue; }

    public Integer getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(Integer maxDiscount) { this.maxDiscount = maxDiscount; }

    public LocalDateTime getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDateTime expiryDate) { this.expiryDate = expiryDate; }

    public Integer getUsageLimit() { return usageLimit; }
    public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }

    public Integer getUsedCount() { return usedCount; }
    public void setUsedCount(Integer usedCount) { this.usedCount = usedCount; }

    public Customers getCustomer() { return customer; }
    public void setCustomer(Customers customer) { this.customer = customer; }
}