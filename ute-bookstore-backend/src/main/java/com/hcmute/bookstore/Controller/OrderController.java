package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.OrderService;
import com.hcmute.bookstore.dto.OrderDetailResponse;
import com.hcmute.bookstore.dto.OrderHistoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

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
}