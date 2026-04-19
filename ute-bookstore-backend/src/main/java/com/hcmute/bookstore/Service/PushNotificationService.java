package com.hcmute.bookstore.Service;

import com.google.firebase.messaging.*;
import org.springframework.stereotype.Service;

@Service
public class PushNotificationService {

    public void sendPush(String token, String title, String body) {
        Message message = Message.builder()
                .setToken(token)
                .setNotification(
                        Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build()
                )
                .build();

        try {
            FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}