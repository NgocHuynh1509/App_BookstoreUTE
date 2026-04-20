package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Service.AdminDashboardService.PredictionJobResult;
import com.hcmute.bookstore.Service.AdminDashboardService;
import com.hcmute.bookstore.dto.admin.DashboardChartsResponse;
import com.hcmute.bookstore.dto.admin.DashboardBooksResponse;
import com.hcmute.bookstore.dto.admin.DashboardOrdersResponse;
import com.hcmute.bookstore.dto.admin.DashboardRecentActivitiesResponse;
import com.hcmute.bookstore.dto.admin.DashboardRevenuePredictionResponse;
import com.hcmute.bookstore.dto.admin.DashboardRevenueResponse;
import com.hcmute.bookstore.dto.admin.DashboardSummaryResponse;
import com.hcmute.bookstore.dto.admin.DashboardTopBooksResponse;
import com.hcmute.bookstore.dto.admin.PredictionJobResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({"/admin/dashboard", "/api/admin/dashboard"})
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    @GetMapping({"/summary", "/overview"})
    public DashboardSummaryResponse getSummary() {
        return adminDashboardService.getSummary();
    }

    @GetMapping({"/revenue", "/revenue-chart"})
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

    @GetMapping({"/revenue-prediction", "/prediction"})
    public DashboardRevenuePredictionResponse getRevenuePrediction() {
        return adminDashboardService.getRevenuePrediction();
    }

    @PostMapping({"/revenue-prediction/jobs", "/prediction/jobs"})
    public PredictionJobResponse createRevenuePredictionJob() {
        String jobId = adminDashboardService.startPredictionJob();
        return PredictionJobResponse.pending(jobId);
    }

    @GetMapping({"/revenue-prediction/jobs/{jobId}", "/prediction/jobs/{jobId}"})
    public PredictionJobResponse getRevenuePredictionJob(@PathVariable String jobId) {
        PredictionJobResult result = adminDashboardService.getPredictionJob(jobId);
        if ("NOT_FOUND".equals(result.getStatus())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, result.getMessage());
        }
        if ("DONE".equals(result.getStatus())) {
            return PredictionJobResponse.done(jobId, result.getPrediction());
        }
        if ("FAILED".equals(result.getStatus())) {
            return PredictionJobResponse.failed(jobId, result.getMessage());
        }
        return PredictionJobResponse.pending(jobId);
    }

    @GetMapping("/top-books")
    public DashboardTopBooksResponse getTopBooks(
            @RequestParam(defaultValue = "month") String range,
            @RequestParam(defaultValue = "5") int limit
    ) {
        return adminDashboardService.getTopBooks(range, limit);
    }

    @GetMapping("/recent-activities")
    public DashboardRecentActivitiesResponse getRecentActivities(
            @RequestParam(defaultValue = "8") int limit
    ) {
        return adminDashboardService.getRecentActivities(limit);
    }
}
