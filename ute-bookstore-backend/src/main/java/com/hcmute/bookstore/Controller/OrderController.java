package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.OrderService;
import com.hcmute.bookstore.dto.OrderDetailResponse;
import com.hcmute.bookstore.dto.OrderHistoryResponse;
import com.hcmute.bookstore.dto.OrderRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping("/user/{userId}")
    public List<OrderHistoryResponse> getOrdersByUserId(
            @PathVariable String userId,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return orderService.getOrdersByUserId(userId, email);
    }

    @GetMapping("/order-detail/{orderId}")
    public OrderDetailResponse getOrderDetail(
            @PathVariable String orderId,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return orderService.getOrderDetail(orderId, email);
    }

    @PutMapping("/cancel-order/{orderId}")
    public Map<String, String> cancelOrder(
            @PathVariable String orderId,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return Map.of("message", orderService.cancelOrder(orderId, email));
    }

    @PostMapping("/create")
    public ResponseEntity<?> createOrder(
            @RequestBody OrderRequest request,
            @RequestHeader("Authorization") String token // Lấy token để kiểm tra nếu cần
    ) {
        try {
            // Kiểm tra đầu vào từ mobile
            if (request.getUser_id() == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "Thiếu ID người dùng (CustomerId)"));
            }

            // 3. Gọi service xử lý
            String orderId = orderService.createOrder(request);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("orderId", orderId);
            response.put("message", "Đặt hàng thành công");

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
}