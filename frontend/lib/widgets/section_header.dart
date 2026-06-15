import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uppercase section label used throughout the app.
/// Replaces the repeated 5-line GoogleFonts.inter(white38, 11px, bold, letterSpacing) pattern.
///
/// Usage:
///   SectionHeader('PREFERENCES & ANALYTICS')
class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionHeader(
    this.text, {
    super.key,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
