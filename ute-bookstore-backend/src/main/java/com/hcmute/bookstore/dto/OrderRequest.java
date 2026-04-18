package com.hcmute.bookstore.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.util.List;

public class OrderRequest {

    private String user_id;           // userName của entity Users
    private String shipping_address_id; // ID của địa chỉ giao hàng
    private List<CartItemDTO> items;  // Danh sách các món hàng (sách)
    private BigDecimal total_price;   // Tổng tiền tạm tính (trước giảm giá)
    private Integer discount_points;  // Số điểm thưởng khách muốn dùng
    private String discount_coupon;   // Mã coupon (code)
    private BigDecimal final_total;   // Tổng tiền cuối cùng sau khi trừ điểm/coupon
    private String payment_method;    // Phương thức thanh toán (COD, VNPAY,...)
    private String address;           // Địa chỉ dạng chuỗi (nếu cần lưu text trực tiếp)
    private boolean fromCart;
    // --- BỔ SUNG MỚI ---
    private BigDecimal shipping_fee;     // Phí vận chuyển từ App gửi lên
    private BigDecimal voucher_discount; // Số tiền được giảm từ Voucher (Ví dụ: 20000)
    private BigDecimal points_discount_amount; // Số tiền quy đổi từ điểm thưởng (Ví dụ: 10000)
    // -------------------

    // --- Constructors ---
    public OrderRequest() {
    }

    // --- Getters và Setters ---

    public String getUser_id() {
        return user_id;
    }

    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }

    public String getShipping_address_id() {
        return shipping_address_id;
    }

    public void setShipping_address_id(String shipping_address_id) {
        this.shipping_address_id = shipping_address_id;
    }

    public List<CartItemDTO> getItems() {
        return items;
    }

    public void setItems(List<CartItemDTO> items) {
        this.items = items;
    }

    public BigDecimal getTotal_price() {
        return total_price;
    }

    public void setTotal_price(BigDecimal total_price) {
        this.total_price = total_price;
    }

    public Integer getDiscount_points() {
        return discount_points;
    }

    public void setDiscount_points(Integer discount_points) {
        this.discount_points = discount_points;
    }

    public String getDiscount_coupon() {
        return discount_coupon;
    }

    public void setDiscount_coupon(String discount_coupon) {
        this.discount_coupon = discount_coupon;
    }

    public BigDecimal getFinal_total() {
        return final_total;
    }

    public void setFinal_total(BigDecimal final_total) {
        this.final_total = final_total;
    }

    public String getPayment_method() {
        return payment_method;
    }

    public void setPayment_method(String payment_method) {
        this.payment_method = payment_method;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @JsonProperty("isFromCart")
    public boolean isFromCart() {
        return fromCart;
    }

    public void setFromCart(boolean fromCart) {
        this.fromCart = fromCart;
    }
    // --- Getters và Setters cho các trường bổ sung ---

    public BigDecimal getShipping_fee() {
        return shipping_fee;
    }

    public void setShipping_fee(BigDecimal shipping_fee) {
        this.shipping_fee = shipping_fee;
    }

    public BigDecimal getVoucher_discount() {
        return voucher_discount;
    }

    public void setVoucher_discount(BigDecimal voucher_discount) {
        this.voucher_discount = voucher_discount;
    }

    public BigDecimal getPoints_discount_amount() {
        return points_discount_amount;
    }

    public void setPoints_discount_amount(BigDecimal points_discount_amount) {
        this.points_discount_amount = points_discount_amount;
    }
}