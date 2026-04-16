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
    private List<OrderDetailItemResponse> items;

    public OrderDetailResponse(
            String id,
            String status,
            Date created_at,
            BigDecimal total,
            String address,
            String customer_name,
            String phone,
            List<OrderDetailItemResponse> items
    ) {
        this.id = id;
        this.status = status;
        this.created_at = created_at;
        this.total = total;
        this.address = address;
        this.customer_name = customer_name;
        this.phone = phone;
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
}