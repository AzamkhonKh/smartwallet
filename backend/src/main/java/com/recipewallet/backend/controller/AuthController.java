package com.recipewallet.backend.controller;

import com.recipewallet.backend.dto.UserResponseDto;
import com.recipewallet.backend.dto.UserProfileRequestDto;
import com.recipewallet.backend.model.User;
import com.recipewallet.backend.repository.UserRepository;
import com.recipewallet.backend.repository.AccountRepository;
import com.recipewallet.backend.repository.CategoryRepository;
import com.recipewallet.backend.repository.TransactionRepository;
import com.recipewallet.backend.repository.ReceiptTaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final CategoryRepository categoryRepository;
    private final TransactionRepository transactionRepository;
    private final ReceiptTaskRepository receiptTaskRepository;

    @DeleteMapping("/me")
    @org.springframework.transaction.annotation.Transactional
    public ResponseEntity<Void> deleteAccount(@AuthenticationPrincipal User user) {
        receiptTaskRepository.deleteByUser(user);
        transactionRepository.deleteByUser(user);
        categoryRepository.deleteByUser(user);
        accountRepository.deleteByUser(user);
        userRepository.delete(user);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponseDto> getCurrentUser(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(toResponseDto(user));
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponseDto> updateProfile(
            @RequestBody UserProfileRequestDto request,
            @AuthenticationPrincipal User user) {
        
        if (request.getName() != null && !request.getName().trim().isEmpty()) {
            user.setName(request.getName());
        }
        if (request.getPrimaryCurrency() != null && !request.getPrimaryCurrency().trim().isEmpty()) {
            user.setPrimaryCurrency(request.getPrimaryCurrency().toUpperCase().trim());
        }
        
        User savedUser = userRepository.save(user);
        return ResponseEntity.ok(toResponseDto(savedUser));
    }

    @PostMapping("/signin")
    public ResponseEntity<UserResponseDto> signIn(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(toResponseDto(user));
    }

    @PostMapping("/signup")
    public ResponseEntity<UserResponseDto> signUp(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(toResponseDto(user));
    }

    private UserResponseDto toResponseDto(User user) {
        if (user == null) return null;
        return UserResponseDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .name(user.getName())
                .primaryCurrency(user.getPrimaryCurrency())
                .dateJoined(user.getDateJoined())
                .build();
    }
}
