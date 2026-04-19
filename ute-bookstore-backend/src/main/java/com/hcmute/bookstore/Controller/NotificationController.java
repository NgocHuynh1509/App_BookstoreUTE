package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Entity.Notification;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.NotificationRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.Service.CurrentUserService;
import com.hcmute.bookstore.Service.NotificationService;
import com.hcmute.bookstore.dto.notification.NotificationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final UsersRepository usersRepository;
    private final NotificationRepository notificationRepository;
    private final CurrentUserService currentUserService;

    @GetMapping
    public Page<NotificationResponse> getMyNotifications(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Users user = currentUserService.getCurrentUser(authentication); // 👈 dùng chung

        return notificationService.getMyNotifications(user, page, size);
    }

    @GetMapping("/unread-count")
    public long countUnread(Authentication authentication) {
        Users user = currentUserService.getCurrentUser(authentication);

        return notificationService.countUnread(user);
    }

    @PutMapping("/{id}/read")
    public void markAsRead(@PathVariable Long id, Authentication authentication) {
        Users user = currentUserService.getCurrentUser(authentication);

        Notification notification = notificationRepository.findByIdAndUser(id, user)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy notification"));

        notificationService.markAsRead(notification);
    }

    @PutMapping("/read-all")
    public void markAllAsRead(Authentication authentication) {
        Users user = currentUserService.getCurrentUser(authentication);
        notificationService.markAllAsRead(user);
    }

}