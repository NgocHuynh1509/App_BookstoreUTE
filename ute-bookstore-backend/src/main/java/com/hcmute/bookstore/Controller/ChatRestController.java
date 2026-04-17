package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.ChatService;
import com.hcmute.bookstore.dto.ChatMessageResponse;
import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
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
@RequiredArgsConstructor // Sẽ tự tạo Constructor cho các field 'final'
public class ChatRestController {

    private final ChatMessageRepository chatRepository;
    private final ChatService chatService; // Thêm final và bỏ @Autowired

    @GetMapping("/history/{userName}")
    public ResponseEntity<List<ChatMessageResponse>> getChatHistory(
            @PathVariable String userName,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        // Gọi hàm Query đã sửa
        Page<ChatMessage> messages = chatRepository.findChatHistoryForUser(userName, pageable);

        // SỬA Ở ĐÂY: chatService::mapToResponse
        List<ChatMessageResponse> responseList = messages.getContent().stream()
                .map(chatService::mapToResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(responseList);
    }
}