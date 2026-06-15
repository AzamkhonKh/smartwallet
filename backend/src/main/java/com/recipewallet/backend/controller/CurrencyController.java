package com.recipewallet.backend.controller;

import com.recipewallet.backend.model.CurrencyRate;
import com.recipewallet.backend.service.CurrencyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/currencies")
@RequiredArgsConstructor
public class CurrencyController {

    private final CurrencyService currencyService;

    @GetMapping("/rates")
    public ResponseEntity<List<CurrencyRate>> getRates() {
        return ResponseEntity.ok(currencyService.getAllRates());
    }
}
