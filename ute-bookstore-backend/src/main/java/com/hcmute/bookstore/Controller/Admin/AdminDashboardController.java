package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Service.AdminDashboardService;
import com.hcmute.bookstore.dto.admin.DashboardSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
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
}

