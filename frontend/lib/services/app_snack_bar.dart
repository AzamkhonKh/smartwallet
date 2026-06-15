import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_exception.dart';

/// A premium, icon-rich SnackBar helper.
///
/// Usage:
///   AppSnackBar.error(context, 'Something went wrong.');
///   AppSnackBar.success(context, 'Transaction saved!');
///   AppSnackBar.info(context, 'Receipt is being processed…');
///   AppSnackBar.warning(context, 'This receipt might be a duplicate.');
///
/// Or, when catching from an API call:
///   AppSnackBar.fromException(context, e);
class AppSnackBar {
  // ── Public factory methods ────────────────────────────────────────────────

  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      iconColor: const Color(0xFFFF6B6B),
      borderColor: const Color(0xFFFF6B6B),
      backgroundColor: const Color(0xFF1E0F0F),
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF4CAF50),
      borderColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFF0D1E0F),
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      iconColor: const Color(0xFF00D2FF),
      borderColor: const Color(0xFF00D2FF),
      backgroundColor: const Color(0xFF0A1A24),
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orangeAccent,
      borderColor: Colors.orangeAccent,
      backgroundColor: const Color(0xFF1E1600),
    );
  }

  /// Inspect [error] and pick the right tone automatically:
  ///  • [ApiException] with 409  → warning (duplicate receipt)
  ///  • [ApiException] with 4xx  → warning for client errors
  ///  • [ApiException] with 5xx  → error
  ///  • Network / unknown        → error
  static void fromException(BuildContext context, Object error) {
    if (error is ApiException) {
      if (error.statusCode == 409) {
        warning(context, error.message);
      } else if (error.statusCode >= 400 && error.statusCode < 500) {
        // 4xx are user-fixable; use warning tone so it's less alarming
        warning(context, error.message);
      } else {
        AppSnackBar.error(context, error.message);
      }
    } else {
      // Network errors, socket exceptions, etc.
      AppSnackBar.error(
        context,
        'Could not connect to the server. Check your internet connection.',
      );
    }
  }

  // ── Private core renderer ─────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Clear any existing snackbar so they don't stack
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withOpacity(0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
