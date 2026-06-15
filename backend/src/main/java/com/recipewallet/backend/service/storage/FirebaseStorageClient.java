package com.recipewallet.backend.service.storage;

import com.google.cloud.storage.Blob;
import com.google.cloud.storage.Bucket;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

public class FirebaseStorageClient implements StorageClient {

    @Override
    public String upload(MultipartFile file) throws IOException {
        String fileName = UUID.randomUUID().toString() + "-" + (file.getOriginalFilename() != null ? file.getOriginalFilename() : "file");
        Bucket bucket = com.google.firebase.cloud.StorageClient.getInstance().bucket();
        if (bucket == null) {
            throw new IllegalStateException("Firebase storage bucket is not configured or initialized");
        }

        String contentType = file.getContentType();
        Blob blob = bucket.create("receipts/" + fileName, file.getBytes(), contentType != null ? contentType : "image/jpeg");

        // Generate a signed URL with 365 days expiration
        return blob.signUrl(365, TimeUnit.DAYS).toString();
    }
}
