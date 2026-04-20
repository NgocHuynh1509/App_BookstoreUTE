package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Service.AdminCouponService;
import com.hcmute.bookstore.dto.admin.AdminCouponRequest;
import com.hcmute.bookstore.dto.admin.AdminCouponResponse;
import com.hcmute.bookstore.dto.admin.AdminCouponStatsResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping({"/admin/coupons", "/api/admin/coupons"})
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminCouponController {

    private final AdminCouponService adminCouponService;

    @GetMapping("/all")
    public List<AdminCouponResponse> getAll(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String scope
    ) {
        return adminCouponService.getCoupons(search, status, scope);
    }

    @GetMapping("/{id}")
    public AdminCouponResponse getById(@PathVariable String id) {
        return adminCouponService.getCoupon(id);
    }

    @PostMapping("/create")
    public AdminCouponResponse create(@RequestBody AdminCouponRequest request) {
        return adminCouponService.create(request);
    }

    @PutMapping("/update/{id}")
    public AdminCouponResponse update(
            @PathVariable String id,
            @RequestBody AdminCouponRequest request
    ) {
        return adminCouponService.update(id, request);
    }

    @DeleteMapping("/delete/{id}")
    public void delete(@PathVariable String id) {
        adminCouponService.delete(id);
    }

    @GetMapping("/search")
    public List<AdminCouponResponse> search(@RequestParam String code) {
        return adminCouponService.getCoupons(code, null, null);
    }

    @GetMapping("/filter")
    public List<AdminCouponResponse> filter(@RequestParam String status) {
        return adminCouponService.getCoupons(null, status, null);
    }

    @GetMapping("/stats")
    public AdminCouponStatsResponse stats() {
        return adminCouponService.getStats();
    }
}

