package com.recipewallet.backend.service.storage;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.UUID;

public class MockStorageClient implements StorageClient {
    @Override
    public String upload(MultipartFile file) throws IOException {
        return "https://mock-storage.example.com/receipts/" + UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
    }
}
