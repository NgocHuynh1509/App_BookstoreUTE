package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.OrderService;
import com.hcmute.bookstore.dto.OrderHistoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
}