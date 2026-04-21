package com.hcmute.bookstore.Service;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

import java.util.concurrent.CompletableFuture;

@Service
public class ExpoPushService {

    public void sendPush(String expoToken, String title, String body, String orderId) {
        CompletableFuture.runAsync(() -> {
            try {
                RestTemplate restTemplate = new RestTemplate();

                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);

                Map<String, Object> payload = new HashMap<>();
                payload.put("to", expoToken);
                payload.put("title", title);
                payload.put("body", body);

                Map<String, Object> data = new HashMap<>();
                data.put("orderId", orderId);
                payload.put("data", data);

                HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

                ResponseEntity<String> response = restTemplate.postForEntity(
                        "https://exp.host/--/api/v2/push/send",
                        entity,
                        String.class
                );

                System.out.println("😍😍😍😍EXPO PUSH RESPONSE = " + response.getBody());
                System.out.println("SEND EXPO PUSH TO = " + expoToken);
                System.out.println("TITLE = " + title);
                System.out.println("BODY = " + body);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }
}