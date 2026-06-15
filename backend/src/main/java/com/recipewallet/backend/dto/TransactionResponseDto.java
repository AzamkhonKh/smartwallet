package com.recipewallet.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponseDto {
    private Long id;
    private String merchant;
    private String merchantAddress;
    private Double totalAmount;
    private String rawText;
    private String structuredJson;
    private List<String> categories;
    private String imageUrl;
    private LocalDateTime transactionDate;
    
    @JsonProperty("isDraft")
    private boolean isDraft;

    @JsonProperty("isDraft")
    public boolean isDraft() {
        return isDraft;
    }

    public void setDraft(boolean isDraft) {
        this.isDraft = isDraft;
    }

    @JsonProperty("isPossibleDuplicate")
    private boolean isPossibleDuplicate;

    private Long duplicateOfId;

    private List<TransactionItemResponseDto> items;
    private String suggestions;
    private String currency;
    private Double convertedAmount;
    private String primaryCurrency;
    private String fromAccountId;
    private String fromAccountName;
    private String toAccountId;
    private String toAccountName;
}
