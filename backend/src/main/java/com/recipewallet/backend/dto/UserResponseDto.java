package com.recipewallet.backend.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponseDto {
    private Long id;
    private String email;
    private String phoneNumber;
    private String name;
    private String primaryCurrency;
    private LocalDateTime dateJoined;
}
