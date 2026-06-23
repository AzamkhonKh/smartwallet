package com.recipewallet.backend.repository;

import com.recipewallet.backend.model.Account;
import com.recipewallet.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AccountRepository extends JpaRepository<Account, String> {
    List<Account> findByUser(User user);
    void deleteByUser(User user);
}
