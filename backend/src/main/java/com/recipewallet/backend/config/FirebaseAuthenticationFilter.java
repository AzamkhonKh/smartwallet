package com.recipewallet.backend.config;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.recipewallet.backend.model.User;
import com.recipewallet.backend.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.Optional;

@RequiredArgsConstructor
public class FirebaseAuthenticationFilter extends OncePerRequestFilter {

    private final UserRepository userRepository;
    private final String appMode;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        try {
            User user;
            if (token.startsWith("mock-token-")) {
                if (!"dev".equalsIgnoreCase(appMode)) {
                    throw new RuntimeException("Mock tokens are not allowed in this environment (mode: " + appMode + ").");
                }
                // Handle local mock testing tokens
                String tokenValue = token.substring(11);
                String email = null;
                String phoneNumber = null;
                String name = "Mock User (" + tokenValue + ")";

                if (tokenValue.startsWith("phone-")) {
                    phoneNumber = tokenValue.substring(6);
                } else {
                    email = tokenValue + "@example.com";
                }

                final String finalEmail = email;
                final String finalPhoneNumber = phoneNumber;

                user = userRepository.findByOauthId(tokenValue).orElseGet(() -> {
                    if (finalPhoneNumber != null) {
                        return userRepository.findByPhoneNumber(finalPhoneNumber).map(existingUser -> {
                            existingUser.setOauthId(tokenValue);
                            return userRepository.save(existingUser);
                        }).orElseGet(() -> {
                            User newUser = User.builder()
                                    .oauthId(tokenValue)
                                    .email(finalEmail)
                                    .phoneNumber(finalPhoneNumber)
                                    .name(name)
                                    .build();
                            return userRepository.save(newUser);
                        });
                    } else {
                        User newUser = User.builder()
                                .oauthId(tokenValue)
                                .email(finalEmail)
                                .phoneNumber(finalPhoneNumber)
                                .name(name)
                                .build();
                        return userRepository.save(newUser);
                    }
                });
            } else {
                // Verify real Firebase ID Token
                FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);
                String oauthId = decodedToken.getUid();
                String email = decodedToken.getEmail();
                String name = (String) decodedToken.getClaims().get("name");
                String phoneNumber = (String) decodedToken.getClaims().get("phone_number");

                user = userRepository.findByOauthId(oauthId).orElseGet(() -> {
                    if (phoneNumber != null && !phoneNumber.trim().isEmpty()) {
                        Optional<User> existingUser = userRepository.findByPhoneNumber(phoneNumber);
                        if (existingUser.isPresent()) {
                            User u = existingUser.get();
                            u.setOauthId(oauthId);
                            if (name != null) u.setName(name);
                            if (email != null) u.setEmail(email);
                            return userRepository.save(u);
                        }
                    }
                    User u = User.builder()
                            .oauthId(oauthId)
                            .email(email)
                            .phoneNumber(phoneNumber)
                            .name(name != null ? name : (phoneNumber != null ? "User " + phoneNumber : "User " + oauthId))
                            .build();
                    return userRepository.save(u);
                });
            }

            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    user,
                    token,
                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Unauthorized\", \"message\": \"" + e.getMessage() + "\"}");
            return;
        }

        filterChain.doFilter(request, response);
    }
}
