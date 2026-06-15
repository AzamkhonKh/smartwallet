package com.recipewallet.backend.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionItemResponseDto {
    private Long id;
    private String name;
    private Double price;
    private Double convertedPrice;
    private Integer qty;
}
