package com.recipewallet.backend.model;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import java.util.ArrayList;

import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String merchant;

    private String merchantAddress;

    @Column(name = "is_draft", nullable = false)
    @Builder.Default
    @JsonProperty("isDraft")
    private boolean isDraft = false;

    private Double totalAmount;

    @OneToOne(mappedBy = "transaction", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private ReceiptOcr receiptOcr;

    @OneToMany(mappedBy = "transaction", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<TransactionItem> items = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "transaction_categories",
        joinColumns = @JoinColumn(name = "transaction_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    @Builder.Default
    private List<Category> categories = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_account_id", nullable = false)
    private Account fromAccount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "to_account_id")
    private Account toAccount;

    private String imageUrl;

    @Column(columnDefinition = "TEXT")
    private String suggestions;

    private LocalDateTime transactionDate;

    private LocalDateTime dateCreated;

    private String currency;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String imageHash;

    @Column(name = "is_possible_duplicate", nullable = false)
    @Builder.Default
    private boolean isPossibleDuplicate = false;

    private Long duplicateOfId;

    @PrePersist
    protected void onCreate() {
        dateCreated = LocalDateTime.now();
        if (transactionDate == null) {
            transactionDate = LocalDateTime.now();
        }
        if (currency == null || currency.isEmpty()) {
            currency = "USD";
        }
    }
}
