package com.recipewallet.backend.service.queue;

import com.recipewallet.backend.model.ReceiptTask;
import com.recipewallet.backend.service.ReceiptProcessingService;
import com.recipewallet.backend.util.InMemoryMultipartFile;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReceiptTaskWorker {

    private final ReceiptProcessingService receiptProcessingService;

    @Value("${recipewallet.storage.disk.upload-dir:uploads}")
    private String uploadDir;

    @Scheduled(fixedDelay = 2000)
    public void pollAndProcess() {
        // Transaction 1: Acquire task
        ReceiptTask task = receiptProcessingService.acquireNextTask();
        if (task == null) {
            return;
        }

        log.info("Acquired task ID: {} for processing", task.getId());
        try {
            // Resolve file bytes
            byte[] fileBytes = resolveFileBytes(task.getImageUrl());
            InMemoryMultipartFile file = new InMemoryMultipartFile(
                    fileBytes,
                    "file",
                    task.getFileName() != null ? task.getFileName() : "receipt.jpg",
                    task.getContentType() != null ? task.getContentType() : "image/jpeg"
            );

            // Execute non-transactional processing (OCR + LLM)
            ReceiptProcessingService.ExtractedDataAndOcr result = receiptProcessingService.performOcrAndLlm(
                    file, task.getTransactionId(), task.getUser());

            // Transaction 2: Commit successful results
            receiptProcessingService.finalizeTransaction(task.getTransactionId(), result, task.getId());

        } catch (Exception e) {
            log.error("Failed to process task ID: {}", task.getId(), e);
            // Transaction 2 Fail: Commit failure state
            try {
                receiptProcessingService.failTransaction(task.getTransactionId(), task.getId(), e.getMessage());
            } catch (Exception ex) {
                log.error("Failed to mark task ID: {} as failed in DB", task.getId(), ex);
            }
        }
    }

    private byte[] resolveFileBytes(String imageUrl) throws IOException {
        // Try resolving locally first if it looks like a local URL
        if (imageUrl.contains("/uploads/")) {
            String filename = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
            Path filePath = Paths.get(uploadDir, filename);
            if (Files.exists(filePath)) {
                log.info("Resolving file bytes locally from path: {}", filePath);
                return Files.readAllBytes(filePath);
            }
        }

        // Fallback: download via HTTP
        log.info("Downloading file bytes from URL: {}", imageUrl);
        java.net.URL url = new java.net.URL(imageUrl);
        try (InputStream in = url.openStream()) {
            return in.readAllBytes();
        }
    }
}
