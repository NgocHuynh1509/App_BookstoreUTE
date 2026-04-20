package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Entity.ReturnRequest;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.ReturnRequestRepository;
import com.hcmute.bookstore.dto.ReturnRequestDTO;
import com.hcmute.bookstore.dto.ReturnResponseDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders/returns")
public class ReturnRequestController {

    @Autowired
    private ReturnRequestRepository returnRepo;
    @Autowired
    private OrdersRepository orderRepo;

    @PostMapping("/submit")
    public ResponseEntity<?> submitReturn(@RequestBody ReturnRequestDTO dto) {
        Optional<Orders> orderOpt = orderRepo.findById(dto.getOrderId());
        if (orderOpt.isEmpty()) return ResponseEntity.badRequest().body("Đơn hàng không tồn tại");

        Orders order = orderOpt.get();

        // Tạo yêu cầu hoàn trả
        ReturnRequest rr = new ReturnRequest();
        rr.setReturnId("RET" + System.currentTimeMillis());
        rr.setOrder(order);
        rr.setReason(dto.getReason());
        rr.setBankName(dto.getBankName());
        rr.setAccountHolder(dto.getAccountHolder());
        rr.setAccountNumber(dto.getAccountNumber());
        // Gán danh sách ảnh
        rr.setImageEvidences(dto.getImageEvidences());
        rr.setStatus("PENDING");



        returnRepo.save(rr);
        orderRepo.save(order);

        return ResponseEntity.ok("Gửi yêu cầu hoàn tiền thành công");
    }

    @GetMapping("/detail/{orderId}")
    public ResponseEntity<?> getReturnDetail(@PathVariable String orderId) {
        return returnRepo.findByOrder_OrderId(orderId)
                .map(rr -> {
                    // Chuyển đổi từ Entity sang DTO
                    ReturnResponseDTO response = ReturnResponseDTO.builder()
                            .returnId(rr.getReturnId())
                            .orderId(rr.getOrder().getOrderId())
                            .reason(rr.getReason())
                            .bankName(rr.getBankName())
                            .accountHolder(rr.getAccountHolder())
                            .accountNumber(rr.getAccountNumber())
                            // ĐỔI Ở ĐÂY: Lấy toàn bộ danh sách ảnh từ Entity
                            .imageEvidences(rr.getImageEvidences())
                            .status(rr.getStatus())
                            .createdAt(LocalDateTime.now()) // Hoặc rr.getCreatedAt() nếu có
                            .build();
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.status(404).body(null));
        // Lưu ý: Không nên trả về chuỗi String lỗi, hãy trả về null hoặc object trống
    }
}
