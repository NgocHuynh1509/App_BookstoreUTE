package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.*;
import com.hcmute.bookstore.Repository.OrderDetailRepository;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.UserFcmTokenRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.dto.admin.AdminOrderDetailItemResponse;
import com.hcmute.bookstore.dto.admin.AdminOrderDetailResponse;
import com.hcmute.bookstore.dto.admin.AdminOrderResponse;
import com.hcmute.bookstore.dto.admin.UpdateOrderStatusRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminOrderService {

    private final OrdersRepository ordersRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final UsersRepository usersRepository;
    private final NotificationService notificationService;
    private final UserFcmTokenRepository tokenRepo;
    private final ExpoPushService expoPushService;

    public Page<AdminOrderResponse> getOrders(String status, Pageable pageable) {
        Page<Orders> page;
        if (status != null && !status.isBlank()) {
            page = ordersRepository.findByStatusIgnoreCase(status.trim(), pageable);
        } else {
            page = ordersRepository.findAll(pageable);
        }
        return page.map(this::toResponse);
    }

//    public AdminOrderResponse updateStatus(String orderId, UpdateOrderStatusRequest request) {
//        Orders order = ordersRepository.findById(orderId)
//                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));
//
//        order.setStatus(request.getStatus());
//        return toResponse(ordersRepository.save(order));
//    }

    public AdminOrderResponse updateStatus(String orderId, UpdateOrderStatusRequest request) {
        Orders order = ordersRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        String oldStatus = order.getStatus();
        String newStatus = request.getStatus();

        order.setStatus(newStatus);
        Orders savedOrder = ordersRepository.save(order);

        Users user = usersRepository
                .findByCustomer_CustomerId(order.getCustomer().getCustomerId())
                .orElse(null);

        if (user != null && newStatus != null && !newStatus.equalsIgnoreCase(oldStatus)) {
            String title = null;
            String body = null;
            NotificationType type = null;

            switch (newStatus.trim().toUpperCase()) {
                case "CONFIRMED":
                    title = "Đơn hàng đã được xác nhận";
                    body = "Đơn hàng #" + order.getOrderId() + " đã được xác nhận.";
                    type = NotificationType.ORDER_CONFIRMED;
                    break;

                case "SHIPPING":
                    title = "Đơn hàng đang được giao";
                    body = "Đơn hàng #" + order.getOrderId() + " đang trên đường giao.";
                    type = NotificationType.ORDER_SHIPPING;
                    break;

                case "COMPLETED":
                    title = "Đơn hàng đã hoàn thành";
                    body = "Đơn hàng #" + order.getOrderId() + " đã hoàn thành.";
                    type = NotificationType.ORDER_COMPLETED;
                    break;

                case "CANCELLED":
                    title = "Đơn hàng đã bị hủy";
                    body = "Đơn hàng #" + order.getOrderId() + " đã bị hủy.";
                    type = NotificationType.ORDER_CANCELLED;
                    break;

                case "RETURNED":
                    title = "Đơn hàng hoàn trả";
                    body = "Đơn hàng #" + order.getOrderId() + " đã được hoàn trả.";
                    type = NotificationType.ORDER_RETURNED;
                    break;
            }

            if (title != null) {
                notificationService.createNotification(
                        user,
                        title,
                        body,
                        type,
                        order.getOrderId(),
                        "CUSTOMER"
                );

                List<UserFcmToken> tokens = tokenRepo.findByUser(user);
                for (UserFcmToken t : tokens) {
                    expoPushService.sendPush(
                            t.getToken(),
                            title,
                            body,
                            order.getOrderId()
                    );
                }
            }
        }

        return toResponse(savedOrder);
    }

    private AdminOrderResponse toResponse(Orders order) {
        AdminOrderResponse response = new AdminOrderResponse();

        response.setOrderId(order.getOrderId());
        response.setStatus(order.getStatus());
        response.setOrderDate(order.getOrderDate());
        response.setTotalAmount(order.getTotalAmount());
        response.setShippingFee(order.getShippingFee());
        response.setPaymentMethod(order.getPaymentMethod());

        if (order.getShippingAddress() != null) {
            var sa = order.getShippingAddress();

            String fullAddress = sa.getSpecificAddress()
                    + (sa.getWard() != null ? ", " + sa.getWard() : "")
                    + ", " + sa.getDistrict()
                    + ", " + sa.getProvince();

            response.setAddress(fullAddress);

            response.setFullName(sa.getRecipientName());

            response.setPhone(sa.getPhoneNumber());

        } else {
            response.setAddress(order.getAddress());

            if (order.getCustomer() != null) {
                response.setFullName(order.getCustomer().getFullName());
                response.setPhone(order.getCustomer().getPhone());
            }
        }

        // giữ email nếu cần
        if (order.getCustomer() != null) {
            response.setCustomerId(order.getCustomer().getCustomerId());
            response.setCustomerEmail(order.getCustomer().getEmail());
        }

        return response;
    }


    public AdminOrderDetailResponse getOrderDetail(String orderId) {
        Orders order = ordersRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        List<OrderDetail> orderDetails = orderDetailRepository.findByOrder_OrderId(orderId);

        List<AdminOrderDetailItemResponse> items = orderDetails.stream().map(detail -> {
            AdminOrderDetailItemResponse item = new AdminOrderDetailItemResponse();
            item.setBookId(detail.getBook().getBookId());
            item.setTitle(detail.getBook().getTitle());
            item.setImage(detail.getBook().getPicture());
            item.setQuantity(detail.getQuantity());
            item.setUnitPrice(detail.getUnitPrice());
            return item;
        }).toList();

        AdminOrderDetailResponse response = new AdminOrderDetailResponse();
        response.setOrderId(order.getOrderId());
        response.setStatus(order.getStatus());
        response.setOrderDate(order.getOrderDate());
        response.setPaymentMethod(order.getPaymentMethod());
        response.setTotalAmount(order.getTotalAmount());
        response.setShippingFee(order.getShippingFee() != null ? order.getShippingFee() : BigDecimal.ZERO);
        response.setVoucherDiscount(order.getVoucherDiscount() != null ? order.getVoucherDiscount() : BigDecimal.ZERO);
        response.setPointsDiscount(order.getPointsDiscount() != null ? order.getPointsDiscount() : BigDecimal.ZERO);
        response.setItems(items);

        if (order.getShippingAddress() != null) {
            var sa = order.getShippingAddress();
            String fullAddress = sa.getSpecificAddress()
                    + (sa.getWard() != null ? ", " + sa.getWard() : "")
                    + ", " + sa.getDistrict()
                    + ", " + sa.getProvince();

            response.setFullName(sa.getRecipientName());
            response.setPhone(sa.getPhoneNumber());
            response.setAddress(fullAddress);
        } else {
            response.setAddress(order.getAddress());
            if (order.getCustomer() != null) {
                response.setFullName(order.getCustomer().getFullName());
                response.setPhone(order.getCustomer().getPhone());
            }
        }

        return response;
    }
}

