package com.recipewallet.backend.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@Slf4j
public class LangfuseTracingService {

    @Value("${LANGFUSE_PUBLIC_KEY:}")
    private String publicKey;

    @Value("${LANGFUSE_SECRET_KEY:}")
    private String secretKey;

    @Value("${LANGFUSE_BASE_URL:http://localhost:3000}")
    private String baseUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    private String cleanValue(String val) {
        if (val == null) return "";
        return val.trim().replace("\"", "").replace("'", "");
    }

    private HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String pub = cleanValue(publicKey);
        String sec = cleanValue(secretKey);
        if (!pub.isEmpty() && !sec.isEmpty()) {
            headers.setBasicAuth(pub, sec);
        }
        return headers;
    }

    private String getIngestionUrl() {
        String base = cleanValue(baseUrl);
        if (base.endsWith("/")) {
            base = base.substring(0, base.length() - 1);
        }
        return base + "/api/public/ingestion";
    }

    public String startTrace(String name, String userId, String input) {
        String traceId = UUID.randomUUID().toString();
        sendTraceCreate(traceId, name, userId, input);
        return traceId;
    }

    @Async
    public void sendTraceCreate(String traceId, String name, String userId, String input) {
        try {
            Map<String, Object> event = Map.of(
                    "id", UUID.randomUUID().toString(),
                    "type", "trace-create",
                    "timestamp", Instant.now().toString(),
                    "body", Map.of(
                            "id", traceId,
                            "name", name,
                            "userId", userId != null ? userId : "system",
                            "input", input != null ? input : ""
                    )
            );

            sendBatch(List.of(event));
        } catch (Exception e) {
            log.warn("Failed to send trace-create event to Langfuse", e);
        }
    }

    @Async
    public void logGeneration(String traceId, String name, String model, String input, String output) {
        try {
            Map<String, Object> event = Map.of(
                    "id", UUID.randomUUID().toString(),
                    "type", "observation-create",
                    "timestamp", Instant.now().toString(),
                    "body", Map.of(
                            "id", UUID.randomUUID().toString(),
                            "traceId", traceId,
                            "type", "GENERATION",
                            "name", name,
                            "model", model != null ? model : "unknown",
                            "input", input != null ? input : "",
                            "output", output != null ? output : ""
                    )
            );

            sendBatch(List.of(event));
        } catch (Exception e) {
            log.warn("Failed to send observation-create event to Langfuse", e);
        }
    }

    @Async
    public void logSpan(String traceId, String name, String input, String output) {
        try {
            Map<String, Object> event = Map.of(
                    "id", UUID.randomUUID().toString(),
                    "type", "observation-create",
                    "timestamp", Instant.now().toString(),
                    "body", Map.of(
                            "id", UUID.randomUUID().toString(),
                            "traceId", traceId,
                            "type", "SPAN",
                            "name", name,
                            "input", input != null ? input : "",
                            "output", output != null ? output : ""
                    )
            );

            sendBatch(List.of(event));
        } catch (Exception e) {
            log.warn("Failed to send observation-create SPAN event to Langfuse", e);
        }
    }

    @Async
    public void endTrace(String traceId, String output) {
        try {
            Map<String, Object> event = Map.of(
                    "id", UUID.randomUUID().toString(),
                    "type", "trace-create", // trace-create in batch also acts as update
                    "timestamp", Instant.now().toString(),
                    "body", Map.of(
                            "id", traceId,
                            "output", output != null ? output : ""
                    )
            );

            sendBatch(List.of(event));
        } catch (Exception e) {
            log.warn("Failed to send trace-update event to Langfuse", e);
        }
    }

    private void sendBatch(List<Map<String, Object>> batch) {
        String url = getIngestionUrl();
        HttpHeaders headers = createHeaders();
        Map<String, Object> payload = Map.of("batch", batch);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        try {
            restTemplate.postForEntity(url, entity, String.class);
        } catch (Exception e) {
            log.debug("Langfuse API call failed: {}", e.getMessage());
        }
    }
}
