package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Service.ChatService;
import com.hcmute.bookstore.dto.ChatMessageResponse;
import com.hcmute.bookstore.dto.admin.ChatThreadDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController("adminChatController")
@RequestMapping("/admin/chat")
public class ChatController {

    @Autowired
    private ChatService chatService;

    @GetMapping("/threads")
    public List<ChatThreadDTO> getChatThreads() {
        return chatService.getChatThreadsForAdmin();
    }

    @GetMapping("/history/{customerUsername}")
    public List<ChatMessageResponse> getChatHistory(@PathVariable String customerUsername) {
        return chatService.getChatHistory(customerUsername);
    }

    @PostMapping("/mark-seen/{customerUsername}")
    public ResponseEntity<Void> markSeen(@PathVariable String customerUsername) {
        chatService.markSeenByAdmin(customerUsername);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/toggle-unread/{customerUsername}")
    public ResponseEntity<Void> toggleUnread(@PathVariable String customerUsername, @RequestParam boolean isUnread) {
        chatService.toggleManualUnreadByAdmin(customerUsername, isUnread);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/unread-status")
    public ResponseEntity<Boolean> getUnreadStatus() {
        return ResponseEntity.ok(chatService.hasAnyUnreadMessagesForAdmin());
    }
}