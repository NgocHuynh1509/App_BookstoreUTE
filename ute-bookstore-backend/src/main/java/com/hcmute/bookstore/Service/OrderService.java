package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.dto.OrderHistoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrdersRepository ordersRepository;
    private final UsersRepository usersRepository;

    public List<OrderHistoryResponse> getOrdersByUserId(String userIdFromClient, String emailFromToken) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        if (!customerId.equals(userIdFromClient)) {
            throw new RuntimeException("Bạn không có quyền xem đơn hàng này");
        }

        List<Orders> orders = ordersRepository.findByCustomer_CustomerIdOrderByOrderDateDesc(customerId);

        return orders.stream()
                .map(order -> new OrderHistoryResponse(
                        order.getOrderId(),
                        normalizeStatus(order.getStatus()),
                        order.getOrderDate(),
                        order.getTotalAmount()
                ))
                .toList();
    }

    private String normalizeStatus(String status) {
        if (status == null) return "pending";

        return switch (status.trim().toLowerCase()) {
            case "pending", "cho_xac_nhan", "chờ xác nhận" -> "pending";
            case "processing", "dang_xu_ly", "đang xử lý" -> "processing";
            case "shipping", "dang_giao", "đang giao" -> "shipping";
            case "completed", "hoan_thanh", "hoàn thành" -> "completed";
            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
            default -> status.toLowerCase();
        };
    }
}