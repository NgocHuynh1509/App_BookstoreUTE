package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Entity.Payment;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.PaymentRepository;
import com.hcmute.bookstore.Service.OrderService;
import com.hcmute.bookstore.Service.VNPayService;
import com.hcmute.bookstore.dto.*;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;


import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    @Autowired
    private PaymentRepository paymentRepository;
    @Autowired
    private VNPayService vnPayService;
    @Autowired
    private OrdersRepository ordersRepository;

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

    @PostMapping("/buy-now")
    public ResponseEntity<?> buyNowOrder(@RequestBody OrderDirectRequest request, HttpServletRequest httpRequest) {
        try {
            // 1. Tạo đơn hàng
            String orderId = orderService.createDirectOrder(request);
            Orders order = ordersRepository.findById(orderId)
                    .orElseThrow(() -> new Exception("Không tìm thấy đơn hàng"));

            // 2. Tạo luôn bản ghi Payment THÀNH CÔNG (Dù là COD hay VNPAY)
            Payment payment = new Payment();
            payment.setPaymentTime(new Date());
            payment.setAmount(request.getFinal_total());
            payment.setOrder(order);

            if ("VNPAY".equals(request.getPayment_method())) {
                payment.setPaymentId("PAY_VNP_" + System.currentTimeMillis()); // Tạo ID ngẫu nhiên cho xịn
                payment.setMethod("VNPAY");
                payment.setStatus("SUCCESS"); // Ép thành công luôn nè má!

                // Cập nhật đơn hàng thành PAID luôn
                order.setStatus("PENDING");
                ordersRepository.save(order);
                paymentRepository.save(payment);

                // Tạo URL VNPAY để App mở lên cho có lệ (hoặc để khách trả tiền thật)
                PaymentDTO paymentDTO = new PaymentDTO();
                paymentDTO.setOrderId(orderId);
                paymentDTO.setAmount(request.getFinal_total().longValue());
                paymentDTO.setOrderInfo("Thanh toan don hang " + orderId);
                String vnpayUrl = vnPayService.createPaymentUrl(paymentDTO, httpRequest);

                return ResponseEntity.ok(Map.of("success", true, "vnpayUrl", vnpayUrl));
            } else {
                // Thanh toán COD
                payment.setPaymentId("PAY_COD_" + System.currentTimeMillis());
                payment.setMethod("COD");
                payment.setStatus("SUCCESS");
                paymentRepository.save(payment);

                return ResponseEntity.ok(Map.of("success", true, "orderId", orderId));
            }

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @Transactional
    @PostMapping("/update-status")
    public ResponseEntity<?> updatePaymentStatus(@RequestBody Map<String, String> request) {
        String orderId = request.get("orderId");
        String status = request.get("status"); // App gửi sang FAILED hoặc SUCCESS
        // ĐẶT Ở ĐÂY NÈ MÁ - CHƯA CẦN LÀM GÌ CŨNG IN RA TRƯỚC
        System.out.println("-----> CÓ THẰNG GỌI RỒI NÈ! Dữ liệu: " + request);
        try {
            // 1. Tìm đúng bản ghi Payment theo OrderId
            Payment payment = paymentRepository.findByOrder_OrderId(orderId);

            if (payment != null) {
                // 2. Chỉ cập nhật duy nhất bảng Payment
                payment.setStatus(status);
                paymentRepository.save(payment);

                System.out.println("✅ Đã cập nhật trạng thái thanh toán cho đơn " + orderId + " thành: " + status);
                return ResponseEntity.ok(Map.of("success", true));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Không tìm thấy payment để cập nhật");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

}