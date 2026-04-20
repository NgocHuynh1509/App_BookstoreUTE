package com.hcmute.bookstore.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

@Configuration
public class FirebaseConfig {

    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${firebase.enabled:true}")
    private boolean firebaseEnabled;

    @Value("${firebase.credentials:}")
    private String firebaseCredentials;

    @PostConstruct
    public void init() {
        if (!firebaseEnabled) {
            log.info("Firebase is disabled via configuration.");
            return;
        }

        try (InputStream is = resolveCredentialsStream()) {
            if (is == null) {
                log.warn("Firebase credentials not found. Set firebase.credentials or add firebase-service-account.json to classpath.");
                return;
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(is))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
            }
        } catch (Exception e) {
            log.error("Failed to initialize Firebase", e);
        }
    }

    private InputStream resolveCredentialsStream() throws Exception {
        if (firebaseCredentials != null && !firebaseCredentials.isBlank()) {
            Path path = Path.of(firebaseCredentials).toAbsolutePath().normalize();
            if (Files.exists(path)) {
                return Files.newInputStream(path);
            }
            log.warn("firebase.credentials path not found: {}", path);
        }

        return getClass()
                .getClassLoader()
                .getResourceAsStream("firebase-service-account.json");
    }
}