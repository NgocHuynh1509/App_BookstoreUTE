package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.OrderDetail;
import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.OrderDetailRepository;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.dto.OrderDetailItemResponse;
import com.hcmute.bookstore.dto.OrderDetailResponse;
import com.hcmute.bookstore.dto.OrderHistoryResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrdersRepository ordersRepository;
    private final UsersRepository usersRepository;
    private final OrderDetailRepository orderDetailRepository;

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
                        normalizeHistoryStatus(order.getStatus()),
                        order.getOrderDate(),
                        order.getTotalAmount()
                ))
                .toList();
    }

//    private String normalizeStatus(String status) {
//        if (status == null) return "pending";
//
//        return switch (status.trim().toLowerCase()) {
//            case "pending", "cho_xac_nhan", "chờ xác nhận" -> "pending";
//            case "processing", "dang_xu_ly", "đang xử lý" -> "processing";
//            case "shipping", "dang_giao", "đang giao" -> "shipping";
//            case "completed", "hoan_thanh", "hoàn thành" -> "completed";
//            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
//            default -> status.toLowerCase();
//        };
//    }

    private String normalizeHistoryStatus(String status) {
        if (status == null) return "pending";

        return switch (status.trim().toLowerCase()) {
            case "pending", "cho_xac_nhan", "chờ xác nhận" -> "pending";
            case "processing", "dang_xu_ly", "đang xử lý", "confirmed", "da_xac_nhan", "đã xác nhận", "preparing", "dang_chuan_bi", "đang chuẩn bị" -> "processing";
            case "shipping", "dang_giao", "đang giao", "delivery" -> "shipping";
            case "completed", "hoan_thanh", "hoàn thành", "success", "giao_thanh_cong" -> "completed";
            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
            default -> status.toLowerCase();
        };
    }

    private String normalizeDetailStatus(String status) {
        if (status == null) return "pending";

        return switch (status.trim().toLowerCase()) {
            case "pending", "cho_xac_nhan", "chờ xác nhận" -> "pending";
            case "confirmed", "da_xac_nhan", "đã xác nhận" -> "confirmed";
            case "preparing", "dang_chuan_bi", "đang chuẩn bị", "processing", "dang_xu_ly", "đang xử lý" -> "preparing";
            case "delivery", "shipping", "dang_giao", "đang giao" -> "delivery";
            case "success", "completed", "hoan_thanh", "hoàn thành", "giao_thanh_cong" -> "success";
            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
            default -> "pending";
        };
    }

    public OrderDetailResponse getOrderDetail(String orderId, String emailFromToken) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        Orders order = ordersRepository.findByOrderIdAndCustomer_CustomerId(orderId, customerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        List<OrderDetail> orderDetails = orderDetailRepository.findByOrder_OrderId(orderId);

        List<OrderDetailItemResponse> items = orderDetails.stream()
                .map(od -> new OrderDetailItemResponse(
                        od.getBook().getBookId(),
                        od.getBook().getTitle(),
                        od.getQuantity(),
                        od.getUnitPrice()
                ))
                .toList();

//        String address;
//        if (order.getShippingAddress() != null) {
//            var sa = order.getShippingAddress();
//
//            address = sa.getSpecificAddress()
//                    + (sa.getWard() != null ? ", " + sa.getWard() : "")
//                    + ", " + sa.getDistrict()
//                    + ", " + sa.getProvince();
//        } else {
//            address = order.getAddress();
//        }
//
//        String customerName = user.getFullName() != null
//                ? user.getFullName()
//                : (user.getCustomer() != null ? user.getCustomer().getFullName() : "Khách hàng");
//
//        String phone = user.getCustomer() != null
//                ? user.getCustomer().getPhone()
//                : "";
        String address;
        String customerName;
        String phone;

        if (order.getShippingAddress() != null) {
            var sa = order.getShippingAddress();

            address = sa.getSpecificAddress()
                    + (sa.getWard() != null ? ", " + sa.getWard() : "")
                    + ", " + sa.getDistrict()
                    + ", " + sa.getProvince();

            customerName = sa.getRecipientName();
            phone = sa.getPhoneNumber();
        } else {
            address = order.getAddress();

            customerName = user.getFullName();
            phone = user.getCustomer() != null ? user.getCustomer().getPhone() : "";
        }

        return new OrderDetailResponse(
                order.getOrderId(),
                normalizeDetailStatus(order.getStatus()),
                order.getOrderDate(),
                order.getTotalAmount(),
                address,
                customerName,
                phone,
                items
        );
    }

    @Transactional
    public String cancelOrder(String orderId, String emailFromToken) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        Orders order = ordersRepository.findByOrderIdAndCustomer_CustomerId(orderId, customerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        String normalizedStatus = normalizeHistoryStatus(order.getStatus());
        if (!"pending".equals(normalizedStatus)) {
            throw new RuntimeException("Chỉ có thể huỷ đơn đang chờ xác nhận");
        }

        Date now = new Date();
        long diffMillis = now.getTime() - order.getOrderDate().getTime();
        long diffMinutes = TimeUnit.MILLISECONDS.toMinutes(diffMillis);

        if (diffMinutes > 30) {
            throw new RuntimeException("Đã quá 30 phút, không thể huỷ đơn hàng");
        }

        order.setStatus("cancelled");
        ordersRepository.save(order);

        return "Đơn hàng đã được huỷ";
    }



}