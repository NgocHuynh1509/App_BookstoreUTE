package com.hcmute.bookstore.dto.admin;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class DashboardRevenueResponse {
    private String range;
    private BigDecimal total;
    private BigDecimal previousTotal;
    private double changePercent;
    private List<DashboardSeriesPoint> series = new ArrayList<>();

    public String getRange() {
        return range;
    }

    public void setRange(String range) {
        this.range = range;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public BigDecimal getPreviousTotal() {
        return previousTotal;
    }

    public void setPreviousTotal(BigDecimal previousTotal) {
        this.previousTotal = previousTotal;
    }

    public double getChangePercent() {
        return changePercent;
    }

    public void setChangePercent(double changePercent) {
        this.changePercent = changePercent;
    }

    public List<DashboardSeriesPoint> getSeries() {
        return series;
    }

    public void setSeries(List<DashboardSeriesPoint> series) {
        this.series = series;
    }
}

