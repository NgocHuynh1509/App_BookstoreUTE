package com.hcmute.bookstore.dto;

import com.hcmute.bookstore.Entity.ReactionType;
import lombok.Data;

@Data
public class ReactionRequest {
    private String messageId;
    private String partnerName; // Tên người nhận thông báo react
    private ReactionType reaction;
}