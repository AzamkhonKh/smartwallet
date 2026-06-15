package com.recipewallet.backend.controller;

import com.recipewallet.backend.dto.AccountRequestDto;
import com.recipewallet.backend.dto.AccountResponseDto;
import com.recipewallet.backend.model.Account;
import com.recipewallet.backend.model.AccountType;
import com.recipewallet.backend.model.User;
import com.recipewallet.backend.repository.AccountRepository;
import com.recipewallet.backend.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/accounts")
@RequiredArgsConstructor
public class AccountController {

    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final com.recipewallet.backend.service.CurrencyService currencyService;

    @GetMapping
    public ResponseEntity<List<AccountResponseDto>> getAccounts(@AuthenticationPrincipal User user) {
        List<Account> accounts = accountRepository.findByUser(user);
        
        // Auto-initialize standard account if none exist
        if (accounts.isEmpty()) {
            Account defaultAccount = Account.builder()
                    .id(UUID.randomUUID().toString())
                    .name("Primary Wallet")
                    .type(AccountType.CASH_WALLET)
                    .balance(BigDecimal.valueOf(1000.00))
                    .currency("USD")
                    .user(user)
                    .build();
            accountRepository.save(defaultAccount);
            accounts = List.of(defaultAccount);
        }

        return ResponseEntity.ok(accounts.stream().map(this::toResponseDto).toList());
    }

    @PostMapping
    public ResponseEntity<AccountResponseDto> createAccount(
            @RequestBody AccountRequestDto request,
            @AuthenticationPrincipal User user) {

        Account account = Account.builder()
                .id(UUID.randomUUID().toString())
                .name(request.getName())
                .type(AccountType.valueOf(request.getType()))
                .balance(BigDecimal.valueOf(request.getBalance() != null ? request.getBalance() : 0.0))
                .currency(request.getCurrency() != null ? request.getCurrency() : "USD")
                .user(user)
                .build();

        Account saved = accountRepository.save(account);
        return ResponseEntity.ok(toResponseDto(saved));
    }

    @DeleteMapping("/{id}")
    @org.springframework.transaction.annotation.Transactional
    public ResponseEntity<?> deleteAccount(
            @PathVariable("id") String id,
            @AuthenticationPrincipal User user) {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Account not found"));

        if (!account.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(403).build();
        }

        if ("Primary Wallet".equalsIgnoreCase(account.getName())) {
            return ResponseEntity.badRequest().body("Cannot delete the primary account.");
        }

        List<Account> allAccounts = accountRepository.findByUser(user);
        if (allAccounts.size() <= 1) {
            return ResponseEntity.badRequest().body("Cannot delete the only remaining account.");
        }

        transactionRepository.deleteByAccount(account);
        accountRepository.delete(account);

        return ResponseEntity.ok().build();
    }

    private AccountResponseDto toResponseDto(Account account) {
        String primaryCurrency = (account.getUser() != null && account.getUser().getPrimaryCurrency() != null)
                ? account.getUser().getPrimaryCurrency()
                : "USD";
        Double balance = account.getBalance() != null ? account.getBalance().doubleValue() : 0.0;
        Double convertedBalance = currencyService.convert(balance, account.getCurrency(), primaryCurrency);

        return AccountResponseDto.builder()
                .id(account.getId())
                .name(account.getName())
                .type(account.getType().name())
                .balance(balance)
                .currency(account.getCurrency())
                .convertedBalance(convertedBalance)
                .primaryCurrency(primaryCurrency)
                .build();
    }
}
