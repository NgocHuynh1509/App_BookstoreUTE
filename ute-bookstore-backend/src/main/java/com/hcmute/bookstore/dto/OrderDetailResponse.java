package com.hcmute.bookstore.dto;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public class OrderDetailResponse {
    private String id;
    private String status;
    private Date created_at;
    private BigDecimal total;
    private String address;
    private String customer_name;
    private String phone;
    private String payment_method; // <--- Thêm dòng này
    private BigDecimal shipping_fee; // <--- Thêm dòng này nhen má
    private BigDecimal voucher_discount;
    private BigDecimal points_discount;
    private List<OrderDetailItemResponse> items;
    private boolean has_return_request; // <--- THÊM BIẾN NÀY

    public OrderDetailResponse(
            String id,
            String status,
            Date created_at,
            BigDecimal total,
            String address,
            String customer_name,
            String phone,
            String payment_method, // <--- Thêm vào constructor
            BigDecimal shipping_fee,
            BigDecimal voucher_discount, // <--- Thêm vào đây
            BigDecimal points_discount,// <--- Thêm vào constructor
            List<OrderDetailItemResponse> items,
            boolean has_return_request // <--- THÊM VÀO CONSTRUCTOR
    ) {
        this.id = id;
        this.status = status;
        this.created_at = created_at;
        this.total = total;
        this.address = address;
        this.customer_name = customer_name;
        this.phone = phone;
        this.payment_method = payment_method;
        this.shipping_fee = shipping_fee;
        this.voucher_discount = voucher_discount;
        this.points_discount = points_discount;
        this.has_return_request = has_return_request; // <--- GÁN GIÁ TRỊ
        this.items = items;
    }

    public String getId() {
        return id;
    }

    public String getStatus() {
        return status;
    }

    public Date getCreated_at() {
        return created_at;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public String getAddress() {
        return address;
    }

    public String getCustomer_name() {
        return customer_name;
    }

    public String getPhone() {
        return phone;
    }

    public List<OrderDetailItemResponse> getItems() {
        return items;
    }
    public String getPayment_method() { return payment_method; }
    public BigDecimal getShipping_fee() { return shipping_fee; }
    public BigDecimal getVoucher_discount() { return voucher_discount; }
    public BigDecimal getPoints_discount() { return points_discount; }
    // ... Giữ các Getter cũ và thêm Getter mới
    public boolean isHas_return_request() { return has_return_request; }

}