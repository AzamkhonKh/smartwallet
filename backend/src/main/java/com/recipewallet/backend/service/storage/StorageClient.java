package com.recipewallet.backend.service.storage;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface StorageClient {
    String upload(MultipartFile file) throws IOException;
}
