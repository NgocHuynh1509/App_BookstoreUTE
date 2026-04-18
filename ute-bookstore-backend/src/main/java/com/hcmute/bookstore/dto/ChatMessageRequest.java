package com.hcmute.bookstore.dto;

import com.hcmute.bookstore.Entity.MessageType;
import lombok.*;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatMessageRequest {
    private String userName;      // ID hoặc Username của người gửi
    private String receiverName;  // ID hoặc Username của người nhận (để server biết gửi đi đâu)
    private String senderRole;    // "USER" hoặc "ADMIN"
    private String content;
    private String mediaUrl;      // URL sau khi đã upload file thành công
    private MessageType messageType;
    private LocalDateTime createdAt;


    // Các ID để thiết lập quan hệ
    private String replyToId;
    private String bookId;
    private String orderId;
}