package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Service.AdminCustomerService;
import com.hcmute.bookstore.dto.admin.AdminCustomerResponse;
import com.hcmute.bookstore.dto.admin.UpdateCustomerStatusRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/customers")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminCustomerController {

    private final AdminCustomerService adminCustomerService;

    @GetMapping
    public List<AdminCustomerResponse> getCustomers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Boolean enabled
    ) {
        return adminCustomerService.getCustomers(keyword, enabled);
    }

    @GetMapping("/{customerId}")
    public AdminCustomerResponse getCustomerDetail(@PathVariable String customerId) {
        return adminCustomerService.getCustomerDetail(customerId);
    }

    @PutMapping("/{customerId}/status")
    public Map<String, String> updateCustomerStatus(
            @PathVariable String customerId,
            @RequestBody UpdateCustomerStatusRequest request
    ) {
        adminCustomerService.updateCustomerStatus(customerId, request.getEnabled());

        Map<String, String> response = new HashMap<>();
        response.put("message", "Cập nhật trạng thái khách hàng thành công");
        return response;
    }
}