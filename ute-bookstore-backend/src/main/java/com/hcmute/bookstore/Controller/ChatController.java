package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.ChatService;
import com.hcmute.bookstore.dto.ChatMessageRequest;
import com.hcmute.bookstore.dto.ChatMessageResponse;
import com.hcmute.bookstore.dto.ReactionRequest;
import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Entity.MessageStatus;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import com.hcmute.bookstore.Repository.BooksRepository; // Giả định bạn đã có
import com.hcmute.bookstore.Repository.OrdersRepository; // Giả định bạn đã có
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import com.hcmute.bookstore.Service.ChatService;


import java.util.UUID;

@Controller
@RequiredArgsConstructor
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;
    private final ChatMessageRepository chatRepository;
    private final BooksRepository booksRepository;
    private final OrdersRepository ordersRepository;
    @Autowired
    private ChatService chatService;
    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@Payload ChatMessageRequest request, java.security.Principal principal) {
        System.out.println("DEBUG: Dang gui tin nhan toi User: " + request.getReceiverName());
        // 1. KIỂM TRA TÊN NGƯỜI GỬI THỰC TẾ
        // Nếu dòng này in ra 'null' hoặc 'uservn2x...', nghĩa là Interceptor của bạn ĐANG SAI.
        String actualSender = (principal != null) ? principal.getName() : "ANONYMOUS";
        System.out.println("🚀 [SENDER CHECK] User thực tế đang gửi là: " + actualSender);
        System.out.println("🚀 [RECEIVER CHECK] Dang gui toi: " + request.getReceiverName());

        // 1. Logic tạo Entity (Giữ nguyên của bạn)
        ChatMessage.ChatMessageBuilder messageBuilder = ChatMessage.builder()
                .id(UUID.randomUUID().toString())
                .userName(request.getUserName())
                .receiverName(request.getReceiverName()) // MỚI: Người nhận (ví dụ: 'khach_hang_A')
                .senderRole(request.getSenderRole())
                .content(request.getContent())
                .mediaUrl(request.getMediaUrl())
                .messageType(request.getMessageType())
                .status(MessageStatus.SENT);

        if (request.getReplyToId() != null) {
            chatRepository.findById(request.getReplyToId()).ifPresent(messageBuilder::replyTo);
        }

        if (request.getBookId() != null) {
            booksRepository.findById(request.getBookId()).ifPresent(messageBuilder::attachedBook);
        }

        if (request.getOrderId() != null) {
            ordersRepository.findById(request.getOrderId()).ifPresent(messageBuilder::attachedOrder);
        }

        // 2. Lưu vào Database
        ChatMessage savedMessage = chatRepository.save(messageBuilder.build());

        // 3. CHUYỂN ĐỔI SANG DTO (Sử dụng hàm mapToResponse)
        // Đây là bước quan trọng để tránh lỗi và bảo mật dữ liệu
        ChatMessageResponse response = chatService.mapToResponse(savedMessage);

        // 2. GỬI CHO NGƯỜI NHẬN
        // Chú ý: request.getReceiverName() PHẢI KHỚP Y HỆT với tên trong log SUBSCRIBE
        messagingTemplate.convertAndSendToUser(
                request.getReceiverName(),
                "/queue/messages",
                response
        );

        // 3. GỬI CHO CHÍNH MÌNH (Dùng actualSender để đảm bảo chính xác)
        messagingTemplate.convertAndSendToUser(
                actualSender,
                "/queue/messages",
                response
        );
    }

    @MessageMapping("/chat.react")
    public void reactMessage(@Payload ReactionRequest request) {
        ChatMessage message = chatRepository.findById(request.getMessageId())
                .orElseThrow(() -> new RuntimeException("Message not found"));

        message.setReaction(request.getReaction());
        chatRepository.save(message);

        // Gửi thông báo reaction cho đối phương
        messagingTemplate.convertAndSendToUser(
                request.getPartnerName(),
                "/queue/reactions",
                message
        );
    }
}