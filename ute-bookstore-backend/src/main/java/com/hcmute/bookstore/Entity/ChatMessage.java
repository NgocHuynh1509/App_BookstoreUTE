package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessage {

    @Id
    @Column(name = "id", length = 50)
    private String id;

    // Tên người dùng hoặc ID người dùng để định danh cuộc hội thoại
    private String userName;

    // Vai trò: "USER" hoặc "ADMIN"
    private String senderRole;

    private String receiverName;

    @Column(columnDefinition = "TEXT")
    private String content;

    // --- QUẢN LÝ MEDIA (ẢNH/VIDEO MÃ HÓA) ---
    // Lưu URL hoặc Path của file sau khi đã mã hóa
    @Column(name = "media_url", columnDefinition = "TEXT")
    private String mediaUrl;

    // Loại tin nhắn: TEXT, IMAGE, VIDEO, PRODUCT, ORDER
    @Enumerated(EnumType.STRING)
    private MessageType messageType;

    @Enumerated(EnumType.STRING)
    private MessageStatus status;

    // --- TÍNH NĂNG NÂNG CAO ---

    @Enumerated(EnumType.STRING)
    @Column(name = "reaction_type", length = 20)
    private ReactionType reaction;

    // Trả lời tin nhắn (Self-reference)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reply_to_id")
    private ChatMessage replyTo;

    // Đính kèm sản phẩm (Nếu có)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id")
    private Books attachedBook;

    // Đính kèm đơn hàng (Nếu có)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Orders attachedOrder;

    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}