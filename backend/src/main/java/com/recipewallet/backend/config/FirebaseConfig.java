package com.recipewallet.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.beans.factory.annotation.Value;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@Configuration
public class FirebaseConfig {

    @Value("${recipewallet.firebase.storage-bucket:office-market-27ec0.firebasestorage.app}")
    private String storageBucket;

    @Value("${recipewallet.firebase.credentials}")
    private String firebaseCredentials;

    @Bean
    public FirebaseApp firebaseApp() {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        if (firebaseCredentials == null || firebaseCredentials.trim().isEmpty() || "mock-credentials".equals(firebaseCredentials)) {
            return null;
        }

        try (InputStream serviceAccount = new ByteArrayInputStream(firebaseCredentials.getBytes(StandardCharsets.UTF_8))) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .setStorageBucket(storageBucket)
                    .build();

            return FirebaseApp.initializeApp(options);
        } catch (Exception e) {
            System.err.println("Firebase initialization failed: " + e.getMessage());
            return null;
        }
    }
}
