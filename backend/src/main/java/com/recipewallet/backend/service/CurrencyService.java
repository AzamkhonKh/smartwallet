package com.recipewallet.backend.service;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.recipewallet.backend.model.CurrencyRate;
import com.recipewallet.backend.repository.CurrencyRateRepository;
import jakarta.annotation.PostConstruct;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class CurrencyService {

    private final CurrencyRateRepository currencyRateRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${exchagerate.api-key:}")
    private String apiKey;

    // Default fallback rates relative to USD (1 USD = rate)
    private static final Map<String, Double> FALLBACK_RATES = Map.of(
            "USD", 1.0,
            "EUR", 0.92,
            "GBP", 0.78,
            "UZS", 12650.0,
            "CAD", 1.36,
            "AUD", 1.50,
            "JPY", 156.0,
            "CHF", 0.90,
            "CNY", 7.25,
            "RUB", 89.0
    );

    @Data
    public static class ExchangeRateApiResponse {
        private String result;
        
        @JsonProperty("base_code")
        private String baseCode;
        
        @JsonProperty("conversion_rates")
        private Map<String, Double> conversionRates;
    }

    @PostConstruct
    public void init() {
        // Run initial rate sync in a background thread to prevent blocking Spring container startup
        new Thread(this::updateRates).start();
    }

    // Update rates daily at 1:00 AM
    @Scheduled(cron = "0 0 1 * * ?")
    public void updateRates() {
        log.info("Starting currency exchange rates synchronization...");
        Map<String, Double> rates = new HashMap<>();

        String cleanKey = apiKey != null ? apiKey.trim().replace("\"", "").replace("'", "") : "";
        if (!cleanKey.isEmpty()) {
            try {
                String url = String.format("https://v6.exchangerate-api.com/v6/%s/latest/USD", cleanKey);
                log.info("Fetching latest exchange rates from ExchangeRate-API...");
                ExchangeRateApiResponse response = restTemplate.getForObject(url, ExchangeRateApiResponse.class);
                
                if (response != null && "success".equalsIgnoreCase(response.getResult()) && response.getConversionRates() != null) {
                    rates.putAll(response.getConversionRates());
                    log.info("Successfully fetched {} exchange rates relative to USD.", rates.size());
                } else {
                    log.warn("ExchangeRate-API response indicated failure or was empty. Using fallback rates.");
                }
            } catch (Exception e) {
                log.error("Failed to connect or fetch from ExchangeRate-API: {}. Using fallback rates.", e.getMessage());
            }
        } else {
            log.info("ExchangeRate-API key is not configured. Using default fallback rates.");
        }

        // If API fetch failed or was skipped, populate with fallback rates
        if (rates.isEmpty()) {
            rates.putAll(FALLBACK_RATES);
        }

        // Save/Update rates in database
        try {
            LocalDateTime now = LocalDateTime.now();
            for (Map.Entry<String, Double> entry : rates.entrySet()) {
                String code = entry.getKey().toUpperCase();
                Double rateValue = entry.getValue();
                
                CurrencyRate currencyRate = CurrencyRate.builder()
                        .currencyCode(code)
                        .rate(rateValue)
                        .lastUpdated(now)
                        .build();
                currencyRateRepository.save(currencyRate);
            }
            log.info("Successfully persisted currency rates in the database.");
        } catch (Exception e) {
            log.error("Failed to save currency rates to the database: {}", e.getMessage(), e);
        }
    }

    public java.util.List<CurrencyRate> getAllRates() {
        return currencyRateRepository.findAll();
    }

    /**
     * Converts an amount from source currency to target currency.
     * Conversion formula: amountInTarget = amountInSource * (rate(Target) / rate(Source))
     */
    public Double convert(Double amount, String fromCurrency, String toCurrency) {
        if (amount == null) {
            return 0.0;
        }
        if (fromCurrency == null || toCurrency == null) {
            return amount;
        }
        
        String fromCode = fromCurrency.toUpperCase().trim();
        String toCode = toCurrency.toUpperCase().trim();

        if (fromCode.equals(toCode)) {
            return amount;
        }

        Double rateFrom = getRate(fromCode);
        Double rateTo = getRate(toCode);

        return amount * (rateTo / rateFrom);
    }

    private Double getRate(String currencyCode) {
        // 1. Try database
        try {
            Optional<CurrencyRate> dbRate = currencyRateRepository.findById(currencyCode);
            if (dbRate.isPresent()) {
                return dbRate.get().getRate();
            }
        } catch (Exception e) {
            log.warn("Database lookup failed for currency code {}: {}", currencyCode, e.getMessage());
        }

        // 2. Try static fallback rates map
        if (FALLBACK_RATES.containsKey(currencyCode)) {
            return FALLBACK_RATES.get(currencyCode);
        }

        // 3. Absolute default
        log.warn("Unknown currency code {}. Defaulting rate relative to USD to 1.0", currencyCode);
        return 1.0;
    }
}
