package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.Date;

@Entity
@Table(name = "payment")
public class Payment {

    @Id
    @Column(name = "paymentId", length = 50)
    private String paymentId;

    @Column(name = "paymentTime", nullable = false)
    @NotNull
    private Date paymentTime;

    // --- BỔ SUNG MỚI ĐỂ KHỚP VỚI SQL ---
    @Column(name = "amount", precision = 12, scale = 2)
    private BigDecimal amount;

    @Column(name = "method", length = 50)
    private String method;

    @Column(name = "status", length = 50)
    private String status;
    // ---------------------------------

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "orderId",
            nullable = false,
            unique = true, // Khớp với UNIQUE trong SQL để đảm bảo quan hệ 1-1 thực sự
            referencedColumnName = "orderId",
            foreignKey = @ForeignKey(name = "FK_Payment_Order")
    )
    private Orders order;

    public Payment() {}

    // Constructor đầy đủ (tùy chọn)
    public Payment(String paymentId, Date paymentTime, BigDecimal amount, String method, String status, Orders order) {
        this.paymentId = paymentId;
        this.paymentTime = paymentTime;
        this.amount = amount;
        this.method = method;
        this.status = status;
        this.order = order;
    }

    // Getters and Setters
    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }

    public Date getPaymentTime() {
        return paymentTime;
    }

    public void setPaymentTime(Date paymentTime) {
        this.paymentTime = paymentTime;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Orders getOrder() {
        return order;
    }

    public void setOrder(Orders order) {
        this.order = order;
    }
}