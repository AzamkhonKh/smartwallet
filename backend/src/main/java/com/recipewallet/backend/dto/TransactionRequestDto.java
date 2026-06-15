package com.recipewallet.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionRequestDto {
    private String merchant;
    private String merchantAddress;
    private Double totalAmount;
    private List<String> categories;
    private LocalDateTime transactionDate;
    private String currency;
    private List<TransactionItemRequestDto> items;
    private String fromAccountId;
    private String toAccountId;
    
    @JsonProperty("isDraft")
    private boolean isDraft;

    @JsonProperty("isDraft")
    public boolean isDraft() {
        return isDraft;
    }

    public void setDraft(boolean isDraft) {
        this.isDraft = isDraft;
    }
}
