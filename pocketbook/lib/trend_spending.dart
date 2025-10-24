import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pocketbook/database_handler.dart';
import 'package:pocketbook/spendings_sub_menu.dart';

class TrendSpending extends StatefulWidget {
  const TrendSpending({super.key});

  @override
  State<TrendSpending> createState() => _TrendSpendingState();
}

class _TrendSpendingState extends State<TrendSpending> {
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;
  bool _loading = true;
  List<Map<String, dynamic>> _monthlyData = [];
  double _budget = 1500.0; // Default fallback if DB fetch fails

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    try {
      // Fetch monthly budget, with fallback
      final budget = await db.getMonthlyBudget(DatabaseHandler.userID).catchError((_) => 1500.0);
      final logs = await db.getSpendingLog(DatabaseHandler.userID);
      Map<String, double> monthlyTotals = {};
      for (var log in logs) {
        final whenRaw = log['date_time']?.toString() ?? '';
        DateTime? when;
        try {
          when = DateFormat("MMM-dd-yyyy\nhh:mm:ss a").parse(whenRaw);
        } catch (_) {
          when = null;
        }
        if (when == null) continue;
        final amount = (log['amount'] as num?)?.toDouble() ?? 0.0;
        if (amount >= 0) continue; // Only count spending (negative amounts)
        final monthKey = DateFormat('yyyy-MM').format(when);
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + amount.abs();
      }

      // Convert to list for charting (last 12 months)
      final now = DateTime.now();
      _monthlyData = [];
      for (int i = 11; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('yyyy-MM').format(month);
        _monthlyData.add({
          'month': month,
          'amount': monthlyTotals[monthKey] ?? 0.0,
        });
      }

      if (!mounted) return;
      setState(() {
        _budget = budget; // Update budget from DB or use fallback
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      debugPrint('Error loading monthly data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF3B0054),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3B0054),
      appBar: AppBar(
        title: const Text('Spending Trends'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back Icon',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadMonthlyData,
          ),
        ],
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Spending by Month',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (_monthlyData.map((e) => e['amount'] as double).reduce((a, b) => a > b ? a : b) * 1.2).clamp(_budget * 1.2, double.infinity),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIdx, rod, rodIdx) {
                              final month = _monthlyData[groupIdx]['month'] as DateTime;
                              final amount = rod.toY;
                              return BarTooltipItem(
                                '${DateFormat('MMM yyyy').format(month)}\n\$${amount.toStringAsFixed(0)}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          touchCallback: (FlTouchEvent event, barTouchResponse) {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              return;
                            }
                            final index = barTouchResponse.spot!.touchedBarGroupIndex;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SpendingsSubmenu(
                                  categoryName: 'All Categories',
                                  categoryColor: const Color(0xFF3498DB),
                                  totalAmount: _monthlyData[index]['amount'],
                                  focusedMonth: _monthlyData[index]['month'],
                                ),
                              ),
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= _monthlyData.length) return const Text('');
                                return Text(
                                  DateFormat('MMM').format(_monthlyData[index]['month']),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text(
                                '\$${value.toInt()}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: _monthlyData.asMap().entries.map((e) {
                          final index = e.key;
                          final amount = e.value['amount'] as double;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: amount,
                                color: amount > _budget ? Colors.red : Colors.green,
                                width: 20,
                              ),
                            ],
                          );
                        }).toList(),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: _budget,
                              color: Colors.white.withOpacity(0.5),
                              strokeWidth: 2,
                              dashArray: [5, 5],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                labelResolver: (_) => 'Budget: \$${_budget.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
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