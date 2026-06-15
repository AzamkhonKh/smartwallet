import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ExchangeRatesScreen extends StatefulWidget {
  final ApiService apiService;

  const ExchangeRatesScreen({super.key, required this.apiService});

  @override
  State<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  List<dynamic> _rates = [];
  List<dynamic> _filteredRates = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.apiService.getExchangeRates();
      // Sort alphabetically by currency code
      data.sort((a, b) => (a['currencyCode'] ?? '').toString().compareTo((b['currencyCode'] ?? '').toString()));
      setState(() {
        _rates = data;
        _filterRates(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exchange rates: $e')),
        );
      }
    }
  }

  void _filterRates(String query) {
    setState(() {
      _searchQuery = query;
      if (query.trim().isEmpty) {
        _filteredRates = _rates;
      } else {
        _filteredRates = _rates
            .where((r) => (r['currencyCode'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? lastUpdatedStr;
    if (_rates.isNotEmpty) {
      lastUpdatedStr = _rates.first['lastUpdated'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Exchange Rates',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading && _rates.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : RefreshIndicator(
              onRefresh: _loadRates,
              color: const Color(0xFF6C63FF),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                children: [
                  Text(
                    'Real-time rates relative to USD base currency',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Search Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.white38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Search currency code...',
                              hintStyle: TextStyle(color: Colors.white24),
                              border: InputBorder.none,
                            ),
                            onChanged: _filterRates,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filterRates('');
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_filteredRates.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Text(
                        'No matching currency rates found.',
                        style: GoogleFonts.inter(color: Colors.white38),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredRates.length,
                      itemBuilder: (context, index) {
                        final rateObj = _filteredRates[index];
                        final code = (rateObj['currencyCode'] ?? '').toString().toUpperCase();
                        final rate = (rateObj['rate'] ?? 1.0) as double;
                        final symbol = getCurrencySymbol(code);

                        // Highlight common currencies
                        bool isMain = code == 'USD' || code == 'EUR' || code == 'GBP' || code == 'UZS';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isMain
                                ? const Color(0xFF6C63FF).withOpacity(0.05)
                                : Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isMain
                                  ? const Color(0xFF6C63FF).withOpacity(0.2)
                                  : Colors.white.withOpacity(0.04),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isMain
                                          ? const Color(0xFF6C63FF).withOpacity(0.12)
                                          : Colors.white.withOpacity(0.04),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      symbol.trim().isNotEmpty ? symbol.trim() : code,
                                      style: GoogleFonts.outfit(
                                        color: isMain ? const Color(0xFF00D2FF) : Colors.white60,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        code,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '1 USD = $symbol${rate.toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white38,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  rate.toStringAsFixed(4),
                                  style: GoogleFonts.outfit(
                                    color: isMain ? const Color(0xFF00D2FF) : Colors.white70,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                  if (lastUpdatedStr != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sync_rounded, color: Colors.white24, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Rates sync timestamp: ${_formatDateTime(lastUpdatedStr)}',
                              style: GoogleFonts.inter(
                                color: Colors.white24,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
