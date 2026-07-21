import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class AiConsentService {
  static const String _kAiSharingConsentKey = 'ai_sharing_consent';

  /// Check if the user has consented to AI sharing.
  /// Returns `true` if consented, `false` if denied, and `null` if not yet asked.
  static Future<bool?> getConsentState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_kAiSharingConsentKey)) {
      return null;
    }
    return prefs.getBool(_kAiSharingConsentKey);
  }

  /// Explicitly save consent status.
  static Future<void> setConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAiSharingConsentKey, value);
  }

  /// Request consent from the user via a high-fidelity modal bottom sheet.
  /// If user has already consented, returns `true` immediately.
  /// Otherwise, prompts the user and returns their choice.
  static Future<bool> requestConsent(BuildContext context) async {
    final status = await getConsentState();
    if (status == true) {
      return true;
    }

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle indicator
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology_rounded, color: Color(0xFF6C63FF), size: 28),
                  const SizedBox(width: 10),
                  Text(
                    l10n.aiConsentTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.aiConsentSubtitle,
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Intro text
              Text(
                l10n.aiConsentDesc,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Detail Section 1: Who
              _buildDetailRow(
                icon: Icons.hub_outlined,
                title: l10n.aiConsentWhoTitle,
                description: l10n.aiConsentWhoDesc,
              ),
              const SizedBox(height: 16),

              // Detail Section 2: What
              _buildDetailRow(
                icon: Icons.data_usage_rounded,
                title: l10n.aiConsentWhatTitle,
                description: l10n.aiConsentWhatDesc,
              ),
              const SizedBox(height: 16),

              // Detail Section 3: Protection
              _buildDetailRow(
                icon: Icons.enhanced_encryption_rounded,
                title: l10n.aiConsentProtectedTitle,
                description: l10n.aiConsentProtectedDesc,
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        l10n.aiConsentDecline,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        l10n.aiConsentAgree,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    final agreed = result ?? false;
    await setConsent(agreed);
    return agreed;
  }

  static Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF00D2FF), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Displays the full Privacy Policy in a scrollable, dark bottom sheet.
  static void showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Privacy Policy',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    children: [
                      _buildPolicySection(
                        title: '1. Introduction',
                        content: 'Welcome to Recipe Wallet (Spendy). We are committed to protecting your privacy and handling your personal information with transparency and care. This policy describes how we collect, use, and protect your data.',
                      ),
                      _buildPolicySection(
                        title: '2. Information We Collect',
                        content: 'We collect your email address for account authentication. We also collect transaction records, category tags, account details, and receipt OCR text to provide budgeting services.',
                      ),
                      _buildPolicySection(
                        title: '3. Camera & Photo Library Access',
                        content: 'We request access to your camera or gallery to let you capture or select receipt photos. The photos are processed to extract transaction items and are stored securely as audit references. You can delete them at any time.',
                      ),
                      _buildPolicySection(
                        title: '4. Third-Party AI Data Sharing',
                        content: 'To parse receipts and generate saving insights, Spendy shares data with third-party AI models:\n'
                            '• Receipt scans (OCR text) are processed via OpenRouter and Mistral AI to extract items, merchant, and total amounts.\n'
                            '• Transaction details (amounts, merchant, categories) are processed to provide Gemma savings advice.\n'
                            'These providers process data over encrypted channels and do not store it for advertising or use it to train their models.',
                      ),
                      _buildPolicySection(
                        title: '5. Your Rights & Choice',
                        content: 'You can opt-in or opt-out of AI sharing at any time in the Profile settings. If you revoke consent, AI features (scanning and insights) will be disabled, and no data will be shared with AI providers.',
                      ),
                      _buildPolicySection(
                        title: '6. Security & Retention',
                        content: 'All data is sent over encrypted TLS connections. We retain your transaction and account data only for as long as your account remains active. You can delete your account or specific data anytime.',
                      ),
                      _buildPolicySection(
                        title: '7. Contact Us',
                        content: 'If you have any questions, contact us at azamkhon.kh@proton.me.',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildPolicySection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
