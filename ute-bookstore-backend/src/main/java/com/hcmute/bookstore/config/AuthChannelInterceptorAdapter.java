package com.hcmute.bookstore.config;

import com.hcmute.bookstore.Security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;

import java.util.Collections;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE) // Phải để mức cao nhất này để chạy trước mọi filter khác
@RequiredArgsConstructor
public class AuthChannelInterceptorAdapter implements ChannelInterceptor {

    private final JwtService jwtService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authHeader = accessor.getFirstNativeHeader("Authorization");

            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                try {
                    // 1. Giải mã token lấy email
                    String email = jwtService.extractUsername(token);

                    if (email != null) {
                        // 2. MAPPING Tên: Ép email về đúng Username mà App đang dùng
                        String finalPrincipal;
                        if (email.contains("admin")) {
                            finalPrincipal = "admin";
                        } else if (email.contains("ngochuynh150905")) {
                            finalPrincipal = "diemngoc";
                        } else {
                            finalPrincipal = email; // Mặc định nếu không khớp
                        }

                        // 3. ĐỊNH DANH: Đây là bước quan trọng nhất
                        UsernamePasswordAuthenticationToken auth =
                                new UsernamePasswordAuthenticationToken(finalPrincipal, null, Collections.emptyList());

                        accessor.setUser(auth);
                        System.out.println("✅ [SOCKET AUTH] Đã định danh thành công: " + finalPrincipal);
                    }
                } catch (Exception e) {
                    System.err.println("❌ [SOCKET AUTH] Lỗi Token: " + e.getMessage());
                }
            }
        }
        return message;
    }

    @Override
    public void postSend(Message<?> message, MessageChannel channel, boolean sent) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);
        if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            String user = (accessor.getUser() != null) ? accessor.getUser().getName() : "Anonymous";
            System.out.println("🛰️ [SUBSCRIBE CHECK] User: " + user + " đang nghe kênh: " + accessor.getDestination());
        }
    }
}