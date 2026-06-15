package com.recipewallet.backend.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountRequestDto {
    private String name;
    private String type; // BANK_ACCOUNT, CASH_WALLET, etc.
    private Double balance;
    private String currency; // e.g. "USD"
}
