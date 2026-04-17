package com.hcmute.bookstore.dto.admin;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatThreadDTO {
    private String customerUsername;
    private String lastMessage;
    private LocalDateTime lastTime;
    private int unreadCount;
}