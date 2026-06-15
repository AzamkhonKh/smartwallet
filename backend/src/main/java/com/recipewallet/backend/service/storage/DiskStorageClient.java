package com.recipewallet.backend.service.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

public class DiskStorageClient implements StorageClient {

    @Value("${recipewallet.storage.disk.upload-dir:uploads}")
    private String uploadDir;

    @Value("${recipewallet.storage.disk.base-url:http://localhost:8080/uploads/}")
    private String baseUrl;

    @Override
    public String upload(MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("Cannot upload empty file");
        }

        // Create the directory if it does not exist
        File directory = new File(uploadDir);
        if (!directory.exists()) {
            directory.mkdirs();
        }

        // Generate unique filename to avoid collisions
        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String filename = UUID.randomUUID().toString() + extension;

        // Save bytes to path
        Path filepath = Paths.get(uploadDir, filename);
        Files.write(filepath, file.getBytes());

        return baseUrl + filename;
    }
}
