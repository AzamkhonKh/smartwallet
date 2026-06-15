package com.recipewallet.backend.service;

import com.recipewallet.backend.model.Category;
import com.recipewallet.backend.model.Transaction;
import com.recipewallet.backend.service.llm.LlmClient;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RecipeReaderService {

    private final LlmClient llmClient;
    private final LangfuseTracingService langfuseTracingService;

    @Value("${recipewallet.llm.model:google/gemma-3-27b-it}")
    private String llmModel;

    public String getRecipeReaderSuggestions(Transaction transaction) {
        String merchant = transaction.getMerchant();
        Double total = transaction.getTotalAmount();
        String currency = transaction.getCurrency() != null ? transaction.getCurrency() : "USD";

        java.util.List<String> categories = java.util.Collections.emptyList();
        if (transaction.getCategories() != null) {
            categories = transaction.getCategories().stream().map(Category::getName).toList();
        }

        // Construct a structured prompt for the LLM to get high-quality dynamic suggestions
        String prompt = String.format(
                "Analyze the following transaction. Generate specific, actionable, money-saving suggestions or energy conservation tips in clean markdown format. " +
                "If the category tags include Coffee, analyze the coffee habit and suggest home brewing. " +
                "If Groceries, advise on cheaper alternatives or discount grocers. " +
                "If Utilities, suggest energy conservation tips. " +
                "If Shopping, recommend the 24-hour waiting rule.\n\n" +
                "Transaction Detail:\n" +
                "- Merchant: %s\n" +
                "- Amount: %s %s\n" +
                "- Category Tags: %s\n\n" +
                "Generate the spending insights now:",
                merchant, total, currency, String.join(", ", categories)
        );

        String traceId = langfuseTracingService.startTrace(
                "recipe-suggestions",
                transaction.getUser() != null ? transaction.getUser().getId().toString() : "system",
                prompt
        );

        String response = llmClient.generate(prompt);

        langfuseTracingService.logGeneration(traceId, "generate-suggestions", llmModel, prompt, response);
        langfuseTracingService.endTrace(traceId, response);

        return response;
    }
}
