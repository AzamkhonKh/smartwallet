import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  final ApiService apiService;

  const StatisticsScreen({super.key, required this.apiService});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {

  bool _isLoading = false;
  Map<String, double> _categoryTotals = {};
  double _grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final txs = await widget.apiService.getTransactions();
      _calculateStats(txs);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stats: $e')),
      );
    }
  }

  void _calculateStats(List<dynamic> txs) {
    Map<String, double> totals = {};
    double totalSum = 0.0;

    for (var tx in txs) {
      final categoriesList = tx['categories'] as List?;
      final amount = (tx['totalAmount'] ?? 0.0) as double;
      totalSum += amount;

      if (categoriesList == null || categoriesList.isEmpty) {
        const category = 'Other';
        totals[category] = (totals[category] ?? 0.0) + amount;
      } else {
        final splitAmount = amount / categoriesList.length;
        for (var cat in categoriesList) {
          final category = cat.toString();
          totals[category] = (totals[category] ?? 0.0) + splitAmount;
        }
      }
    }

    // Default mock stats if no real transactions exist (to show beautiful UI instantly)
    if (totals.isEmpty) {
      totals = {
        'Coffee': 18.50,
        'Groceries': 142.20,
        'Utilities': 84.20,
        'Shopping': 45.50,
      };
      totalSum = 290.40;
    }

    setState(() {
      _categoryTotals = totals;
      _grandTotal = totalSum;
      _isLoading = false;
    });
  }

  Color _getColorForCategory(String category) {
    final colors = {
      'Coffee': Colors.orangeAccent,
      'Groceries': Colors.lightGreen,
      'Utilities': Colors.redAccent,
      'Shopping': Colors.purpleAccent,
      'Other': Colors.blueGrey,
    };
    if (colors.containsKey(category)) {
      return colors[category]!;
    }
    final hash = category.hashCode;
    final index = hash.abs() % Colors.primaries.length;
    return Colors.primaries[index];
  }

  List<PieChartSectionData> _getSections() {
    List<PieChartSectionData> sections = [];
    _categoryTotals.forEach((category, value) {
      final color = _getColorForCategory(category);
      final percentage = _grandTotal > 0 ? (value / _grandTotal * 100) : 0.0;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: const Color(0xFF6C63FF),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                children: [
                  Text(
                    'Category-wise Breakdown',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Pie Chart Container
                  Container(
                    height: 200,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,
                            sections: _getSections(),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'TOTAL',
                                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${_grandTotal.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Legend list
                  Column(
                    children: _categoryTotals.entries.map((entry) {
                      final category = entry.key;
                      final total = entry.value;
                      final color = _getColorForCategory(category);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  category,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Mock Trend Chart Header
                  Text(
                    'Monthly Spend Trend',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Line Chart
                  Container(
                    height: 180,
                    padding: const EdgeInsets.only(right: 16, top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final style = GoogleFonts.inter(color: Colors.white30, fontSize: 10);
                                switch (value.toInt()) {
                                  case 1: return Text('Mar', style: style);
                                  case 2: return Text('Apr', style: style);
                                  case 3: return Text('May', style: style);
                                  case 4: return Text('Jun', style: style);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final style = GoogleFonts.inter(color: Colors.white30, fontSize: 10);
                                return Text('\$${value.toInt()}', style: style);
                              },
                              reservedSize: 32,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 1,
                        maxX: 4,
                        minY: 100,
                        maxY: 400,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(1, 150),
                              FlSpot(2, 280),
                              FlSpot(3, 190),
                              FlSpot(4, 290),
                            ],
                            isCurved: true,
                            color: const Color(0xFF6C63FF),
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF6C63FF).withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
