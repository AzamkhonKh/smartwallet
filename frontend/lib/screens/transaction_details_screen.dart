import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/app_snack_bar.dart';
import '../services/ai_consent_service.dart';
import '../l10n/app_localizations.dart';
import 'transaction_form_sheet.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final ApiService apiService;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
    required this.apiService,
  });

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late Map<String, dynamic> _transaction;
  bool _isPolling = false;
  Timer? _pollingTimer;
  String? _suggestions;
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
    _suggestions = _transaction['suggestions'];
    if (_transaction['isDraft'] == true || _transaction['merchant'] == 'Processing...') {
      _startPolling();
    }
  }

  void _startPolling() {
    setState(() {
      _isPolling = true;
    });
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final id = _transaction['id'] as int;
        final updatedTx = await widget.apiService.getTransaction(id);
        if (mounted) {
          if (updatedTx['isDraft'] == false && updatedTx['merchant'] != 'Processing...') {
            timer.cancel();
            setState(() {
              _transaction = updatedTx;
              _suggestions = updatedTx['suggestions'];
              _isPolling = false;
            });
          } else {
            setState(() {
              _transaction = updatedTx;
              _suggestions = updatedTx['suggestions'];
            });
          }
        }
      } catch (e) {
        // Quietly fail or log during background polling
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchGemmaSuggestions() async {
    final consented = await AiConsentService.requestConsent(context);
    if (!consented) {
      if (mounted) {
        AppSnackBar.error(context, AppLocalizations.of(context).aiConsentSnackbarDecline);
      }
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
      _suggestions = null;
    });

    try {
      final id = _transaction['id'] as int;
      final result = await widget.apiService.getGemmaSuggestions(id);
      setState(() {
        _suggestions = result;
        _transaction['suggestions'] = result;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSuggestions = false;
        _suggestions = null;
      });
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101424),
        title: const Text('Delete Scan?', style: TextStyle(color: Colors.white)),
        content: const Text('This will remove the transaction and update your balances.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC70039)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final id = _transaction['id'] as int;
        await widget.apiService.deleteTransaction(id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) AppSnackBar.fromException(context, e);
      }
    }
  }

  void _showEditTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => TransactionFormSheet(
        apiService: widget.apiService,
        transaction: _transaction,
        onSaved: (updatedTx) {
          setState(() {
            _transaction = updatedTx;
            _suggestions = updatedTx['suggestions'];
          });
        },
      ),
    );
  }

  Widget _buildDuplicateWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  color: Colors.orangeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Possible Duplicate Detected',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This transaction matches another record (Merchant, Date, and Amount match). Verify if it is a duplicate.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    try {
                      final id = _transaction['id'] as int;
                      final updatedTx = await widget.apiService.keepBoth(id);
                      setState(() {
                        _transaction = updatedTx;
                        _suggestions = updatedTx['suggestions'];
                      });
                      if (mounted) {
                        AppSnackBar.success(context, 'Both transactions kept. Flags cleared.');
                      }
                    } catch (e) {
                      if (mounted) AppSnackBar.fromException(context, e);
                    }
                  },
                  child: Text(
                    'Keep Both',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC70039), width: 1.5),
                    foregroundColor: const Color(0xFFC70039),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _deleteTransaction,
                  child: Text(
                    'Delete Duplicate',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGemmaInsights() {
    if (_isLoadingSuggestions) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Color(0xFF6C63FF)),
            const SizedBox(height: 16),
            Text(
              'Gemma 3n is generating recommendations...',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_suggestions == null || _suggestions!.trim().isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.15),
              const Color(0xFF00D2FF).withOpacity(0.05),
            ],
          ),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00D2FF)),
          label: Text(
            'Generate Gemma Insights',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          onPressed: _fetchGemmaSuggestions,
        ),
      );
    }

    // Simple markdown renderer to render styled text blocks
    List<Widget> parsedWidgets = [];
    final lines = _suggestions!.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('###')) {
        parsedWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Text(
              line.replaceFirst('###', '').trim(),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('**') || line.startsWith('☕') || line.startsWith('🛒') || line.startsWith('🔌') || line.startsWith('🛍️') || line.startsWith('📊')) {
        parsedWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              line.replaceAll('**', '').trim(),
              style: GoogleFonts.inter(
                color: const Color(0xFF00D2FF),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('•') || line.startsWith('-')) {
        parsedWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 16)),
                Expanded(
                  child: Text(
                    line.replaceFirst(RegExp(r'^[•-]\s*'), '').replaceAll('**', '').trim(),
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('⚠️') || line.startsWith('💡') || line.startsWith('✅')) {
        final isAlert = line.startsWith('⚠️');
        parsedWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAlert ? const Color(0xFFC70039).withOpacity(0.1) : const Color(0xFF00D2FF).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAlert ? const Color(0xFFC70039).withOpacity(0.3) : const Color(0xFF00D2FF).withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.substring(0, 2), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line.substring(2).replaceAll('**', '').trim(),
                    style: GoogleFonts.inter(
                      color: isAlert ? const Color(0xFFC70039) : Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        parsedWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              line.replaceAll('**', '').trim(),
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parsedWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merchant = _transaction['merchant'] ?? 'Merchant';
    final categoriesList = _transaction['categories'] as List?;
    final category = (categoriesList != null && categoriesList.isNotEmpty)
        ? categoriesList.join(', ')
        : 'Other';
    final total = _transaction['totalAmount'] ?? 0.0;
    
    // Parse line items
    List<dynamic> items = [];
    if (_transaction['items'] != null) {
      items = _transaction['items'];
    } else {
      try {
        final jsonStr = _transaction['structuredJson'];
        if (jsonStr != null) {
          items = jsonDecode(jsonStr);
        }
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF6C63FF)),
            onPressed: _showEditTransactionSheet,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC70039)),
            onPressed: _deleteTransaction,
          ),
        ],
        bottom: _isPolling
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(
                  color: Color(0xFF6C63FF),
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          if (_transaction['isPossibleDuplicate'] == true) ...[
            _buildDuplicateWarningBanner(),
            const SizedBox(height: 20),
          ],
          // Header Transaction Info
          Center(
            child: Column(
              children: [
                Text(
                  merchant,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category,
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white38, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _transaction['toAccountName'] != null
                          ? '${_transaction['fromAccountName']} ➔ ${_transaction['toAccountName']}'
                          : '${_transaction['fromAccountName']}',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${getCurrencySymbol(_transaction['currency'])}${total.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                if (_transaction['currency'] != null &&
                    _transaction['primaryCurrency'] != null &&
                    _transaction['currency'].toString().toUpperCase() !=
                        _transaction['primaryCurrency'].toString().toUpperCase() &&
                    _transaction['convertedAmount'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '≈ ${getCurrencySymbol(_transaction['primaryCurrency'] as String)}${(((_transaction['convertedAmount'] ?? total) as num).toDouble()).toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          if (_transaction['imageUrl'] != null && _transaction['imageUrl'].toString().trim().isNotEmpty) ...[
            Text(
              'RECEIPT IMAGE',
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.black.withOpacity(0.9),
                      insetPadding: const EdgeInsets.all(12),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          InteractiveViewer(
                            maxScale: 5.0,
                            child: Center(
                              child: Image.network(
                                _transaction['imageUrl'],
                                headers: widget.apiService.authService.token != null
                                    ? {'Authorization': 'Bearer ${widget.apiService.authService.token}'}
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  image: DecorationImage(
                    image: NetworkImage(
                      _transaction['imageUrl'],
                      headers: widget.apiService.authService.token != null
                          ? {'Authorization': 'Bearer ${widget.apiService.authService.token}'}
                          : null,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to zoom receipt image',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Items breakdown list
          Text(
            'EXTRACTED ITEMS',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_isPolling)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF), strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gemma is reading the receipt items...',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No specific line items extracted.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final item = items[idx];
                final name = item['name'] ?? 'Item';
                final price = item['price'] ?? 0.0;
                final qty = item['qty'] ?? 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.015),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$qty x $name',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${getCurrencySymbol(_transaction['currency'])}${(price * qty).toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_transaction['currency'] != null &&
                              _transaction['primaryCurrency'] != null &&
                              _transaction['currency'].toString().toUpperCase() !=
                                  _transaction['primaryCurrency'].toString().toUpperCase() &&
                              item['convertedPrice'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                '${getCurrencySymbol(_transaction['primaryCurrency'] as String)}${((item['convertedPrice'] ?? price) * qty).toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 40),

          // Gemma AI suggestions block
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GEMMA 3N SAVINGS ADVICE',
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              if (!_isPolling && _suggestions != null && _suggestions!.trim().isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF), size: 18),
                  onPressed: _fetchGemmaSuggestions,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isPolling)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.01),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Insights will become available after parsing is complete.',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildGemmaInsights(),
          const SizedBox(height: 48),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _isPolling
                  ? LinearGradient(
                      colors: [
                        Colors.orangeAccent.withOpacity(0.8),
                        Colors.redAccent.withOpacity(0.8)
                      ],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
                    ),
              boxShadow: [
                BoxShadow(
                  color: (_isPolling ? Colors.orangeAccent : const Color(0xFF6C63FF))
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                _pollingTimer?.cancel();
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPolling) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    _isPolling
                        ? 'Process in Background (Back to Wallet)'
                        : 'Back to Wallet',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
