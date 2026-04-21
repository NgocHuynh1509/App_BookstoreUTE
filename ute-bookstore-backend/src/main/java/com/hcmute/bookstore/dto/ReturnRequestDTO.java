package com.hcmute.bookstore.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Data Transfer Object cho yêu cầu hoàn trả hàng.
 * Dùng để nhận dữ liệu từ Frontend gửi lên API.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReturnRequestDTO {

    private String orderId;

    private String reason;

    private String bankName;

    private String accountHolder;

    private String accountNumber;

    /**
     * Có thể là String Base64 hoặc URL sau khi đã upload lên
     * các dịch vụ lưu trữ đám mây (Cloudinary, S3, Firebase).
     */
    private List<String> imageEvidences; // Chuyển thành List nhen
}