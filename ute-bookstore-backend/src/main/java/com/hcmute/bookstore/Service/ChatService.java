package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import com.hcmute.bookstore.Repository.ShippingAddressRepository;
import com.hcmute.bookstore.dto.ChatMessageResponse;
import com.hcmute.bookstore.dto.admin.ChatMessageDTO;
import com.hcmute.bookstore.dto.admin.ChatThreadDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service // BẮT BUỘC PHẢI CÓ DÒNG NÀY
@RequiredArgsConstructor
public class ChatService {
    @Autowired
    private ChatMessageRepository chatRepository;
    // --- COPY HÀM NÀY VÀO TRONG CONTROLLER HOẶC SERVICE ---
    public ChatMessageResponse mapToResponse(ChatMessage entity) {
        ChatMessageResponse.ChatMessageResponseBuilder builder = ChatMessageResponse.builder()
                .id(entity.getId())
                .content(entity.getContent())
                .mediaUrl(entity.getMediaUrl())
                .messageType(entity.getMessageType())
                .senderRole(entity.getSenderRole())
                .userName(entity.getUserName())
                .receiverName(entity.getReceiverName())
                .createdAt(entity.getCreatedAt());

        if (entity.getReplyTo() != null) {
            builder.replyToContent(entity.getReplyTo().getContent());
        }

        if (entity.getAttachedBook() != null) {
            builder.bookId(entity.getAttachedBook().getBookId());
            builder.bookName(entity.getAttachedBook().getTitle());
            builder.bookImage(entity.getAttachedBook().getPicture()); // Giả định có trường image
        }

        if (entity.getAttachedOrder() != null) {
            builder.orderId(entity.getAttachedOrder().getOrderId());
            builder.orderStatus(entity.getAttachedOrder().getStatus().toString());
            builder.totalPrice(entity.getAttachedOrder().getTotalAmount());
        }

        return builder.build();
    }



    // Lấy danh sách thread cho Admin
    public List<ChatMessage> getChatThreads() {
        return chatRepository.findAllChatThreads();
    }

    // Lấy lịch sử chat
    public List<ChatMessage> getChatHistory(String userName) {
        return chatRepository.findByUserNameOrderByCreatedAtAsc(userName);
    }

    // Lưu tin nhắn mới (Dùng cho Socket hoặc API)
    public ChatMessage saveMessage(ChatMessage message) {
        return chatRepository.save(message);
    }
}
