import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/app_snack_bar.dart';
import '../l10n/app_localizations.dart';
import '../widgets/section_header.dart';
import '../widgets/gradient_button.dart';
import '../widgets/glass_card.dart';

class AccountsScreen extends StatefulWidget {
  final ApiService apiService;

  const AccountsScreen({super.key, required this.apiService});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<dynamic> _accounts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.apiService.getAccounts();
      if (!mounted) return;
      setState(() {
        _accounts = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  void _showAddAccountSheet() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0.0');
    String selectedType = 'BANK_ACCOUNT';
    String selectedCurrency = 'USD';

    final types = [
      'BANK_ACCOUNT',
      'CASH_WALLET',
      'CASH_SAFE',
      'CREDIT_CARD',
      'INVESTMENT',
      'DIGITAL_WALLET',
    ];

    final currencies = ['USD', 'EUR', 'GBP', 'UZS'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).accountsCreateTitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).accountsName,
                      labelStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: const Color(0xFF101424),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).accountsType,
                      labelStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                    ),
                    items: types.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: balanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).accountsInitialBalance,
                            labelStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.03),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: selectedCurrency,
                          dropdownColor: const Color(0xFF101424),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).accountsCurrency,
                            labelStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.03),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                          items: currencies.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedCurrency = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                   GradientButton(
                    label: AppLocalizations.of(context).accountsCreate,
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final bal =
                          double.tryParse(balanceController.text) ?? 0.0;
                      if (name.isNotEmpty) {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                          await widget.apiService.createAccount({
                            'name': name,
                            'type': selectedType,
                            'balance': bal,
                            'currency': selectedCurrency,
                          });
                          _loadAccounts();
                        } catch (e) {
                          setState(() => _isLoading = false);
                          if (mounted) AppSnackBar.fromException(context, e);
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  LinearGradient _getGradientForType(String type) {
    switch (type) {
      case 'BANK_ACCOUNT':
        return const LinearGradient(
          colors: [Color(0xFF1A2639), Color(0xFF111E2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'CREDIT_CARD':
        return const LinearGradient(
          colors: [Color(0xFF3B1A22), Color(0xFF261015)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'INVESTMENT':
        return const LinearGradient(
          colors: [Color(0xFF142B28), Color(0xFF0C1D1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'CASH_WALLET':
      case 'DIGITAL_WALLET':
      default:
        return const LinearGradient(
          colors: [Color(0xFF1F1D36), Color(0xFF121020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'BANK_ACCOUNT':
        return Icons.account_balance_outlined;
      case 'CREDIT_CARD':
        return Icons.credit_card_outlined;
      case 'INVESTMENT':
        return Icons.trending_up_outlined;
      case 'CASH_WALLET':
      case 'CASH_SAFE':
        return Icons.wallet_outlined;
      case 'DIGITAL_WALLET':
      default:
        return Icons.phonelink_setup_outlined;
    }
  }

  Future<void> _confirmDeleteAccount(String id, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101424),
          title: Text(
            AppLocalizations.of(context).accountsDeleteTitle,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context).accountsDeleteContent(name),
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppLocalizations.of(context).delete,
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await widget.apiService.deleteAccount(id);
        _loadAccounts();
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) AppSnackBar.fromException(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).accountsTitle,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddAccountSheet,
          ),
        ],
      ),
      body: _isLoading && _accounts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : RefreshIndicator(
              onRefresh: _loadAccounts,
              color: const Color(0xFF6C63FF),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                children: [
                  Text(
                    AppLocalizations.of(context).accountsSubtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_accounts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).accountsEmpty,
                        style: GoogleFonts.inter(color: Colors.white38),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final acc = _accounts[index];
                        final id = acc['id'] as String;
                        final name = acc['name'] ?? 'Wallet';
                        final type = acc['type'] ?? 'CASH_WALLET';
                        final balance = ((acc['balance'] ?? 0.0) as num).toDouble();
                        final currency = acc['currency'] ?? 'USD';
                        final symbol = getCurrencySymbol(currency);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: _getGradientForType(type),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getIconForType(type),
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          type.replaceAll('_', ' '),
                                          style: GoogleFonts.inter(
                                            color: Colors.white38,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      currency,
                                      style: GoogleFonts.inter(
                                        color: Colors.white38,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (name.toLowerCase() !=
                                            'primary wallet' &&
                                        _accounts.length > 1)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _confirmDeleteAccount(id, name),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$symbol${balance.toStringAsFixed(2)}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (acc['convertedBalance'] != null &&
                                        acc['primaryCurrency'] != null &&
                                        currency.toUpperCase() !=
                                            acc['primaryCurrency']
                                                .toString()
                                                .toUpperCase())
                                      Text(
                                        '≈ ${getCurrencySymbol(acc['primaryCurrency'] as String)}${((acc['convertedBalance'] ?? 0.0) as num).toDouble().toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
