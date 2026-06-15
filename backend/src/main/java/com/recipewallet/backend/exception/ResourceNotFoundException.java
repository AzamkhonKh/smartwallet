package com.recipewallet.backend.exception;

/**
 * Thrown when a requested resource is not found (maps to HTTP 404).
 */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
