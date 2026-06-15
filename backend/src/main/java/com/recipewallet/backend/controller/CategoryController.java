package com.recipewallet.backend.controller;

import com.recipewallet.backend.model.Category;
import com.recipewallet.backend.model.User;
import com.recipewallet.backend.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryRepository categoryRepository;

    @GetMapping
    public ResponseEntity<List<String>> getCategories(@AuthenticationPrincipal User user) {
        List<Category> categories = categoryRepository.findByUser(user);
        
        // Auto-initialize standard categories if none exist
        if (categories.isEmpty()) {
            List<String> defaults = List.of("Coffee", "Groceries", "Utilities", "Shopping", "Other");
            for (String name : defaults) {
                Category cat = Category.builder()
                        .name(name)
                        .user(user)
                        .build();
                categoryRepository.save(cat);
            }
            categories = categoryRepository.findByUser(user);
        }

        return ResponseEntity.ok(categories.stream().map(Category::getName).toList());
    }

    @PostMapping
    public ResponseEntity<String> addCategory(@RequestBody String name, @AuthenticationPrincipal User user) {
        // Strip quotes if any (e.g. from raw text request body)
        String cleanName = name.replace("\"", "").trim();
        
        if (categoryRepository.findByUserAndName(user, cleanName).isPresent()) {
            return ResponseEntity.badRequest().body("Category already exists");
        }

        Category category = Category.builder()
                .name(cleanName)
                .user(user)
                .build();
        categoryRepository.save(category);

        return ResponseEntity.ok(cleanName);
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<Void> deleteCategory(@PathVariable("name") String name, @AuthenticationPrincipal User user) {
        categoryRepository.findByUserAndName(user, name).ifPresent(categoryRepository::delete);
        return ResponseEntity.ok().build();
    }
}
