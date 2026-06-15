package com.recipewallet.backend.repository;

import com.recipewallet.backend.model.Transaction;
import com.recipewallet.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import com.recipewallet.backend.model.Account;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByUserOrderByTransactionDateDesc(User user);

    List<Transaction> findByUserAndImageHashAndIsDraftFalse(User user, String imageHash);

    boolean existsByUserAndImageHash(User user, String imageHash);

    List<Transaction> findByUserAndTotalAmountAndIsDraftFalse(User user, Double totalAmount);

    @Modifying
    @Transactional
    @Query("DELETE FROM Transaction t WHERE t.fromAccount = :account OR t.toAccount = :account")
    void deleteByAccount(@Param("account") Account account);
}
