package com.recipewallet.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "currency_rates")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CurrencyRate {

    @Id
    @Column(name = "currency_code", length = 3)
    private String currencyCode; // e.g. "USD", "EUR", "UZS"

    @Column(nullable = false)
    private Double rate; // Conversion rate relative to base USD (1 USD = rate)

    @Column(nullable = false)
    private LocalDateTime lastUpdated;
}
