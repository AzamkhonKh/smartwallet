package com.recipewallet.backend.service.ocr;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Base64;
import java.util.Map;

@RequiredArgsConstructor
public class MistralOcrClient implements OcrClient {

    private final String apiKey;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String extractText(MultipartFile file) throws IOException {
        try {
            byte[] fileBytes = file.getBytes();
            String base64Image = Base64.getEncoder().encodeToString(fileBytes);
            String contentType = file.getContentType() != null ? file.getContentType() : "image/jpeg";
            String dataUrl = "data:" + contentType + ";base64," + base64Image;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            Map<String, Object> documentMap = Map.of(
                    "type", "image_url",
                    "image_url", dataUrl);

            Map<String, Object> requestBody = Map.of(
                    "model", "mistral-ocr-latest",
                    "document", documentMap,
                    "include_image_base64", true);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(
                    "https://api.mistral.ai/v1/ocr",
                    entity,
                    String.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode root = objectMapper.readTree(response.getBody());
                JsonNode pages = root.path("pages");
                StringBuilder sb = new StringBuilder();
                if (pages.isArray()) {
                    for (JsonNode page : pages) {
                        sb.append(page.path("markdown").asText()).append("\n");
                    }
                }
                return sb.toString().trim();
            } else {
                throw new RuntimeException("Mistral OCR API returned error status: " + response.getStatusCode());
            }
        } catch (Exception e) {
            throw new IOException("Error calling Mistral OCR API: " + e.getMessage(), e);
        }
    }
}
