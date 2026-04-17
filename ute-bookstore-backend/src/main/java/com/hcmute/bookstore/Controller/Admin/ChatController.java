package com.hcmute.bookstore.Controller.Admin;


import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController("adminChatController")
@RequestMapping("/admin/chat") // Đảm bảo khớp với baseUrl của ApiClient trong Flutter
public class ChatController {

    @Autowired
    private ChatService chatService;

    // Khớp với Flutter: _client.dio.get('/admin/chat/threads')
    @GetMapping("/threads")
    public List<ChatMessage> getChatThreads() {
        return chatService.getChatThreads();
    }

    // Khớp với Flutter: _client.dio.get('/chat/history/$customerUsername')
    @GetMapping("/history/{customerUsername}")
    public List<ChatMessage> getChatHistory(@PathVariable String customerUsername) {
        return chatService.getChatHistory(customerUsername);
    }
}