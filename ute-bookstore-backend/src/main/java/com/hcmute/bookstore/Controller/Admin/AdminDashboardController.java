package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Service.AdminDashboardService;
import com.hcmute.bookstore.dto.admin.DashboardBooksResponse;
import com.hcmute.bookstore.dto.admin.DashboardChartsResponse;
import com.hcmute.bookstore.dto.admin.DashboardOrdersResponse;
import com.hcmute.bookstore.dto.admin.DashboardRevenueResponse;
import com.hcmute.bookstore.dto.admin.DashboardSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/dashboard")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    @GetMapping("/summary")
    public DashboardSummaryResponse getSummary() {
        return adminDashboardService.getSummary();
    }

    @GetMapping("/revenue")
    public DashboardRevenueResponse getRevenue(@RequestParam(defaultValue = "month") String range) {
        return adminDashboardService.getRevenue(range);
    }

    @GetMapping("/books")
    public DashboardBooksResponse getBooks(@RequestParam(defaultValue = "month") String range) {
        return adminDashboardService.getBooks(range);
    }

    @GetMapping("/orders")
    public DashboardOrdersResponse getOrders(@RequestParam(defaultValue = "month") String range) {
        return adminDashboardService.getOrders(range);
    }

    @GetMapping("/charts")
    public DashboardChartsResponse getCharts(@RequestParam(defaultValue = "month") String range) {
        return adminDashboardService.getCharts(range);
    }
}

