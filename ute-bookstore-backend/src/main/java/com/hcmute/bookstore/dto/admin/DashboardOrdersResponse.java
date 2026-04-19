package com.hcmute.bookstore.dto.admin;

import java.util.ArrayList;
import java.util.List;

public class DashboardOrdersResponse {
    private String range;
    private long totalOrders;
    private double completionRate;
    private List<DashboardStatusCountResponse> statusCounts = new ArrayList<>();

    public String getRange() {
        return range;
    }

    public void setRange(String range) {
        this.range = range;
    }

    public long getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(long totalOrders) {
        this.totalOrders = totalOrders;
    }

    public double getCompletionRate() {
        return completionRate;
    }

    public void setCompletionRate(double completionRate) {
        this.completionRate = completionRate;
    }

    public List<DashboardStatusCountResponse> getStatusCounts() {
        return statusCounts;
    }

    public void setStatusCounts(List<DashboardStatusCountResponse> statusCounts) {
        this.statusCounts = statusCounts;
    }
}

