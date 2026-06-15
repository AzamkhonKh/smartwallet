package com.recipewallet.backend.repository;

import com.recipewallet.backend.model.Category;
import com.recipewallet.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findByUser(User user);
    Optional<Category> findByUserAndName(User user, String name);
}
