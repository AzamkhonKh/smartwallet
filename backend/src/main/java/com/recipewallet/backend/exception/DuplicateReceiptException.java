package com.recipewallet.backend.exception;

/**
 * Thrown when a duplicate receipt is detected (maps to HTTP 409 Conflict).
 */
public class DuplicateReceiptException extends RuntimeException {
    public DuplicateReceiptException(String message) {
        super(message);
    }
}
