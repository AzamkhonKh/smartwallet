package com.recipewallet.backend.service.ocr;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface OcrClient {
    /**
     * Extracts raw text from a receipt image file.
     * @param file the receipt image file
     * @return the extracted raw text
     * @throws IOException if an error occurs reading the file
     */
    String extractText(MultipartFile file) throws IOException;
}
