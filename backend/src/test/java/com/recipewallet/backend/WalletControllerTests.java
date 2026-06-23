package com.recipewallet.backend;

import com.recipewallet.backend.repository.CategoryRepository;
import com.recipewallet.backend.repository.AccountRepository;
import com.recipewallet.backend.repository.ReceiptTaskRepository;
import com.recipewallet.backend.repository.TransactionItemRepository;
import com.recipewallet.backend.repository.TransactionRepository;
import com.recipewallet.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
        "recipewallet.ocr.provider=mock",
        "recipewallet.llm.provider=mock",
        "recipewallet.storage.provider=mock"
})
@AutoConfigureMockMvc
class WalletControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private TransactionItemRepository transactionItemRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ReceiptTaskRepository receiptTaskRepository;

    @Autowired
    private org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setUp() {
        jdbcTemplate.execute("DROP TABLE IF EXISTS budgets CASCADE");
        receiptTaskRepository.deleteAll();
        transactionItemRepository.deleteAll();
        transactionRepository.deleteAll();
        categoryRepository.deleteAll();
        accountRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    void unauthenticatedRequestsReceive401() throws Exception {
        mockMvc.perform(get("/api/transactions"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/auth/me"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void authenticatedMockRequestCanFetchCurrentUserProfile() throws Exception {
        mockMvc.perform(get("/api/auth/me")
                .header("Authorization", "Bearer mock-token-testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.oauthId").doesNotExist())
                .andExpect(jsonPath("$.email").value("testuser@example.com"));
    }

    @Test
    void authenticatedMockRequestCanSignInAndSignUp() throws Exception {
        mockMvc.perform(post("/api/auth/signin")
                .header("Authorization", "Bearer mock-token-testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.oauthId").doesNotExist())
                .andExpect(jsonPath("$.email").value("testuser@example.com"));

        mockMvc.perform(post("/api/auth/signup")
                .header("Authorization", "Bearer mock-token-testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.oauthId").doesNotExist())
                .andExpect(jsonPath("$.email").value("testuser@example.com"));
    }

    @Test
    void authenticatedMockRequestCanFetchTransactionsAndCategoriesAndAccounts() throws Exception {
        // Test transactions list
        mockMvc.perform(get("/api/transactions")
                .header("Authorization", "Bearer mock-token-testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());

        // Test categories list auto-initializes categories
        mockMvc.perform(get("/api/categories")
                .header("Authorization", "Bearer mock-token-testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0]").value("Coffee"));

        // Test accounts list auto-initializes accounts
        mockMvc.perform(get("/api/accounts")
                .header("Authorization", "Bearer mock-token-testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].name").value("Primary Wallet"))
                .andExpect(jsonPath("$[0].balance").value(0.0));
    }

    @Test
    void authenticatedPhoneMockRequestCanRegisterAndFetch() throws Exception {
        mockMvc.perform(get("/api/transactions")
                .header("Authorization", "Bearer mock-token-phone-+1234567890"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());

        java.util.Optional<com.recipewallet.backend.model.User> createdUser = userRepository
                .findByPhoneNumber("+1234567890");
        org.junit.jupiter.api.Assertions.assertTrue(createdUser.isPresent());
        org.junit.jupiter.api.Assertions.assertNull(createdUser.get().getEmail());
        org.junit.jupiter.api.Assertions.assertEquals("+1234567890", createdUser.get().getPhoneNumber());
    }

    @Test
    void uploadReceiptSimulatesOcrCorrectly() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "starbucks_coffee.jpg",
                MediaType.IMAGE_JPEG_VALUE,
                "fake image content".getBytes());

        mockMvc.perform(multipart("/api/transactions/upload")
                .file(file)
                .header("Authorization", "Bearer mock-token-testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.merchant").value("Processing..."))
                .andExpect(jsonPath("$.isDraft").value(true));

        // Poll database for up to 5 seconds until background async processing finishes
        long start = System.currentTimeMillis();
        com.recipewallet.backend.model.Transaction savedTx = null;
        while (System.currentTimeMillis() - start < 5000) {
            java.util.List<com.recipewallet.backend.model.Transaction> txs = transactionRepository.findAll();
            if (!txs.isEmpty() && !txs.get(0).isDraft()) {
                savedTx = txs.get(0);
                break;
            }
            Thread.sleep(100);
        }

        org.junit.jupiter.api.Assertions.assertNotNull(savedTx, "Transaction was not processed in time");
        org.junit.jupiter.api.Assertions.assertEquals("Starbucks Coffee", savedTx.getMerchant());
        org.junit.jupiter.api.Assertions.assertEquals("123 Coffee Lane, Seattle, WA 98101",
                savedTx.getMerchantAddress());
        org.junit.jupiter.api.Assertions.assertFalse(savedTx.isDraft());
        org.junit.jupiter.api.Assertions.assertNotNull(savedTx.getImageUrl());
        org.junit.jupiter.api.Assertions
                .assertTrue(savedTx.getImageUrl().startsWith("https://mock-storage.example.com/receipts/"));

        java.util.List<com.recipewallet.backend.model.TransactionItem> items = transactionItemRepository.findAll();
        org.junit.jupiter.api.Assertions.assertEquals(3, items.size());
        org.junit.jupiter.api.Assertions.assertEquals("Caffe Latte", items.get(0).getName());
    }

    @Test
    void addCategorySuccessfully() throws Exception {
        mockMvc.perform(post("/api/categories")
                .header("Authorization", "Bearer mock-token-testuser")
                .contentType(MediaType.APPLICATION_JSON)
                .content("\"My New Category\""))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").value("My New Category"));
    }

    @Test
    void createAccountSuccessfully() throws Exception {
        String accountJson = "{\"name\":\"Savings Account\",\"type\":\"BANK_ACCOUNT\",\"balance\":500.0,\"currency\":\"USD\"}";
        mockMvc.perform(post("/api/accounts")
                .header("Authorization", "Bearer mock-token-testuser")
                .contentType(MediaType.APPLICATION_JSON)
                .content(accountJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Savings Account"))
                .andExpect(jsonPath("$.balance").value(500.0));
    }

    @Test
    void deleteAccountSuccessfully() throws Exception {
        // Authenticate once to ensure user is created, categories and accounts auto-initialized
        mockMvc.perform(get("/api/auth/me")
                .header("Authorization", "Bearer mock-token-deleteuser"))
                .andExpect(status().isOk());

        // Perform delete request
        mockMvc.perform(delete("/api/auth/me")
                .header("Authorization", "Bearer mock-token-deleteuser"))
                .andExpect(status().isNoContent());

        // Ensure user is deleted
        org.junit.jupiter.api.Assertions.assertFalse(userRepository.findByOauthId("deleteuser").isPresent());
    }
}
