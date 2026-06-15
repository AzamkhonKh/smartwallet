package com.recipewallet.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String oauthId; // Unique identifier from OAuth provider (e.g., OIDC 'sub' claim)

    @Column(nullable = true)
    private String email;

    @Column(unique = true)
    private String phoneNumber;

    private String name;

    @Column(nullable = false)
    @Builder.Default
    private String primaryCurrency = "USD";

    private LocalDateTime dateJoined;

    @PrePersist
    protected void onCreate() {
        dateJoined = LocalDateTime.now();
        if (primaryCurrency == null) {
            primaryCurrency = "USD";
        }
    }
}
