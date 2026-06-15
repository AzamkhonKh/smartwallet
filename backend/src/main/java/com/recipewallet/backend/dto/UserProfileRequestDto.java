package com.recipewallet.backend.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileRequestDto {
    private String name;
    private String primaryCurrency;
}
