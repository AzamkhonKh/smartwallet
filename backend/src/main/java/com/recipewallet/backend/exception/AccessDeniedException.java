package com.recipewallet.backend.exception;

/**
 * Thrown when the authenticated user tries to access a resource they do not own (maps to HTTP 403).
 */
public class AccessDeniedException extends RuntimeException {
    public AccessDeniedException(String message) {
        super(message);
    }
}
