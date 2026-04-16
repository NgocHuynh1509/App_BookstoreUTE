package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Service.AdminOrderService;
import com.hcmute.bookstore.dto.admin.AdminOrderResponse;
import com.hcmute.bookstore.dto.admin.UpdateOrderStatusRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping({"/admin/orders", "/orders"})
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminOrderController {

    private final AdminOrderService adminOrderService;

    @GetMapping
    public Page<AdminOrderResponse> getOrders(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return adminOrderService.getOrders(
                status,
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "orderDate"))
        );
    }

    @PutMapping("/{orderId}/status")
    public AdminOrderResponse updateStatus(
            @PathVariable String orderId,
            @Valid @RequestBody UpdateOrderStatusRequest request
    ) {
        return adminOrderService.updateStatus(orderId, request);
    }
}
