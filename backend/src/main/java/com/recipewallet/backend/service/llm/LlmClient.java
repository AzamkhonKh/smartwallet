package com.recipewallet.backend.service.llm;

public interface LlmClient {
    /**
     * Generates a response from the LLM based on the given prompt.
     * @param prompt the prompt to send to the LLM
     * @return the generated response text
     */
    String generate(String prompt);
}
