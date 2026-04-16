package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.dto.admin.AdminOrderResponse;
import com.hcmute.bookstore.dto.admin.UpdateOrderStatusRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminOrderService {

    private final OrdersRepository ordersRepository;

    public Page<AdminOrderResponse> getOrders(String status, Pageable pageable) {
        Page<Orders> page;
        if (status != null && !status.isBlank()) {
            page = ordersRepository.findByStatusIgnoreCase(status.trim(), pageable);
        } else {
            page = ordersRepository.findAll(pageable);
        }
        return page.map(this::toResponse);
    }

    public AdminOrderResponse updateStatus(String orderId, UpdateOrderStatusRequest request) {
        Orders order = ordersRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        order.setStatus(request.getStatus());
        return toResponse(ordersRepository.save(order));
    }

    private AdminOrderResponse toResponse(Orders order) {
        AdminOrderResponse response = new AdminOrderResponse();
        response.setOrderId(order.getOrderId());
        response.setStatus(order.getStatus());
        response.setOrderDate(order.getOrderDate());
        response.setTotalAmount(order.getTotalAmount());
        response.setShippingFee(order.getShippingFee());
        response.setPaymentMethod(order.getPaymentMethod());
        response.setAddress(order.getAddress());
        if (order.getCustomer() != null) {
            response.setCustomerId(order.getCustomer().getCustomerId());
            response.setCustomerEmail(order.getCustomer().getEmail());
        }
        return response;
    }
}

