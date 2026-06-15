package com.recipewallet.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.recipewallet.backend.model.Account;
import com.recipewallet.backend.model.ReceiptOcr;
import com.recipewallet.backend.model.Transaction;
import com.recipewallet.backend.model.TransactionItem;
import com.recipewallet.backend.model.User;
import com.recipewallet.backend.model.Category;
import com.recipewallet.backend.model.ReceiptTask;
import com.recipewallet.backend.repository.AccountRepository;
import com.recipewallet.backend.repository.CategoryRepository;
import com.recipewallet.backend.repository.TransactionRepository;
import com.recipewallet.backend.repository.ReceiptTaskRepository;
import com.recipewallet.backend.service.llm.LlmClient;
import com.recipewallet.backend.service.ocr.OcrClient;
import com.recipewallet.backend.service.storage.StorageClient;
import lombok.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReceiptProcessingService {

    private final OcrClient ocrClient;
    private final LlmClient llmClient;
    private final LangfuseTracingService langfuseTracingService;
    private final StorageClient storageClient;
    private final TransactionRepository transactionRepository;
    private final CategoryRepository categoryRepository;
    private final AccountRepository accountRepository;
    private final ReceiptTaskRepository receiptTaskRepository;
    private final ObjectMapper objectMapper = new ObjectMapper().registerModule(new JavaTimeModule());

    @Value("${recipewallet.llm.model:google/gemma-3-27b-it}")
    private String llmModel;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExtractedData {
        private String merchant;
        private String merchantAddress;
        private Double totalAmount;
        private String rawText;
        private List<ItemDto> items;
        private String category;
        private LocalDateTime transactionDate;
        private String currency;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ItemDto {
        private String name;
        private Double price;
        private Integer qty;
    }

    @Data
    @AllArgsConstructor
    public static class ExtractedDataAndOcr {
        private ExtractedData data;
        private String rawText;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public ReceiptTask acquireNextTask() {
        java.util.Optional<ReceiptTask> opt = receiptTaskRepository.findNextTaskForUpdate();
        if (opt.isPresent()) {
            ReceiptTask task = opt.get();
            task.setStatus(com.recipewallet.backend.model.TaskStatus.PROCESSING);
            task.setStartedAt(LocalDateTime.now());
            return receiptTaskRepository.save(task);
        }
        return null;
    }

    public ExtractedDataAndOcr performOcrAndLlm(MultipartFile file, Long transactionId, User user) {
        log.info("Starting OCR and LLM processing for transaction ID: {}", transactionId);
        String userIdStr = user != null ? user.getId().toString() : "system";
        String traceId = langfuseTracingService.startTrace("receipt-extraction", userIdStr,
                "File: " + (file.getOriginalFilename() != null ? file.getOriginalFilename() : "unknown"));
        try {
            // Perform OCR text extraction
            String rawText = "";
            try {
                rawText = ocrClient.extractText(file);
                langfuseTracingService.logSpan(traceId, "ocr-extraction", file.getOriginalFilename(), rawText);
            } catch (IOException e) {
                log.error("Failed to perform OCR extraction: {}", e.getMessage(), e);
                rawText = "Failed OCR extraction from file: "
                        + (file.getOriginalFilename() != null ? file.getOriginalFilename() : "unknown");
                langfuseTracingService.logSpan(traceId, "ocr-extraction", file.getOriginalFilename(), rawText);
            }

            // Build prompt for LLM parsing
            String prompt = "You are a professional receipt parser. Analyze the following OCR raw text from a receipt and output a JSON object containing the fields below. "
                    + "Do NOT output any markdown tags, wrappers, explanation, or commentary. Output ONLY the raw JSON object.\n\n"
                    + "JSON Schema:\n" +
                    "{\n" +
                    "  \"merchant\": \"Name of the store or merchant (String)\",\n" +
                    "  \"merchantAddress\": \"Full street address of the store (String, optional)\",\n" +
                    "  \"totalAmount\": 12.34 (Double, representing total price paid),\n" +
                    "  \"currency\": \"3-letter ISO-4217 currency code (String, e.g., USD, EUR, GBP, UZS, etc.)\",\n" +
                    "  \"category\": \"Choose one of: Cafes & Dining, Groceries, Transport, Entertainment, Shopping, Bills & Utilities, Other\",\n"
                    +
                    "  \"items\": [\n" +
                    "    {\"name\": \"item name (String)\", \"price\": 1.99 (Double), \"qty\": 1 (Integer)}\n" +
                    "  ],\n" +
                    "  \"transactionDate\": \"The date/time of transaction in ISO-8601 format (YYYY-MM-DDTHH:MM:SS) (String, optional)\"\n"
                    + "}\n\n" +
                    "Receipt Raw Text:\n" +
                    rawText;

            String llmResponse = llmClient.generate(prompt);
            langfuseTracingService.logGeneration(traceId, "parse-receipt", llmModel, prompt, llmResponse);

            String cleanedResponse = cleanLlmResponse(llmResponse);
            ExtractedData data = objectMapper.readValue(cleanedResponse, ExtractedData.class);
            if (data.getTransactionDate() == null) {
                data.setTransactionDate(LocalDateTime.now());
            }
            langfuseTracingService.endTrace(traceId, cleanedResponse);

            return new ExtractedDataAndOcr(data, rawText);
        } catch (Exception e) {
            langfuseTracingService.endTrace(traceId, "Processing failed: " + e.getMessage());
            throw new RuntimeException("Receipt extraction failed", e);
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void finalizeTransaction(Long transactionId, ExtractedDataAndOcr result, Long taskId) {
        ReceiptTask task = receiptTaskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found: " + taskId));

        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("Transaction not found: " + transactionId));

        ExtractedData data = result.getData();
        String rawText = result.getRawText();

        // Set OCR text
        if (rawText != null && !rawText.isEmpty()) {
            ReceiptOcr receiptOcr = ReceiptOcr.builder()
                    .rawText(rawText)
                    .transaction(transaction)
                    .build();
            transaction.setReceiptOcr(receiptOcr);
        }

        // Update fields from successfully parsed data
        transaction.setMerchant(data.getMerchant());
        transaction.setMerchantAddress(data.getMerchantAddress());
        transaction.setTotalAmount(data.getTotalAmount());
        if (data.getCurrency() != null && !data.getCurrency().isEmpty()) {
            transaction.setCurrency(data.getCurrency());
        }

        if (data.getCategory() != null && !data.getCategory().isEmpty()) {
            String clean = data.getCategory().replace("\"", "").trim();
            User user = transaction.getUser();
            Category cat = categoryRepository.findByUserAndName(user, clean)
                    .orElseGet(() -> categoryRepository.save(Category.builder().name(clean).user(user).build()));
            transaction.setCategories(new java.util.ArrayList<>(java.util.List.of(cat)));
        }

        if (data.getTransactionDate() != null) {
            transaction.setTransactionDate(data.getTransactionDate());
        }
        transaction.setDraft(false);

        // Check for duplicate by metadata (merchant + total price + date within the
        // same day)
        if (!transaction.isPossibleDuplicate() && transaction.getTotalAmount() != null
                && transaction.getTransactionDate() != null) {
            User user = transaction.getUser();
            List<Transaction> matchingAmountTxs = transactionRepository.findByUserAndTotalAmountAndIsDraftFalse(user,
                    transaction.getTotalAmount());
            for (Transaction existingTx : matchingAmountTxs) {
                if (existingTx.getId().equals(transaction.getId())) {
                    continue;
                }
                if (existingTx.getTransactionDate() != null) {
                    if (existingTx.getTransactionDate().toLocalDate()
                            .isEqual(transaction.getTransactionDate().toLocalDate())) {
                        String extMerchant = transaction.getMerchant();
                        String extMerchantLower = extMerchant != null ? extMerchant.toLowerCase().trim() : "";
                        String existingMerchantLower = existingTx.getMerchant() != null
                                ? existingTx.getMerchant().toLowerCase().trim()
                                : "";

                        if (!extMerchantLower.isEmpty() && !existingMerchantLower.isEmpty()) {
                            if (extMerchantLower.contains(existingMerchantLower)
                                    || existingMerchantLower.contains(extMerchantLower)) {
                                transaction.setPossibleDuplicate(true);
                                transaction.setDuplicateOfId(existingTx.getId());
                                log.info(
                                        "Duplicate transaction detected via metadata check. Original transaction ID: {}",
                                        existingTx.getId());
                                break;
                            }
                        }
                    }
                }
            }
        }

        // Set items
        if (data.getItems() != null) {
            transaction.getItems().clear();
            for (ItemDto item : data.getItems()) {
                transaction.getItems().add(TransactionItem.builder()
                        .name(item.getName())
                        .price(item.getPrice())
                        .qty(item.getQty())
                        .transaction(transaction)
                        .build());
            }
        }

        Transaction savedTx = transactionRepository.save(transaction);

        // Deduct from account balance
        if (savedTx.getFromAccount() != null && savedTx.getTotalAmount() != null) {
            Account fromAcc = savedTx.getFromAccount();
            java.math.BigDecimal amount = java.math.BigDecimal.valueOf(savedTx.getTotalAmount());
            fromAcc.setBalance(fromAcc.getBalance().subtract(amount));
            accountRepository.save(fromAcc);
        }

        task.setStatus(com.recipewallet.backend.model.TaskStatus.COMPLETED);
        task.setCompletedAt(LocalDateTime.now());
        receiptTaskRepository.save(task);
        log.info("Successfully completed async receipt processing task ID: {} for transaction ID: {}", taskId,
                transactionId);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void failTransaction(Long transactionId, Long taskId, String errorMessage) {
        ReceiptTask task = receiptTaskRepository.findById(taskId).orElse(null);
        if (task != null) {
            task.setStatus(com.recipewallet.backend.model.TaskStatus.FAILED);
            task.setErrorLog(errorMessage);
            task.setCompletedAt(LocalDateTime.now());
            receiptTaskRepository.save(task);
        }

        Transaction transaction = transactionRepository.findById(transactionId).orElse(null);
        if (transaction != null) {
            transaction.setMerchant("Processing Failed");
            transaction.setDraft(false);
            transactionRepository.save(transaction);
        }
        log.warn("Marked task ID: {} and transaction ID: {} as FAILED. Reason: {}", taskId, transactionId,
                errorMessage);
    }

    private String cleanLlmResponse(String response) {
        if (response == null) {
            return "{}";
        }
        String cleaned = response.trim();
        int start = cleaned.indexOf('{');
        int end = cleaned.lastIndexOf('}');
        if (start != -1 && end != -1 && start < end) {
            cleaned = cleaned.substring(start, end + 1);
        } else {
            if (cleaned.startsWith("```json")) {
                cleaned = cleaned.substring(7);
            } else if (cleaned.startsWith("```")) {
                cleaned = cleaned.substring(3);
            }
            if (cleaned.endsWith("```")) {
                cleaned = cleaned.substring(0, cleaned.length() - 3);
            }
        }
        return cleaned.trim();
    }

    private String calculateSha256(MultipartFile file) {
        try {
            byte[] bytes = file.getBytes();
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(bytes);
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1)
                    hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            log.error("Failed to calculate SHA-256 hash", e);
            return null;
        }
    }
}
