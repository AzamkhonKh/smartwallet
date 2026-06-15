package com.recipewallet.backend.controller;

import com.recipewallet.backend.model.Transaction;
import com.recipewallet.backend.model.User;
import com.recipewallet.backend.repository.TransactionRepository;
import com.recipewallet.backend.service.RecipeReaderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class SuggestionController {

    private final TransactionRepository transactionRepository;
    private final RecipeReaderService recipeReaderService;

    @PostMapping("/{id}/suggestions")
    public ResponseEntity<Map<String, String>> getSuggestions(
            @PathVariable("id") Long id,
            @AuthenticationPrincipal User user) {
        
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Transaction not found"));

        if (!transaction.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(403).build();
        }

        String suggestions = recipeReaderService.getRecipeReaderSuggestions(transaction);

        transaction.setSuggestions(suggestions);
        transactionRepository.save(transaction);

        return ResponseEntity.ok(Map.of("suggestions", suggestions));
    }
}
