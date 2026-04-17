package com.hcmute.bookstore.dto.admin;


import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageDTO {
    private String senderName;
    private String receiverName;
    private String content;
    private String senderRole; // ADMIN hoặc USER
    private LocalDateTime timestamp;
}
