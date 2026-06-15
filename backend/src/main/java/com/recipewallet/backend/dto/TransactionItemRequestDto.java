package com.recipewallet.backend.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionItemRequestDto {
    private Long id;
    private String name;
    private Double price;
    private Integer qty;
}
