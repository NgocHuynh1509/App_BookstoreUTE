package com.hcmute.bookstore.dto;

import com.hcmute.bookstore.Entity.MessageType;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class ChatMessageResponse {
    private String id;
    private String content;
    private String mediaUrl;
    private MessageType messageType;
    private String senderRole;
    private LocalDateTime createdAt;
    private String receiverName;

    // Thông tin Reply
    private String replyToContent;

    // Thông tin Product đính kèm
    private String bookId;
    private String bookName;
    private String bookImage;

    // Thông tin Order đính kèm
    private String orderId;
    private String orderStatus;
    private BigDecimal totalPrice;
    private String userName;
}
