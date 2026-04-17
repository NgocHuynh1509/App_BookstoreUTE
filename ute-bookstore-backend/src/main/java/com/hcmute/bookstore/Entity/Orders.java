package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "orders")
public class Orders {

    @Id
    @Column(name = "orderId", length = 50)
    private String orderId;

    @Column(name = "paymentMethod", length = 50)
    @NotNull
    private String paymentMethod;

    @Column(name = "orderDate")
    @NotNull
    @Temporal(TemporalType.TIMESTAMP)
    private Date orderDate = new Date(); // Khớp với DEFAULT CURRENT_TIMESTAMP

    @Column(name = "totalAmount", precision = 12, scale = 0) // Cập nhật scale = 2
    @NotNull
    @DecimalMin(value = "0", inclusive = true)
    private BigDecimal totalAmount = BigDecimal.ZERO;
    // --- BỔ SUNG MỚI: GIẢM GIÁ ---
    @Column(name = "voucher_discount", precision = 12, scale = 0)
    private BigDecimal voucherDiscount = BigDecimal.ZERO; // Tiền giảm từ mã Voucher

    @Column(name = "points_discount", precision = 12, scale = 0)
    private BigDecimal pointsDiscount = BigDecimal.ZERO; // Tiền giảm từ việc đổi điểm thưởng
    // ----------------------------

    // --- BỔ SUNG MỚI ---
    @Column(name = "shipping_fee", precision = 10, scale = 2)
    private BigDecimal shippingFee = BigDecimal.valueOf(0.00);

    @Column(name = "note", length = 500)
    private String note;
    // ------------------

    @Column(name = "address", length = 100) // Thu hẹp độ dài từ 2000 xuống 100 khớp SQL
    @NotNull
    private String address;

    @Column(name = "status", length = 50)
    @NotNull
    private String status;

    // QUAN HỆ
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<OrderDetail> orderDetail_Order = new ArrayList<>();

    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Payment payment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customerId", referencedColumnName = "customerId", foreignKey = @ForeignKey(name = "FK_Order_Customer"))
    private Customers customer; // Bỏ @NotNull nếu trong DB cho phép NULL (SET NULL)

    // --- BỔ SUNG MỐI QUAN HỆ SHIPPING ADDRESS ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_address_id", referencedColumnName = "id", foreignKey = @ForeignKey(name = "fk_order_shipping"))
    private ShippingAddress shippingAddress;

    // Constructors
    public Orders() {}

    // Getter và Setter cho các trường mới
    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(BigDecimal shippingFee) {
        this.shippingFee = shippingFee;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public ShippingAddress getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(ShippingAddress shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    // Các Getter và Setter cũ (Giữ nguyên hoặc generate lại)
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public List<OrderDetail> getOrderDetail_Order() { return orderDetail_Order; }
    public void setOrderDetail_Order(List<OrderDetail> orderDetail_Order) { this.orderDetail_Order = orderDetail_Order; }
    public Customers getCustomer() { return customer; }
    public void setCustomer(Customers customer) { this.customer = customer; }
    public Payment getPayment() { return payment; }
    public void setPayment(Payment payment) { this.payment = payment; }
    // --- GETTERS VÀ SETTERS MỚI ---
    public BigDecimal getVoucherDiscount() {
        return voucherDiscount;
    }

    public void setVoucherDiscount(BigDecimal voucherDiscount) {
        this.voucherDiscount = voucherDiscount;
    }

    public BigDecimal getPointsDiscount() {
        return pointsDiscount;
    }

    public void setPointsDiscount(BigDecimal pointsDiscount) {
        this.pointsDiscount = pointsDiscount;
    }
}