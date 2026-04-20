package com.hcmute.bookstore.dto.admin;

import java.util.ArrayList;
import java.util.List;

public class DashboardTopBooksResponse {

    private List<DashboardTopBookResponse> items = new ArrayList<>();

    public List<DashboardTopBookResponse> getItems() {
        return items;
    }

    public void setItems(List<DashboardTopBookResponse> items) {
        this.items = items;
    }
}

