package com.hcmute.bookstore.dto;

import java.math.BigDecimal;
import java.util.Date;

public class OrderHistoryResponse {
    private String id;
    private String status;
    private Date created_at;
    private BigDecimal total;
    private String returnRequestStatus;

    public OrderHistoryResponse(String id, String status, Date created_at, BigDecimal total, String returnRequestStatus) {
        this.id = id;
        this.status = status;
        this.created_at = created_at;
        this.total = total;
        this.returnRequestStatus = returnRequestStatus;
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

    public String getReturnRequestStatus() {
        return returnRequestStatus;
    }
}