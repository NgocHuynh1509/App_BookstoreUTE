package com.hcmute.bookstore.dto.admin;

import java.util.ArrayList;
import java.util.List;

public class DashboardChartsResponse {
    private String range;
    private List<DashboardStatusCountResponse> orderStatus = new ArrayList<>();
    private List<DashboardStatusCountResponse> categoryBreakdown = new ArrayList<>();
    private List<DashboardSeriesPoint> revenueSeries = new ArrayList<>();
    private List<DashboardSeriesPoint> ordersSeries = new ArrayList<>();
    private List<DashboardSeriesPoint> booksSoldSeries = new ArrayList<>();

    public String getRange() {
        return range;
    }

    public void setRange(String range) {
        this.range = range;
    }

    public List<DashboardStatusCountResponse> getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(List<DashboardStatusCountResponse> orderStatus) {
        this.orderStatus = orderStatus;
    }

    public List<DashboardStatusCountResponse> getCategoryBreakdown() {
        return categoryBreakdown;
    }

    public void setCategoryBreakdown(List<DashboardStatusCountResponse> categoryBreakdown) {
        this.categoryBreakdown = categoryBreakdown;
    }

    public List<DashboardSeriesPoint> getRevenueSeries() {
        return revenueSeries;
    }

    public void setRevenueSeries(List<DashboardSeriesPoint> revenueSeries) {
        this.revenueSeries = revenueSeries;
    }

    public List<DashboardSeriesPoint> getOrdersSeries() {
        return ordersSeries;
    }

    public void setOrdersSeries(List<DashboardSeriesPoint> ordersSeries) {
        this.ordersSeries = ordersSeries;
    }

    public List<DashboardSeriesPoint> getBooksSoldSeries() {
        return booksSoldSeries;
    }

    public void setBooksSoldSeries(List<DashboardSeriesPoint> booksSoldSeries) {
        this.booksSoldSeries = booksSoldSeries;
    }
}

