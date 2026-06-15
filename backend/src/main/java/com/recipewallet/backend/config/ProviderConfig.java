package com.recipewallet.backend.config;

import com.recipewallet.backend.service.llm.LlmClient;
import com.recipewallet.backend.service.llm.MockLlmClient;
import com.recipewallet.backend.service.llm.MistralLlmClient;
import com.recipewallet.backend.service.llm.OpenRouterLlmClient;
import com.recipewallet.backend.service.ocr.OcrClient;
import com.recipewallet.backend.service.ocr.MockOcrClient;
import com.recipewallet.backend.service.ocr.MistralOcrClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ProviderConfig {

    @Value("${recipewallet.ocr.provider:mock}")
    private String ocrProvider;

    @Value("${recipewallet.llm.provider:mock}")
    private String llmProvider;

    @Value("${recipewallet.llm.model:google/gemma-3-27b-it}")
    private String llmModel;

    @Value("${recipewallet.storage.provider:mock}")
    private String storageProvider;

    @Value("${openrouter.api-key:}")
    private String openrouterApiKey;

    @Value("${mistral.api-key:}")
    private String mistralApiKey;

    @Bean
    public OcrClient ocrClient() {
        if ("mistral".equalsIgnoreCase(ocrProvider)) {
            if (mistralApiKey == null || mistralApiKey.trim().isEmpty()) {
                throw new IllegalArgumentException("Mistral API key is not configured for OCR");
            }
            return new MistralOcrClient(mistralApiKey);
        }
        return new MockOcrClient();
    }

    @Bean
    public LlmClient llmClient() {
        if ("openrouter".equalsIgnoreCase(llmProvider)) {
            if (openrouterApiKey == null || openrouterApiKey.trim().isEmpty()) {
                throw new IllegalArgumentException("OpenRouter API key is not configured");
            }
            return new OpenRouterLlmClient(openrouterApiKey, llmModel);
        } else if ("mistral".equalsIgnoreCase(llmProvider)) {
            if (mistralApiKey == null || mistralApiKey.trim().isEmpty()) {
                throw new IllegalArgumentException("Mistral API key is not configured");
            }
            return new MistralLlmClient(mistralApiKey, llmModel);
        }
        return new MockLlmClient();
    }

    @Bean
    public com.recipewallet.backend.service.storage.StorageClient storageClient() {
        if ("firebase".equalsIgnoreCase(storageProvider)) {
            return new com.recipewallet.backend.service.storage.FirebaseStorageClient();
        } else if ("disk".equalsIgnoreCase(storageProvider)) {
            return new com.recipewallet.backend.service.storage.DiskStorageClient();
        }
        return new com.recipewallet.backend.service.storage.MockStorageClient();
    }
}
