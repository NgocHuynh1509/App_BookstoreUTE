package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.ChatService;
import com.hcmute.bookstore.dto.ChatMessageResponse;
import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatRestController {

    private final ChatMessageRepository chatRepository;
    private final ChatService chatService;

    @GetMapping("/history/{userName}")
    public ResponseEntity<List<ChatMessageResponse>> getChatHistory(
            @PathVariable String userName,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<ChatMessage> messages = chatRepository.findChatHistoryForUser(userName, pageable);

        List<ChatMessageResponse> responseList = messages.getContent().stream()
                .map(chatService::mapToResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(responseList);
    }

    @PostMapping("/mark-seen/{userName}")
    public ResponseEntity<Void> markSeen(@PathVariable String userName) {
        // Mặc định là USER gọi API này
        chatService.markSeen(userName, "USER");
        return ResponseEntity.ok().build();
    }

    @PostMapping("/toggle-unread/{partnerName}")
    public ResponseEntity<Void> toggleUnread(@PathVariable String partnerName, @RequestParam boolean isUnread) {
        chatService.toggleManualUnread(partnerName, "USER", isUnread);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/unread-status/{userName}")
    public ResponseEntity<Boolean> getUnreadStatus(@PathVariable String userName) {
        return ResponseEntity.ok(chatService.hasAnyUnreadMessagesForUser(userName));
    }
}