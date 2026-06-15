package com.recipewallet.backend.service.llm;

import java.time.LocalDateTime;

public class MockLlmClient implements LlmClient {

    @Override
    public String generate(String prompt) {
        String promptLower = prompt.toLowerCase();

        // 1. Receipt parsing detection (check if prompt asks for JSON formatting or contains raw receipt texts)
        if (promptLower.contains("json") || promptLower.contains("parse") || promptLower.contains("extract")) {
            if (promptLower.contains("starbucks") || promptLower.contains("latte")) {
                return "{\n" +
                        "  \"merchant\": \"Starbucks Coffee\",\n" +
                        "  \"merchantAddress\": \"123 Coffee Lane, Seattle, WA 98101\",\n" +
                        "  \"totalAmount\": 13.85,\n" +
                        "  \"currency\": \"USD\",\n" +
                        "  \"category\": \"Cafes & Dining\",\n" +
                        "  \"items\": [\n" +
                        "    {\"name\":\"Caffe Latte\",\"price\":4.75,\"qty\":1},\n" +
                        "    {\"name\":\"Butter Croissant\",\"price\":3.85,\"qty\":1},\n" +
                        "    {\"name\":\"Caramel Macchiato\",\"price\":5.25,\"qty\":1}\n" +
                        "  ],\n" +
                        "  \"transactionDate\": \"" + LocalDateTime.now().minusHours(2) + "\"\n" +
                        "}";
            } else if (promptLower.contains("whole foods") || promptLower.contains("grocery") || promptLower.contains("groceries")) {
                return "{\n" +
                        "  \"merchant\": \"Whole Foods Market\",\n" +
                        "  \"merchantAddress\": \"456 Grocery Boulevard, Austin, TX 78703\",\n" +
                        "  \"totalAmount\": 20.95,\n" +
                        "  \"currency\": \"USD\",\n" +
                        "  \"category\": \"Groceries\",\n" +
                        "  \"items\": [\n" +
                        "    {\"name\":\"Organic Milk\",\"price\":5.99,\"qty\":1},\n" +
                        "    {\"name\":\"Fresh Strawberries\",\"price\":4.49,\"qty\":1},\n" +
                        "    {\"name\":\"Whole Wheat Bread\",\"price\":3.49,\"qty\":1},\n" +
                        "    {\"name\":\"Cage-Free Eggs\",\"price\":4.99,\"qty\":1},\n" +
                        "    {\"name\":\"Avocado\",\"price\":1.99,\"qty\":1}\n" +
                        "  ],\n" +
                        "  \"transactionDate\": \"" + LocalDateTime.now().minusDays(1) + "\"\n" +
                        "}";
            } else if (promptLower.contains("pacific gas") || promptLower.contains("electricity") || promptLower.contains("pge")) {
                return "{\n" +
                        "  \"merchant\": \"Pacific Gas & Electric\",\n" +
                        "  \"merchantAddress\": \"789 Power Rd, San Francisco, CA 94105\",\n" +
                        "  \"totalAmount\": 84.20,\n" +
                        "  \"currency\": \"USD\",\n" +
                        "  \"category\": \"Bills & Utilities\",\n" +
                        "  \"items\": [\n" +
                        "    {\"name\":\"Electricity Usage (May 2026)\",\"price\":84.20,\"qty\":1}\n" +
                        "  ],\n" +
                        "  \"transactionDate\": \"" + LocalDateTime.now().minusDays(3) + "\"\n" +
                        "}";
            } else if (promptLower.contains("target") || promptLower.contains("walmart")) {
                return "{\n" +
                        "  \"merchant\": \"Target Stores\",\n" +
                        "  \"merchantAddress\": \"101 Retail Ave, Minneapolis, MN 55403\",\n" +
                        "  \"totalAmount\": 45.50,\n" +
                        "  \"currency\": \"USD\",\n" +
                        "  \"category\": \"Shopping\",\n" +
                        "  \"items\": [\n" +
                        "    {\"name\":\"T-Shirt\",\"price\":18.00,\"qty\":1},\n" +
                        "    {\"name\":\"Bluetooth Headphones\",\"price\":25.00,\"qty\":1}\n" +
                        "  ],\n" +
                        "  \"transactionDate\": \"" + LocalDateTime.now().minusDays(2) + "\"\n" +
                        "}";
            } else {
                return "{\n" +
                        "  \"merchant\": \"General Merchant\",\n" +
                        "  \"merchantAddress\": \"404 Main St, Anytown, US 90210\",\n" +
                        "  \"totalAmount\": 24.99,\n" +
                        "  \"currency\": \"USD\",\n" +
                        "  \"category\": \"Other\",\n" +
                        "  \"items\": [\n" +
                        "    {\"name\":\"Miscellaneous Items\",\"price\":24.99,\"qty\":1}\n" +
                        "  ],\n" +
                        "  \"transactionDate\": \"" + LocalDateTime.now() + "\"\n" +
                        "}";
            }
        }

        // 2. Budget suggestions detection
        StringBuilder sb = new StringBuilder();
        sb.append("### 🧠 Gemma 3n - Smart Spending Insight\n\n");

        if (promptLower.contains("coffee")) {
            sb.append("☕ **Coffee Habit Analysis:**\n");
            sb.append("You just spent money under the Coffee category.\n");
            sb.append("💡 **Gemma's Money-Saving Suggestion:**\n");
            sb.append("• Try brewing a Caffe Latte at home. Average home-brew cost is just **$0.85**, which would save you **$3.90** on this transaction!\n");
            sb.append("• Alternately, order a size 'Tall' instead of 'Grande' to save **15%** instantly.");
        } else if (promptLower.contains("grocery") || promptLower.contains("groceries")) {
            sb.append("🛒 **Grocery Cart Insights:**\n");
            sb.append("💡 **Gemma's Money-Saving Suggestion:**\n");
            sb.append("• Item Check: Organic Milk ($5.99) and Strawberries ($4.49) are priced premium here.\n");
            sb.append("• Buying these same items at a discount grocer (like ALDI or Trader Joe's) would save you approximately **$4.20 (20%)**.\n");
            sb.append("• Consider buying store-brand organic milk to save **$1.50** next trip.");
        } else if (promptLower.contains("utility") || promptLower.contains("utilities")) {
            sb.append("🔌 **Utility Bill Breakdown:**\n\n");
            sb.append("💡 **Gemma's Energy Conservation Tips:**\n");
            sb.append("• Run high-energy appliances (washers, dishwashers) after **7:00 PM** during off-peak hours to reduce electricity rates.\n");
            sb.append("• Unplug 'phantom load' electronics (like idle chargers and consoles) which consume up to **$8.00/month** in standby power.\n");
            sb.append("• Set your thermostat 2°F higher in summer and 2°F lower in winter to trim **5-8%** off your next bill.");
        } else if (promptLower.contains("shopping")) {
            sb.append("🛍️ **Shopping Habits Review:**\n\n");
            sb.append("💡 **Gemma's Smart Shopping Advice:**\n");
            sb.append("• Delay rule: Apply a **24-hour waiting rule** for non-essential clothing or electronics to see if you still want them.\n");
            sb.append("• Look for discount codes or online sales before buying in-store; Target price-matches its own website and select competitors!");
        } else {
            sb.append("📊 **Transaction Analysis:**\n\n");
            sb.append("💡 **Gemma's General Advice:**\n");
            sb.append("• Ensure all miscellaneous expenses are tagged properly so we can build an accurate spending profile for you.");
        }

        return sb.toString();
    }
}
