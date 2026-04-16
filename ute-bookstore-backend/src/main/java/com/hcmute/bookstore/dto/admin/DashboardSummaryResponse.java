package com.hcmute.bookstore.dto.admin;

import java.math.BigDecimal;

public class DashboardSummaryResponse {

    private long totalBooks;
    private long totalOrders;
    private long totalUsers;
    private BigDecimal revenueDay;
    private BigDecimal revenueMonth;
    private BigDecimal revenueYear;
    private long pendingOrders;
    private long lowStockBooks;
    private long unreadMessages;

    public long getTotalBooks() {
        return totalBooks;
    }

    public void setTotalBooks(long totalBooks) {
        this.totalBooks = totalBooks;
    }

    public long getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(long totalOrders) {
        this.totalOrders = totalOrders;
    }

    public long getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(long totalUsers) {
        this.totalUsers = totalUsers;
    }

    public BigDecimal getRevenueDay() {
        return revenueDay;
    }

    public void setRevenueDay(BigDecimal revenueDay) {
        this.revenueDay = revenueDay;
    }

    public BigDecimal getRevenueMonth() {
        return revenueMonth;
    }

    public void setRevenueMonth(BigDecimal revenueMonth) {
        this.revenueMonth = revenueMonth;
    }

    public BigDecimal getRevenueYear() {
        return revenueYear;
    }

    public void setRevenueYear(BigDecimal revenueYear) {
        this.revenueYear = revenueYear;
    }

    public long getPendingOrders() {
        return pendingOrders;
    }

    public void setPendingOrders(long pendingOrders) {
        this.pendingOrders = pendingOrders;
    }

    public long getLowStockBooks() {
        return lowStockBooks;
    }

    public void setLowStockBooks(long lowStockBooks) {
        this.lowStockBooks = lowStockBooks;
    }

    public long getUnreadMessages() {
        return unreadMessages;
    }

    public void setUnreadMessages(long unreadMessages) {
        this.unreadMessages = unreadMessages;
    }
}

