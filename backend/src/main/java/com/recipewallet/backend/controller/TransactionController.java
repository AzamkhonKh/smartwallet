package com.recipewallet.backend.controller;

import com.recipewallet.backend.dto.TransactionItemResponseDto;
import com.recipewallet.backend.dto.TransactionRequestDto;
import com.recipewallet.backend.dto.TransactionResponseDto;
import com.recipewallet.backend.dto.TransactionItemRequestDto;
import com.recipewallet.backend.exception.AccessDeniedException;
import com.recipewallet.backend.exception.DuplicateReceiptException;
import com.recipewallet.backend.exception.ResourceNotFoundException;
import com.recipewallet.backend.model.Account;
import com.recipewallet.backend.model.AccountType;
import com.recipewallet.backend.model.Category;
import com.recipewallet.backend.model.Transaction;
import com.recipewallet.backend.model.TransactionItem;
import com.recipewallet.backend.model.User;
import com.recipewallet.backend.repository.AccountRepository;
import com.recipewallet.backend.repository.CategoryRepository;
import com.recipewallet.backend.repository.TransactionItemRepository;
import com.recipewallet.backend.repository.TransactionRepository;
import com.recipewallet.backend.repository.ReceiptTaskRepository;
import com.recipewallet.backend.model.ReceiptTask;
import com.recipewallet.backend.model.TaskStatus;
import com.recipewallet.backend.service.storage.StorageClient;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.UUID;
import com.recipewallet.backend.util.InMemoryMultipartFile;
import com.recipewallet.backend.service.ReceiptProcessingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
@Slf4j
public class TransactionController {

    private final TransactionRepository transactionRepository;
    private final CategoryRepository categoryRepository;
    private final AccountRepository accountRepository;
    private final TransactionItemRepository transactionItemRepository;
    private final ReceiptProcessingService receiptProcessingService;
    private final com.recipewallet.backend.service.CurrencyService currencyService;
    private final ReceiptTaskRepository receiptTaskRepository;
    private final StorageClient storageClient;

    @GetMapping
    public ResponseEntity<List<TransactionResponseDto>> getTransactions(@AuthenticationPrincipal User user) {
        List<Transaction> transactions = transactionRepository.findByUserOrderByTransactionDateDesc(user);
        return ResponseEntity.ok(transactions.stream().map(this::toResponseDto).toList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<TransactionResponseDto> getTransaction(@PathVariable("id") Long id,
            @AuthenticationPrincipal User user) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with id: " + id));

        if (!transaction.getUser().getId().equals(user.getId())) {
            throw new AccessDeniedException("You do not have permission to access this transaction.");
        }

        return ResponseEntity.ok(toResponseDto(transaction));
    }

    private TransactionResponseDto processSingleUpload(MultipartFile file, String precalculatedHash,
            String fromAccountId, User user) {
        // Validate file size and extension
        if (file.getSize() > 10 * 1024 * 1024) {
            throw new IllegalArgumentException("File size exceeds 10 MB limit: " + file.getOriginalFilename());
        }
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || !originalFilename.contains(".")) {
            throw new IllegalArgumentException("Invalid file name: " + originalFilename);
        }
        String extension = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        if (!extension.equals("png") && !extension.equals("jpg") && !extension.equals("jpeg")) {
            throw new IllegalArgumentException(
                    "Unsupported file extension: ." + extension + ". Allowed: .png, .jpg, .jpeg");
        }

        // 1. Calculate SHA-256 hash synchronously if not precalculated
        String imageHash = precalculatedHash;
        if (imageHash == null) {
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
                imageHash = hexString.toString();
            } catch (Exception e) {
                throw new RuntimeException("Failed to calculate SHA-256 hash", e);
            }
        }

        // 2. Perform duplicate check synchronously (skip if exists)
        if (imageHash != null && !imageHash.isEmpty()) {
            if (transactionRepository.existsByUserAndImageHash(user, imageHash)) {
                log.info("Duplicate receipt detected by image hash. Skipping transaction creation for hash: {}",
                        imageHash);
                throw new DuplicateReceiptException("This receipt has already been uploaded (duplicate image detected).");
            }
        }

        // 3. Upload image to storage synchronously
        String imageUrl = null;
        try {
            imageUrl = storageClient.upload(file);
        } catch (java.io.IOException e) {
            log.error("Storage upload failed for file {}: {}", file.getOriginalFilename(), e.getMessage(), e);
            throw new RuntimeException("Failed to upload receipt image. Please try again later.", e);
        }

        Account fromAcc = null;
        if (fromAccountId != null && !fromAccountId.isEmpty()) {
            fromAcc = accountRepository.findById(fromAccountId).orElse(null);
        }
        if (fromAcc == null) {
            fromAcc = getOrCreateDefaultAccount(user);
        }

        // 4. Save the initial draft Transaction
        Transaction transaction = Transaction.builder()
                .merchant("Processing...")
                .isDraft(true)
                .fromAccount(fromAcc)
                .user(user)
                .imageUrl(imageUrl)
                .imageHash(imageHash)
                .isPossibleDuplicate(false)
                .duplicateOfId(null)
                .build();

        Transaction savedTransaction = transactionRepository.save(transaction);

        // 5. Insert a ReceiptTask database record
        ReceiptTask task = ReceiptTask.builder()
                .transactionId(savedTransaction.getId())
                .imageUrl(imageUrl)
                .imageHash(imageHash)
                .fileName(file.getOriginalFilename())
                .contentType(file.getContentType())
                .status(TaskStatus.PENDING)
                .user(user)
                .build();

        receiptTaskRepository.save(task);

        return toResponseDto(savedTransaction);
    }

    @Operation(summary = "Upload receipt image for OCR and extraction")
    @PostMapping(value = "/upload", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    @Transactional
    public ResponseEntity<TransactionResponseDto> uploadReceipt(
            @Parameter(description = "Receipt image file to extract data from", required = true) @RequestPart("file") MultipartFile file,
            @RequestParam(value = "fromAccountId", required = false) String fromAccountId,
            @AuthenticationPrincipal User user) {
        // processSingleUpload throws DuplicateReceiptException on duplicate — no null check needed
        TransactionResponseDto response = processSingleUpload(file, null, fromAccountId, user);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Upload multiple receipt images for batch OCR and extraction")
    @PostMapping(value = "/upload-batch", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    @Transactional
    public ResponseEntity<List<TransactionResponseDto>> uploadReceiptsBatch(
            @Parameter(description = "Receipt image files to extract data from", required = true) @RequestPart("files") List<MultipartFile> files,
            @RequestParam(value = "fromAccountId", required = false) String fromAccountId,
            @AuthenticationPrincipal User user) {

        List<TransactionResponseDto> responses = new java.util.ArrayList<>();
        java.util.Set<String> seenHashes = new java.util.HashSet<>();

        for (MultipartFile file : files) {
            if (file.isEmpty()) {
                continue;
            }

            // Calculate hash upfront for de-duplication inside the current batch
            String imageHash = null;
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
                imageHash = hexString.toString();
            } catch (Exception e) {
                throw new RuntimeException("Failed to calculate SHA-256 hash for batch file", e);
            }

            // If we've already seen this file in the current batch, skip it!
            if (seenHashes.contains(imageHash)) {
                log.warn("Skipping duplicate file in batch upload: {}", file.getOriginalFilename());
                continue;
            }
            seenHashes.add(imageHash);

            // Process and save the single upload
            TransactionResponseDto response = processSingleUpload(file, imageHash, fromAccountId, user);
            if (response != null) {
                responses.add(response);
            } else {
                log.info("Skipping duplicate file in batch upload: {} (hash already exists in database)",
                        file.getOriginalFilename());
            }
        }

        return ResponseEntity.ok(responses);
    }

    @PostMapping("/manual")
    public ResponseEntity<TransactionResponseDto> createManualTransaction(
            @RequestBody TransactionRequestDto transactionRequest,
            @AuthenticationPrincipal User user) {

        Account fromAcc = accountRepository.findById(transactionRequest.getFromAccountId())
                .orElseThrow(() -> new ResourceNotFoundException("Source account not found: " + transactionRequest.getFromAccountId()));
        Account toAcc = null;
        if (transactionRequest.getToAccountId() != null && !transactionRequest.getToAccountId().isEmpty()) {
            toAcc = accountRepository.findById(transactionRequest.getToAccountId())
                    .orElseThrow(() -> new ResourceNotFoundException("Destination account not found: " + transactionRequest.getToAccountId()));
        }

        Transaction transaction = Transaction.builder()
                .merchant(transactionRequest.getMerchant())
                .merchantAddress(transactionRequest.getMerchantAddress())
                .totalAmount(transactionRequest.getTotalAmount())
                .categories(resolveCategories(transactionRequest.getCategories(), user))
                .transactionDate(transactionRequest.getTransactionDate())
                .isDraft(transactionRequest.isDraft())
                .currency(transactionRequest.getCurrency())
                .fromAccount(fromAcc)
                .toAccount(toAcc)
                .user(user)
                .build();

        if (transaction.getItems() == null) {
            transaction.setItems(new java.util.ArrayList<>());
        }
        if (transactionRequest.getItems() != null) {
            for (TransactionItemRequestDto itemDto : transactionRequest.getItems()) {
                transaction.getItems().add(TransactionItem.builder()
                        .name(itemDto.getName())
                        .price(itemDto.getPrice())
                        .qty(itemDto.getQty())
                        .transaction(transaction)
                        .build());
            }
        }

        Transaction savedTransaction = transactionRepository.save(transaction);

        // Deduct/Transfer balances
        applyTransactionBalances(savedTransaction, false);

        return ResponseEntity.ok(toResponseDto(savedTransaction));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TransactionResponseDto> updateTransaction(
            @PathVariable("id") Long id,
            @RequestBody TransactionRequestDto transactionRequest,
            @AuthenticationPrincipal User user) {

        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with id: " + id));

        if (!transaction.getUser().getId().equals(user.getId())) {
            throw new AccessDeniedException("You do not have permission to update this transaction.");
        }

        // 1. Reverse the old balances impact
        applyTransactionBalances(transaction, true);

        // 2. Resolve new from/to accounts
        Account fromAcc = accountRepository.findById(transactionRequest.getFromAccountId())
                .orElseThrow(() -> new ResourceNotFoundException("Source account not found: " + transactionRequest.getFromAccountId()));
        Account toAcc = null;
        if (transactionRequest.getToAccountId() != null && !transactionRequest.getToAccountId().isEmpty()) {
            toAcc = accountRepository.findById(transactionRequest.getToAccountId())
                    .orElseThrow(() -> new ResourceNotFoundException("Destination account not found: " + transactionRequest.getToAccountId()));
        }

        // 3. Update fields
        transaction.setMerchant(transactionRequest.getMerchant());
        transaction.setMerchantAddress(transactionRequest.getMerchantAddress());
        transaction.setTotalAmount(transactionRequest.getTotalAmount());
        transaction.setCategories(resolveCategories(transactionRequest.getCategories(), user));
        transaction.setTransactionDate(transactionRequest.getTransactionDate());
        transaction.setDraft(transactionRequest.isDraft());
        transaction.setCurrency(transactionRequest.getCurrency());
        transaction.setFromAccount(fromAcc);
        transaction.setToAccount(toAcc);

        if (transaction.getItems() == null) {
            transaction.setItems(new java.util.ArrayList<>());
        }
        transaction.getItems().clear();
        if (transactionRequest.getItems() != null) {
            for (TransactionItemRequestDto itemDto : transactionRequest.getItems()) {
                transaction.getItems().add(TransactionItem.builder()
                        .name(itemDto.getName())
                        .price(itemDto.getPrice())
                        .qty(itemDto.getQty())
                        .transaction(transaction)
                        .build());
            }
        }

        Transaction savedTransaction = transactionRepository.save(transaction);

        // 4. Apply the new balances impact
        applyTransactionBalances(savedTransaction, false);

        return ResponseEntity.ok(toResponseDto(savedTransaction));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTransaction(@PathVariable("id") Long id, @AuthenticationPrincipal User user) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with id: " + id));

        if (!transaction.getUser().getId().equals(user.getId())) {
            throw new AccessDeniedException("You do not have permission to delete this transaction.");
        }

        // Reverse balances impact before deleting
        applyTransactionBalances(transaction, true);

        transactionRepository.delete(transaction);

        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/keep-both")
    public ResponseEntity<TransactionResponseDto> keepBoth(
            @PathVariable("id") Long id,
            @AuthenticationPrincipal User user) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with id: " + id));

        if (!transaction.getUser().getId().equals(user.getId())) {
            throw new AccessDeniedException("You do not have permission to modify this transaction.");
        }

        transaction.setPossibleDuplicate(false);
        transaction.setDuplicateOfId(null);

        Transaction saved = transactionRepository.save(transaction);
        return ResponseEntity.ok(toResponseDto(saved));
    }

    private Account getOrCreateDefaultAccount(User user) {
        List<Account> accounts = accountRepository.findByUser(user);
        if (accounts.isEmpty()) {
            Account defaultAccount = Account.builder()
                    .id(UUID.randomUUID().toString())
                    .name("Primary Wallet")
                    .type(AccountType.CASH_WALLET)
                    .balance(BigDecimal.valueOf(1000.00))
                    .currency("USD")
                    .user(user)
                    .build();
            return accountRepository.save(defaultAccount);
        }
        return accounts.get(0);
    }

    private List<Category> resolveCategories(List<String> names, User user) {
        List<Category> list = new java.util.ArrayList<>();
        if (names != null) {
            for (String name : names) {
                String clean = name.replace("\"", "").trim();
                Category cat = categoryRepository.findByUserAndName(user, clean)
                        .orElseGet(() -> categoryRepository.save(Category.builder().name(clean).user(user).build()));
                list.add(cat);
            }
        }
        return list;
    }

    private void applyTransactionBalances(Transaction tx, boolean isDelete) {
        if (tx.getFromAccount() != null) {
            BigDecimal amount = BigDecimal.valueOf(tx.getTotalAmount() != null ? tx.getTotalAmount() : 0.0);
            Account fromAcc = tx.getFromAccount();
            if (isDelete) {
                fromAcc.setBalance(fromAcc.getBalance().add(amount));
            } else {
                fromAcc.setBalance(fromAcc.getBalance().subtract(amount));
            }
            accountRepository.save(fromAcc);
        }
        if (tx.getToAccount() != null) {
            BigDecimal amount = BigDecimal.valueOf(tx.getTotalAmount() != null ? tx.getTotalAmount() : 0.0);
            Account toAcc = tx.getToAccount();
            if (isDelete) {
                toAcc.setBalance(toAcc.getBalance().subtract(amount));
            } else {
                toAcc.setBalance(toAcc.getBalance().add(amount));
            }
            accountRepository.save(toAcc);
        }
    }

    private TransactionResponseDto toResponseDto(Transaction tx) {
        if (tx == null)
            return null;

        String primaryCurrency = (tx.getUser() != null && tx.getUser().getPrimaryCurrency() != null)
                ? tx.getUser().getPrimaryCurrency()
                : "USD";
        String txCurrency = tx.getCurrency() != null ? tx.getCurrency() : "USD";

        List<TransactionItemResponseDto> items = java.util.Collections.emptyList();
        if (tx.getItems() != null) {
            items = tx.getItems().stream()
                    .map(item -> {
                        Double price = item.getPrice() != null ? item.getPrice() : 0.0;
                        Double convertedPrice = currencyService.convert(price, txCurrency, primaryCurrency);
                        return TransactionItemResponseDto.builder()
                                .id(item.getId())
                                .name(item.getName())
                                .price(price)
                                .convertedPrice(convertedPrice)
                                .qty(item.getQty())
                                .build();
                    })
                    .toList();
        }

        List<String> categories = java.util.Collections.emptyList();
        if (tx.getCategories() != null) {
            categories = tx.getCategories().stream().map(Category::getName).toList();
        }

        Double totalAmt = tx.getTotalAmount() != null ? tx.getTotalAmount() : 0.0;
        Double convertedAmount = currencyService.convert(totalAmt, txCurrency, primaryCurrency);

        return TransactionResponseDto.builder()
                .id(tx.getId())
                .merchant(tx.getMerchant())
                .merchantAddress(tx.getMerchantAddress())
                .totalAmount(tx.getTotalAmount())
                .categories(categories)
                .imageUrl(tx.getImageUrl())
                .transactionDate(tx.getTransactionDate())
                .isDraft(tx.isDraft())
                .isPossibleDuplicate(tx.isPossibleDuplicate())
                .duplicateOfId(tx.getDuplicateOfId())
                .items(items)
                .suggestions(tx.getSuggestions())
                .currency(tx.getCurrency())
                .convertedAmount(convertedAmount)
                .primaryCurrency(primaryCurrency)
                .fromAccountId(tx.getFromAccount() != null ? tx.getFromAccount().getId() : null)
                .fromAccountName(tx.getFromAccount() != null ? tx.getFromAccount().getName() : null)
                .toAccountId(tx.getToAccount() != null ? tx.getToAccount().getId() : null)
                .toAccountName(tx.getToAccount() != null ? tx.getToAccount().getName() : null)
                .build();
    }
}
