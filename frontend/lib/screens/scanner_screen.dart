import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/app_snack_bar.dart';
import '../services/ai_consent_service.dart';
import '../l10n/app_localizations.dart';
import 'transaction_details_screen.dart';

class ScannerScreen extends StatefulWidget {
  final ApiService apiService;

  const ScannerScreen({super.key, required this.apiService});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  int _batchCount = 0;
  List<dynamic> _accounts = [];
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accs = await widget.apiService.getAccounts();
      if (mounted && accs.isNotEmpty) {
        setState(() {
          _accounts = accs;
          _selectedAccountId = accs.first['id'] as String;
        });
      }
    } catch (e) {
      debugPrint("Failed to load accounts: $e");
    }
  }

  Future<void> _handleImageSelection(XFile? image) async {
    if (image == null) return;

    final consented = await AiConsentService.requestConsent(context);
    if (!consented) {
      if (mounted) {
        AppSnackBar.error(context, AppLocalizations.of(context).aiConsentSnackbarDecline);
      }
      return;
    }

    setState(() {
      _isUploading = true;
      _batchCount = 1;
    });
    try {
      // Size validation
      final length = await image.length();
      if (length > 10 * 1024 * 1024) {
        throw Exception('File size exceeds the 10MB limit.');
      }
      // Extension validation
      String ext = image.name.split('.').last.toLowerCase();
      if (ext != 'png' && ext != 'jpg' && ext != 'jpeg') {
        throw Exception('Unsupported file extension. Only .png, .jpg, .jpeg are allowed.');
      }

      final bytes = await image.readAsBytes();
      final result = await widget.apiService.uploadReceipt(
        bytes,
        image.name,
        fromAccountId: _selectedAccountId,
      );

      setState(() => _isUploading = false);
      
      // Navigate to details screen of the parsed transaction
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(
              transaction: result,
              apiService: widget.apiService,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  Future<void> _handleBatchImageSelection(List<XFile>? images) async {
    if (images == null || images.isEmpty) return;

    final consented = await AiConsentService.requestConsent(context);
    if (!consented) {
      if (mounted) {
        AppSnackBar.error(context, AppLocalizations.of(context).aiConsentSnackbarDecline);
      }
      return;
    }

    int totalCount = images.length;
    setState(() {
      _isUploading = true;
      _batchCount = totalCount;
    });

    try {
      List<Uint8List> fileBytesList = [];
      List<String> filenames = [];

      for (XFile image in images) {
        // Check file size (max 10MB)
        final length = await image.length();
        if (length > 10 * 1024 * 1024) {
          throw Exception('File ${image.name} exceeds the 10MB size limit.');
        }
        // Check file extension
        String ext = image.name.split('.').last.toLowerCase();
        if (ext != 'png' && ext != 'jpg' && ext != 'jpeg') {
          throw Exception('File ${image.name} has an unsupported extension (only .png, .jpg, .jpeg allowed).');
        }

        final bytes = await image.readAsBytes();
        fileBytesList.add(bytes);
        filenames.add(image.name);
      }

      // De-duplicate matching filenames/hashes client-side
      List<Uint8List> deduplicatedBytes = [];
      List<String> deduplicatedFilenames = [];
      Set<String> uniqueNames = {};
      for (int i = 0; i < filenames.length; i++) {
        if (!uniqueNames.contains(filenames[i])) {
          uniqueNames.add(filenames[i]);
          deduplicatedBytes.add(fileBytesList[i]);
          deduplicatedFilenames.add(filenames[i]);
        }
      }

      if (deduplicatedBytes.isEmpty) {
        throw Exception('No unique valid files selected for upload.');
      }

      final uploadedTxs = await widget.apiService.uploadReceiptsBatch(
        deduplicatedBytes,
        deduplicatedFilenames,
        fromAccountId: _selectedAccountId,
      );

      setState(() => _isUploading = false);

      if (mounted) {
        if (uploadedTxs.isEmpty) {
          AppSnackBar.warning(
            context,
            'All selected receipts had already been uploaded.',
          );
        } else {
          AppSnackBar.success(
            context,
            'Successfully queued ${uploadedTxs.length} receipts! Processing in the background.',
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          if (images.length == 1) {
            await _handleImageSelection(images.first);
          } else {
            await _handleBatchImageSelection(images);
          }
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          await _handleImageSelection(image);
        }
      }
    } catch (e) {
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A13),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Receipt Scanner',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: 40,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00D2FF).withOpacity(0.08)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Scanning viewfinder animation representation
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_scanner_rounded, size: 80, color: Color(0xFF6C63FF)),
                              const SizedBox(height: 16),
                              Text(
                                'Align receipt within frame',
                                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
                              ),
                            ],
                          ),

                          // Scanner laser line simulator if loading
                          if (_isUploading) ...[
                            Container(
                              color: Colors.black.withOpacity(0.7),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                                  const SizedBox(height: 20),
                                  Text(
                                    _batchCount > 1 
                                        ? 'Uploading $_batchCount receipts...'
                                        : 'Running OCR Data Extraction...',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _batchCount > 1
                                        ? 'Saving drafts to task queue'
                                        : 'Parsing items & total',
                                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Source Account Selection Dropdown
                if (_accounts.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    dropdownColor: const Color(0xFF101424),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Source Account',
                      labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white38, size: 20),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.02),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                      ),
                    ),
                    items: _accounts.map((acc) {
                      return DropdownMenuItem<String>(
                        value: acc['id'] as String,
                        child: Text('${acc['name']} (${acc['currency']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedAccountId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Device Photo Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withOpacity(0.08)),
                          ),
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Camera'),
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
