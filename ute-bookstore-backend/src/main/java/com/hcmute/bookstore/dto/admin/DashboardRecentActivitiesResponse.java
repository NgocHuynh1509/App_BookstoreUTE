package com.hcmute.bookstore.dto.admin;

import java.util.ArrayList;
import java.util.List;

public class DashboardRecentActivitiesResponse {

    private List<DashboardRecentActivityResponse> items = new ArrayList<>();

    public List<DashboardRecentActivityResponse> getItems() {
        return items;
    }

    public void setItems(List<DashboardRecentActivityResponse> items) {
        this.items = items;
    }
}

