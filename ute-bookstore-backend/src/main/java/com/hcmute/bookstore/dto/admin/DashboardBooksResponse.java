package com.hcmute.bookstore.dto.admin;

public class DashboardBooksResponse {
    private String range;
    private long totalBooks;
    private long soldBooks;
    private long stockBooks;
    private long lowStockBooks;

    public String getRange() {
        return range;
    }

    public void setRange(String range) {
        this.range = range;
    }

    public long getTotalBooks() {
        return totalBooks;
    }

    public void setTotalBooks(long totalBooks) {
        this.totalBooks = totalBooks;
    }

    public long getSoldBooks() {
        return soldBooks;
    }

    public void setSoldBooks(long soldBooks) {
        this.soldBooks = soldBooks;
    }

    public long getStockBooks() {
        return stockBooks;
    }

    public void setStockBooks(long stockBooks) {
        this.stockBooks = stockBooks;
    }

    public long getLowStockBooks() {
        return lowStockBooks;
    }

    public void setLowStockBooks(long lowStockBooks) {
        this.lowStockBooks = lowStockBooks;
    }
}

