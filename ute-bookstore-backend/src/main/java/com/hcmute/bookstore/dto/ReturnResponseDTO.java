package com.hcmute.bookstore.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReturnResponseDTO {
    private String returnId;
    private String orderId;
    private String reason;
    private String bankName;
    private String accountHolder;
    private String accountNumber;
    private List<String> imageEvidences;
    private String status;
    private LocalDateTime createdAt; // Ngày gửi yêu cầu
    private String reply;
}