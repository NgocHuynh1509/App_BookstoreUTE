package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Notification;
import com.hcmute.bookstore.Entity.NotificationType;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.NotificationRepository;
import com.hcmute.bookstore.dto.notification.NotificationRealtimeResponse;
import com.hcmute.bookstore.dto.notification.NotificationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public void createNotification(
            Users user,
            String title,
            String message,
            NotificationType type,
            String referenceId,
            String role
    ) {
        Notification notification = Notification.builder()
                .title(title)
                .message(message)
                .type(type)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .referenceId(referenceId)
                .role(role)
                .user(user)
                .build();

        Notification saved = notificationRepository.save(notification);

        NotificationRealtimeResponse payload = NotificationRealtimeResponse.builder()
                .id(saved.getId())
                .title(saved.getTitle())
                .message(saved.getMessage())
                .type(saved.getType().name())
                .isRead(saved.getIsRead())
                .createdAt(saved.getCreatedAt().toString())
                .referenceId(saved.getReferenceId())
                .build();

        messagingTemplate.convertAndSendToUser(
                user.getCustomer().getEmail(),
                "/queue/notifications",
                payload
        );
    }

    public Page<NotificationResponse> getMyNotifications(Users user, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return notificationRepository.findByUserOrderByCreatedAtDesc(user, pageable)
                .map(n -> NotificationResponse.builder()
                        .id(n.getId())
                        .title(n.getTitle())
                        .message(n.getMessage())
                        .type(n.getType().name())
                        .isRead(n.getIsRead())
                        .createdAt(n.getCreatedAt().toString())
                        .referenceId(n.getReferenceId())
                        .build());
    }

    public long countUnread(Users user) {
        return notificationRepository.countByUserAndIsReadFalse(user);
    }

    public void markAsRead(Notification notification) {
        notification.setIsRead(true);
        notificationRepository.save(notification);
    }

    public void markAllAsRead(Users user) {
        List<Notification> list = notificationRepository
                .findByUserAndIsReadFalse(user);

        for (Notification n : list) {
            n.setIsRead(true);
        }

        notificationRepository.saveAll(list);
    }
}