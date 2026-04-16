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
import com.hcmute.bookstore.Entity.Orders; // Thay đúng đường dẫn tới file Order.java của má


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
    public ResponseEntity<?> createOrder(@RequestBody OrderRequest request, HttpServletRequest httpRequest) {
        try {
            // 1. Tạo đơn hàng (Giống logic buy-now)
            String orderId = orderService.createOrder(request);
            Orders order = ordersRepository.findById(orderId)
                    .orElseThrow(() -> new Exception("Không tìm thấy đơn hàng"));

            // 2. Tạo luôn bản ghi Payment (Y hệt bên kia)
            Payment payment = new Payment();
            payment.setPaymentTime(new Date());
            payment.setAmount(request.getFinal_total());
            payment.setOrder(order);

            // 3. Rẽ nhánh phương thức
            if ("VNPAY".equals(request.getPayment_method())) {
                payment.setPaymentId("PAY_VNP_" + System.currentTimeMillis());
                payment.setMethod("VNPAY");
                payment.setStatus("SUCCESS"); // Ép THÀNH CÔNG luôn nè má!

                // Cập nhật đơn hàng thành CONFIRMED (Y chang bên kia nha)
                order.setStatus("CONFIRMED");
                ordersRepository.save(order);
                paymentRepository.save(payment);

                // Tạo URL VNPAY
                PaymentDTO paymentDTO = new PaymentDTO();
                paymentDTO.setOrderId(orderId);
                paymentDTO.setAmount(request.getFinal_total().longValue());
                paymentDTO.setOrderInfo("Thanh toan don hang " + orderId);
                String vnpayUrl = vnPayService.createPaymentUrl(paymentDTO, httpRequest);

                return ResponseEntity.ok(Map.of("success", true, "vnpayUrl", vnpayUrl, "orderId", orderId));

            } else {
                // Thanh toán COD
                payment.setPaymentId("PAY_COD_" + System.currentTimeMillis());
                payment.setMethod("COD");
                payment.setStatus("UNPAID");
                paymentRepository.save(payment);

                return ResponseEntity.ok(Map.of("success", true, "orderId", orderId, "message", "Đặt hàng COD thành công"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("success", false, "error", e.getMessage()));
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
                order.setStatus("CONFIRMED"); // Hoặc PAID tùy má thích
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
                payment.setStatus("UNPAID"); // COD thì chưa thanh toán ngay, để sau khi giao hàng mới cập nhật thành PAID
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
        String status = request.get("status");

        System.out.println("-----> CÓ THẰNG GỌI RỒI NÈ! Dữ liệu: " + request);
        try {
            // 1. Tìm bản ghi Payment theo OrderId
            Payment payment = paymentRepository.findByOrder_OrderId(orderId);

            if (payment != null) {
                // 2. Cập nhật trạng thái thanh toán (FAILED/SUCCESS)
                payment.setStatus(status);
                paymentRepository.save(payment);

                // 3. Cập nhật trạng thái ĐƠN HÀNG (Order) sang PENDING
                // Lấy object Order từ trong Payment ra
                Orders order = payment.getOrder();
                if (order != null) {
                    // Giả sử Status trong bảng Order của má là String
                    order.setStatus("PENDING");
                    // Nếu má dùng Enum thì thay bằng: order.setStatus(OrderStatus.PENDING);

                    // Lưu lại sự thay đổi của Order
                    // Nếu má dùng JpaRepository cho Order thì gọi orderRepository.save(order)
                    // Hoặc nếu có cascade thì nó tự lưu, nhưng gọi tường minh cho chắc má ạ
                    ordersRepository.save(order);
                }

                System.out.println("✅ Đã cập nhật Payment thành: " + status + " và Order thành: PENDING cho đơn " + orderId);
                return ResponseEntity.ok(Map.of("success", true));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Không tìm thấy đơn hàng");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

}