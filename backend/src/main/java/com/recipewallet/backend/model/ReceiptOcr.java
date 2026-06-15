package com.recipewallet.backend.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "receipt_ocrs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReceiptOcr {

    @Id
    private Long transactionId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "transaction_id")
    private Transaction transaction;

    @Column(columnDefinition = "TEXT")
    private String rawText;
}
