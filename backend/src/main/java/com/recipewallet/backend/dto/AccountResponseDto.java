package com.recipewallet.backend.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountResponseDto {
    private String id;
    private String name;
    private String type;
    private Double balance;
    private String currency;
    private Double convertedBalance;
    private String primaryCurrency;
}
