package com.recipewallet.backend.repository;

import com.recipewallet.backend.model.ReceiptTask;
import com.recipewallet.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface ReceiptTaskRepository extends JpaRepository<ReceiptTask, Long> {

    @Query(value = "SELECT * FROM receipt_tasks WHERE status = 'PENDING' ORDER BY created_at ASC LIMIT 1 FOR UPDATE SKIP LOCKED", nativeQuery = true)
    Optional<ReceiptTask> findNextTaskForUpdate();

    void deleteByUser(User user);
}
