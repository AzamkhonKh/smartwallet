import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/app_snack_bar.dart';
import 'accounts_screen.dart';
import 'scanner_screen.dart';
import 'transaction_details_screen.dart';
import 'transaction_form_sheet.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late ApiService _apiService;
  List<dynamic> _transactions = [];
  bool _isLoading = false;
  double _totalSpending = 0.0;
  String _primaryCurrency = 'USD';
  String _userFullName = 'Demo User';
  Timer? _draftPollTimer;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = ApiService(authService);
    _loadData();
  }

  @override
  void dispose() {
    _draftPollTimer?.cancel();
    super.dispose();
  }

  void _checkAndStartDraftPolling() {
    _draftPollTimer?.cancel();

    final draftIds = _transactions
        .where((tx) => tx['isDraft'] == true)
        .map((tx) => tx['id'] as int)
        .toList();

    if (draftIds.isEmpty) return;

    _draftPollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final txs = await _apiService.getTransactions();

        bool anyDraftCompleted = false;
        for (int id in draftIds) {
          final matchingTx = txs.firstWhere(
            (tx) => tx['id'] == id,
            orElse: () => null,
          );
          if (matchingTx == null || matchingTx['isDraft'] == false) {
            anyDraftCompleted = true;
            break;
          }
        }

        if (anyDraftCompleted && mounted) {
          timer.cancel();
          _loadData();
        }
      } catch (e) {
        debugPrint("Error polling transactions: $e");
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final txs = await _apiService.getTransactions();

      // Fetch user profile settings
      try {
        final profile = await _apiService.getCurrentUser();
        setState(() {
          _primaryCurrency = profile['primaryCurrency'] ?? 'USD';
          _userFullName = profile['name'] ?? 'Demo User';
        });
      } catch (e) {
        debugPrint("Failed to fetch user profile: $e");
      }

      double total = 0.0;
      for (var tx in txs) {
        total += (tx['convertedAmount'] ?? tx['totalAmount'] ?? 0.0) as double;
      }

      setState(() {
        _transactions = txs;
        _totalSpending = total;
        _isLoading = false;
      });
      _checkAndStartDraftPolling();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppSnackBar.fromException(context, e);
    }
  }

  void _showSettingsDialog() {
    final nameController = TextEditingController(text: _userFullName);
    String selectedCurrency = _primaryCurrency;

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
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  Text(
                    'Profile Settings',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  Text(
                    'FULL NAME',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_rounded,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Currency Selection Dropdown
                  Text(
                    'PRIMARY CURRENCY',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        dropdownColor: const Color(0xFF101424),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white60,
                        ),
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        items: ['USD', 'EUR', 'GBP', 'UZS', 'CAD', 'AUD', 'JPY']
                            .map(
                              (code) => DropdownMenuItem(
                                value: code,
                                child: Text(
                                  '$code (${getCurrencySymbol(code)})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedCurrency = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      try {
                        await _apiService.updateProfile({
                          'name': nameController.text,
                          'primaryCurrency': selectedCurrency,
                        });
                        if (context.mounted) Navigator.pop(context);
                        _loadData();
                        if (mounted) AppSnackBar.success(context, 'Profile updated successfully!');
                      } catch (e) {
                        if (mounted) AppSnackBar.fromException(context, e);
                      }
                    },
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    final grouped = _groupTransactions(_transactions);
    final List<dynamic> listItems = [];
    grouped.forEach((date, txList) {
      listItems.add(date);
      listItems.addAll(txList);
    });

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF6C63FF),
      backgroundColor: const Color(0xFF101424),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          // Greeting & User info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                  ),
                  Text(
                    _userFullName,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Profile tab index
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF00D2FF),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Balance Gradient Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFC70039)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL SPENDING',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Icon(Icons.show_chart_rounded, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${getCurrencySymbol(_primaryCurrency)}${_totalSpending.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF00D2FF),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Scan receipts to trigger AI personal finance insights.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Transactions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Scans',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _loadData,
                child: const Text(
                  'Refresh',
                  style: TextStyle(color: Color(0xFF6C63FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Transactions List
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  ),
                )
              : _transactions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.document_scanner_outlined,
                        size: 48,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No scanned receipts yet.',
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openCamera,
                        child: const Text(
                          'Scan Your First Receipt',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listItems.length,
                  itemBuilder: (context, index) {
                    final item = listItems[index];
                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          bottom: 10.0,
                          left: 4.0,
                        ),
                        child: Text(
                          item.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6C63FF),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      );
                    }

                    final tx = item as Map<String, dynamic>;
                    final categoriesList = tx['categories'] as List?;
                    final category =
                        (categoriesList != null && categoriesList.isNotEmpty)
                        ? categoriesList.join(', ')
                        : 'Other';
                    final total = tx['totalAmount'] ?? 0.0;
                    final merchant = tx['merchant'] ?? 'Merchant';
                    final fromAccName = tx['fromAccountName'] ?? 'Unknown';
                    final toAccName = tx['toAccountName'];
                    final isTransfer = toAccName != null;

                    IconData categoryIcon = isTransfer
                        ? Icons.swap_horiz_rounded
                        : Icons.shopping_bag_rounded;
                    Color categoryColor = isTransfer
                        ? const Color(0xFF00D2FF)
                        : const Color(0xFF6C63FF);

                    if (!isTransfer) {
                      if (category.contains('Coffee')) {
                        categoryIcon = Icons.coffee_rounded;
                        categoryColor = Colors.orangeAccent;
                      } else if (category.contains('Groceries')) {
                        categoryIcon = Icons.local_grocery_store_rounded;
                        categoryColor = Colors.lightGreen;
                      } else if (category.contains('Utilities')) {
                        categoryIcon = Icons.electrical_services_rounded;
                        categoryColor = Colors.redAccent;
                      }
                    }

                    final subtitleText = isTransfer
                        ? '$fromAccName ➔ $toAccName'
                        : '$fromAccName • $category';

                    final amountSign = isTransfer ? '' : '-';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(categoryIcon, color: categoryColor),
                        ),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                merchant,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tx['isPossibleDuplicate'] == true) ...[
                              const SizedBox(width: 6),
                              const Tooltip(
                                message: 'Possible Duplicate',
                                child: Icon(
                                  Icons.copy_rounded,
                                  color: Colors.orangeAccent,
                                  size: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          subtitleText,
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$amountSign${getCurrencySymbol(tx['currency'])}${total.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if ((tx['currency'] ?? 'USD')
                                        .toString()
                                        .toUpperCase() !=
                                    (tx['primaryCurrency'] ?? _primaryCurrency)
                                        .toString()
                                        .toUpperCase())
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '${getCurrencySymbol(tx['primaryCurrency'] ?? _primaryCurrency)}${((tx['convertedAmount'] ?? total) as double).toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white38,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white38,
                              size: 18,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailsScreen(
                                transaction: tx,
                                apiService: _apiService,
                              ),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(apiService: _apiService),
      ),
    ).then((_) => _loadData());
  }

  void _showInsertOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Text(
                'Add Transaction',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to input your expenses',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(
                      title: 'Scan Receipt',
                      subtitle: 'Auto-extract details with OCR & Gemma',
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF6C63FF),
                      onTap: () {
                        Navigator.pop(context);
                        _openCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOptionCard(
                      title: 'Enter Manually',
                      subtitle: 'Type merchant name, amount & category',
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFF00D2FF),
                      onTap: () {
                        Navigator.pop(context);
                        _showManualInsertSheet();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.015),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), color.withOpacity(0.01)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _showManualInsertSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => TransactionFormSheet(
        apiService: _apiService,
        onSaved: (_) {
          _loadData();
        },
      ),
    ).then((_) => _loadData());
  }

  Map<String, List<dynamic>> _groupTransactions(List<dynamic> transactions) {
    // Sort transactions by transactionDate descending
    transactions.sort((a, b) {
      final aDateStr = a['transactionDate'] ?? '';
      final bDateStr = b['transactionDate'] ?? '';
      if (aDateStr.isEmpty && bDateStr.isEmpty) return 0;
      if (aDateStr.isEmpty) return 1;
      if (bDateStr.isEmpty) return -1;
      return bDateStr.compareTo(aDateStr); // Descending order
    });

    final Map<String, List<dynamic>> groups = {};
    for (var tx in transactions) {
      final dateStr = tx['transactionDate'];
      String groupKey = 'No Date';
      if (dateStr != null && dateStr.toString().isNotEmpty) {
        try {
          final dt = DateTime.parse(dateStr.toString()).toLocal();
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final txDay = DateTime(dt.year, dt.month, dt.day);

          if (txDay.isAtSameMomentAs(today)) {
            groupKey = 'Today';
          } else if (txDay.isAtSameMomentAs(yesterday)) {
            groupKey = 'Yesterday';
          } else {
            final months = [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December',
            ];
            groupKey = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
          }
        } catch (_) {}
      }
      groups.putIfAbsent(groupKey, () => []).add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildOverviewTab(),
      AccountsScreen(apiService: _apiService),
      ProfileScreen(apiService: _apiService),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF0F1424),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.white38,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _showInsertOptionsSheet,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.add_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
