package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Entity.MessageStatus;
import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import com.hcmute.bookstore.dto.ChatMessageResponse;
import com.hcmute.bookstore.dto.admin.ChatThreadDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {
    @Autowired
    private ChatMessageRepository chatRepository;

    public ChatMessageResponse mapToResponse(ChatMessage entity) {
        ChatMessageResponse.ChatMessageResponseBuilder builder = ChatMessageResponse.builder()
                .id(entity.getId())
                .content(entity.getContent())
                .mediaUrl(entity.getMediaUrl())
                .messageType(entity.getMessageType())
                .userName(entity.getUserName())
                .senderRole(entity.getSenderRole())
                .receiverName(entity.getReceiverName())
                .createdAt(entity.getCreatedAt())
                .isMarkedUnreadByAdmin(entity.isMarkedUnreadByAdmin())
                .isMarkedUnreadByUser(entity.isMarkedUnreadByUser());

        if (entity.getReplyTo() != null) {
            builder.replyToId(entity.getReplyTo().getId());
            builder.replyToContent(entity.getReplyTo().getContent());
            builder.replyToMediaUrl(entity.getReplyTo().getMediaUrl());
            builder.replyToMessageType(entity.getReplyTo().getMessageType());
            builder.replyToSender(entity.getReplyTo().getUserName());
        }

        if (entity.getAttachedBook() != null) {
            builder.bookId(entity.getAttachedBook().getBookId());
            builder.bookName(entity.getAttachedBook().getTitle());
            builder.bookImage(entity.getAttachedBook().getPicture());
            builder.bookPrice(entity.getAttachedBook().getPrice());
        }

        // CẬP NHẬT PHẦN MAP ORDER TẠI ĐÂY
        if (entity.getAttachedOrder() != null) {
            Orders order = entity.getAttachedOrder();
            builder.orderId(order.getOrderId());
            builder.orderStatus(order.getStatus().toString());
            builder.totalPrice(order.getTotalAmount());

            // Lấy số mặt hàng từ danh sách chi tiết đơn hàng
            if (order.getOrderDetail_Order() != null) {
                builder.orderItemCount(order.getOrderDetail_Order().size());
            } else {
                builder.orderItemCount(0);
            }

            // LẤY TẤM HÌNH ĐẦU TIÊN Ở ĐÂY
            // Lấy item đầu tiên -> lấy Book -> lấy Picture
            String firstProductImage = order.getOrderDetail_Order().get(0).getBook().getPicture();
            builder.bookImage(firstProductImage);
        }

        if (entity.getReaction() != null) {
            builder.reaction(entity.getReaction().name());
        }

        return builder.build();
    }

    // Lấy danh sách thread cho Admin kèm unread count và manual flag
    public List<ChatThreadDTO> getChatThreadsForAdmin() {
        List<ChatMessage> latestMessages = chatRepository.findAllChatThreads();
        return latestMessages.stream().map(msg -> {
            String customerUsername = msg.getUserName().equals("admin") ? msg.getReceiverName() : msg.getUserName();
            long unreadCount = chatRepository.countByUserNameAndReceiverNameAndStatusNot(customerUsername, "admin", MessageStatus.SEEN);
            
            String senderPrefix = msg.getUserName().equals("admin") ? "Bạn: " : msg.getUserName() + ": ";
            String displayContent = msg.getContent();
            if (displayContent == null || displayContent.trim().isEmpty()) {
                if (msg.getMessageType() != null && "IMAGE".equalsIgnoreCase(msg.getMessageType().name())) {
                    displayContent = "[Hình ảnh]";
                } else {
                    displayContent = "[Đính kèm]";
                }
            }
            
            return ChatThreadDTO.builder()
                    .customerUsername(customerUsername)
                    .lastMessage(senderPrefix + displayContent)
                    .lastTime(msg.getCreatedAt())
                    .unreadCount((int) unreadCount)
                    .manualUnread(msg.isMarkedUnreadByAdmin())
                    .build();
        }).collect(Collectors.toList());
    }

    // Đánh dấu đã xem
    @Transactional
    public void markSeen(String partnerName, String role) {
        if ("ADMIN".equalsIgnoreCase(role)) {
            chatRepository.markAllAsSeenByAdmin(partnerName);
        } else {
            chatRepository.markAllAsSeenByUser(partnerName);
        }
    }

    // Bật/tắt đánh dấu chưa đọc thủ công
    @Transactional
    public void toggleManualUnread(String customerUsername, String role, boolean isUnread) {
        if ("ADMIN".equalsIgnoreCase(role)) {
            ChatMessage latestMsg = chatRepository.findFirstByUserNameAndReceiverNameOrderByCreatedAtDesc(customerUsername, "admin");
            if (latestMsg != null) {
                latestMsg.setMarkedUnreadByAdmin(isUnread);
                chatRepository.save(latestMsg);
            }
        } else {
            ChatMessage latestMsg = chatRepository.findFirstByUserNameAndReceiverNameOrderByCreatedAtDesc("admin", customerUsername);
            if (latestMsg != null) {
                latestMsg.setMarkedUnreadByUser(isUnread);
                chatRepository.save(latestMsg);
            }
        }
    }

    // --- Legacy and other methods ---
    public List<ChatMessage> getChatThreads() { return chatRepository.findAllChatThreads(); }
    public List<ChatMessageResponse> getChatHistory(String userName) {
        return chatRepository.findByUserNameOrderByCreatedAtAsc(userName)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }
    public ChatMessage saveMessage(ChatMessage message) { return chatRepository.save(message); }
    public void markSeenByAdmin(String customerUsername) { chatRepository.markAllAsSeenByAdmin(customerUsername); }
    public void toggleManualUnreadByAdmin(String customerUsername, boolean isUnread) { toggleManualUnread(customerUsername, "ADMIN", isUnread); }

    public boolean hasAnyUnreadMessagesForAdmin() {
        return chatRepository.existsUnreadForAdmin();
    }

    public boolean hasAnyUnreadMessagesForUser(String userName) {
        return chatRepository.existsUnreadForUser(userName);
    }
}
