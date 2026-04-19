package com.hcmute.bookstore.dto.admin;

public class DashboardStatusCountResponse {
    private String label;
    private long count;

    public DashboardStatusCountResponse() {
    }

    public DashboardStatusCountResponse(String label, long count) {
        this.label = label;
        this.count = count;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public long getCount() {
        return count;
    }

    public void setCount(long count) {
        this.count = count;
    }
}

