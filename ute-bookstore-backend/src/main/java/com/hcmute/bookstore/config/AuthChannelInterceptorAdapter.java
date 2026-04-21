package com.hcmute.bookstore.config;

import com.hcmute.bookstore.Security.JwtService;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.UsersRepository;
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
    private final UsersRepository usersRepository;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authHeader = accessor.getFirstNativeHeader("Authorization");

            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                try {
                    // 1. Giải mã token lấy subject (hiện tại CustomUserDetailsService lưu email vào subject)
                    String subject = jwtService.extractUsername(token);

                    if (subject != null) {
                        String finalPrincipal = subject;
                        
                        // 2. Tìm username thức tế từ Database thay vì gán cứng
                        Users userByEmail = usersRepository.findByCustomer_Email(subject).orElse(null);
                        if (userByEmail != null) {
                            finalPrincipal = userByEmail.getUserName();
                        } else {
                            Users userByName = usersRepository.findById(subject).orElse(null);
                            if (userByName != null) {
                                finalPrincipal = userByName.getUserName();
                            }
                        }

                        // 3. ĐỊNH DANH (Dùng trực tiếp username)
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