package com.hcmute.bookstore.dto.admin;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public class AdminOrderDetailResponse {
    private String orderId;
    private String status;
    private Date orderDate;

    private String fullName;
    private String phone;
    private String address;

    private String paymentMethod;
    private BigDecimal totalAmount;
    private BigDecimal shippingFee;
    private BigDecimal voucherDiscount;
    private BigDecimal pointsDiscount;
    private String customerUsername;

    private List<AdminOrderDetailItemResponse> items;
    private AdminReturnRequestResponse returnRequest; // Thêm field này

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getShippingFee() { return shippingFee; }
    public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }

    public BigDecimal getVoucherDiscount() { return voucherDiscount; }
    public void setVoucherDiscount(BigDecimal voucherDiscount) { this.voucherDiscount = voucherDiscount; }

    public BigDecimal getPointsDiscount() { return pointsDiscount; }
    public void setPointsDiscount(BigDecimal pointsDiscount) { this.pointsDiscount = pointsDiscount; }

    public String getCustomerUsername() { return customerUsername; }
    public void setCustomerUsername(String customerUsername) { this.customerUsername = customerUsername; }

    public List<AdminOrderDetailItemResponse> getItems() { return items; }
    public void setItems(List<AdminOrderDetailItemResponse> items) { this.items = items; }

    public AdminReturnRequestResponse getReturnRequest() { return returnRequest; }
    public void setReturnRequest(AdminReturnRequestResponse returnRequest) { this.returnRequest = returnRequest; }
}