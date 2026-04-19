package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Entity.UserFcmToken;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.UserFcmTokenRepository;
import com.hcmute.bookstore.Service.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final CurrentUserService currentUserService;
    private final UserFcmTokenRepository tokenRepo;

    @PostMapping("/save-fcm-token")
    public void saveToken(@RequestBody Map<String, String> body,
                          Authentication auth) {

        System.out.println("== SAVE FCM TOKEN API CALLED ==");

        Users user = currentUserService.getCurrentUser(auth);
        System.out.println("CURRENT USER = " + user.getUserName());

        String token = body.get("token");
        System.out.println("TOKEN = " + token);

        boolean exists = tokenRepo.existsByToken(token);
        System.out.println("TOKEN EXISTS = " + exists);

        if (!exists) {
            UserFcmToken t = new UserFcmToken();
            t.setToken(token);
            t.setUser(user);

            tokenRepo.save(t);
            System.out.println("TOKEN SAVED");
        } else {
            System.out.println("TOKEN ALREADY EXISTS");
        }
    }
}