import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_handler.dart';

class SpendingsSubmenu extends StatefulWidget {
  const SpendingsSubmenu({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.totalAmount,
    });

  final String categoryName;
  final Color categoryColor;
  final double totalAmount;


  @override
  State<SpendingsSubmenu> createState() => _SpendingsSubMenuState();
}

class _SpendingsSubMenuState extends State<SpendingsSubmenu> {
  DateTime _focusedMonth = DateTime.now();
  bool _loading = true;
  List<_Txn> _allTxns = [];
  List<_Txn> _monthTxns = [];

  // Budget Value
  double? _budget;

  @override
  void initState() {
    super.initState();
    _loadTxns();
  }

  Color _on(Color bg) => ThemeData.estimateBrightnessForColor(bg) == Brightness.light ? Colors.black : Colors.white;

  Future<void> _loadTxns() async {
    setState(() => _loading = true);

    try {
      final handler = await DatabaseHandler.create();
      final rows = await handler.getSpendingInCategory(
        DatabaseHandler.userID,
        widget.categoryName,
      );
      // print('[submenu] rows fetched for "${widget.categoryName}": ${rows.length}');
      // if (rows.isNotEmpty) print('[submenu] first row: ${rows.first}');
      final catRows = await handler.getCategoriesFromName(
        DatabaseHandler.userID,
        widget.categoryName,
      );
      final budgetFromDb = (catRows.isNotEmpty) ? (catRows.first['amount'] as num?)?.toDouble() : null;
      final parsed = rows.map((r) {
        final whenRaw = r['date_time']?.toString() ?? '';
        DateTime? when;
        try {
          when = DateFormat("MMM-dd-yyyy\nhh:mm:ss a").parse(whenRaw);
        } catch (_) {
          when = null;
        }
        final caption = r['caption']?.toString() ?? '-';
        final amount = (r['amount'] as num?)?.toDouble() ?? 0.0;

        return _Txn(
          when: when,
          caption: caption,
          amount: amount,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _budget = budgetFromDb ?? widget.totalAmount;
        _allTxns = parsed;
        _monthTxns = _filterForMonth(_focusedMonth, parsed);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _budget = widget.totalAmount; 
        _allTxns = [];
        _monthTxns = [];
        _loading = false;
      });
      debugPrint('SpendingsSubMenu: error loading txns: $e');
    }
  }

  List<_Txn> _filterForMonth(DateTime month, List<_Txn> list) {
    final y = month.year;
    final m = month.month;
    return list.where((t) {
      if (t.when == null) return false;
      return t.when!.year == y && t.when!.month == m; //I think the issue is here. t.when!.month = "oct" or something, when m = 10.
    }).toList()
      ..sort((a, b) {
        final aa = a.when ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bb = b.when ?? DateTime.fromMicrosecondsSinceEpoch(0);
        return bb.compareTo(aa);
      });
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    setState(() {
      _focusedMonth = next;
      _monthTxns = _filterForMonth(_focusedMonth, _allTxns);
    });
  }

  String _monthLabel(DateTime d) { // Should return "Month Year"
    return '${_monthNames[d.month - 1]} ${d.year}';
  }

  // double get _monthTotal => _monthTxns.fold(0.0, (sum, t) => sum + t.amount);
  double get _monthSpent {
    double s = 0.0;
    for (final t in _monthTxns) {
      if (t.amount < 0) s += -t.amount;
    }
    return s;
  }

  String _fmt(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final c = widget.categoryColor;
    final onC = _on(c);
    final double remainder = (_budget ?? widget.totalAmount) - _monthSpent;

    return Scaffold(
      backgroundColor: const Color(0xFF3B0054),
      appBar: AppBar( 
        // title:  Text(widget.categoryName),  // Uses the category's name
        // centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go Back',
          onPressed: () => Navigator.pop(context), 
        ),
        actions: [
          IconButton(
           tooltip: 'Refresh',
           icon: const Icon(Icons.refresh),
           onPressed: _loadTxns, 
          ),
        ],
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                )
              : Column(
                children: [

                  const SizedBox(height: 16),

                  // Summary card
                  SizedBox(
                    width: 375,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            // Spending Data title
                            Text(
                              widget.categoryName,
                              style: TextStyle(
                                color:  onC,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 8),

                            // Category Name
                            Text(
                              '${_fmt(remainder)} left',
                              style: TextStyle(
                                color: onC.withValues(alpha: 0.9),
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Month total for this category
                            Text(
                              // '${_signFor(_monthTotal)}\$${_monthTotal.abs().toStringAsFixed(2)} in ${_monthLabel(_focusedMonth)}',
                              '${_fmt(_monthSpent)} spent / ${_fmt(_budget ?? widget.totalAmount)} budget',
                              style: TextStyle(
                                color: onC.withValues(alpha: 0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),
                            
                            // Focused Month
                            Text(
                              'in ${_monthLabel(_focusedMonth)}',
                              style: TextStyle(
                                color: onC.withValues(alpha: 0.85),
                                fontSize: 14,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Transactions header bar
                  SizedBox(
                    width: 425,
                    height: 75,
                    child: Container(
                      decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.85),
                      border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          'Transactions',
                          style: TextStyle(
                            color: _on(c.withValues(alpha: 0.85)),
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Month Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        IconButton(
                          tooltip: 'Previous Month',
                          icon: const Icon(Icons.chevron_left),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                          ),
                          onPressed: () => _shiftMonth(-1),
                        ),

                        const SizedBox(width: 8),
                        
                        Text(
                          _monthLabel(_focusedMonth),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        IconButton(
                          tooltip: 'Next Month',
                          icon: const Icon(Icons.chevron_right),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                          ),
                          onPressed: () => _shiftMonth(1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  // Transaction List
                  Expanded(
                    child: _monthTxns.isEmpty
                        ? const Center(
                            child: Text(
                              'No transactions for this month.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemCount: _monthTxns.length,
                          itemBuilder: (context, i) {
                            final txn = _monthTxns[i];
                            final isDeposit = txn.amount > 0;
                            final amtColor = isDeposit ? Colors.green : Colors.red;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF280039).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [

                                  // Date
                                  Expanded (
                                    flex: 3, 
                                    child: Text(
                                      txn.when != null ? _shortDate(txn.when!) : '-',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),

                                  // Caption
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      txn.caption,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),

                                  // Amount
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '${_signFor(txn.amount)}\$${txn.amount.abs().toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: amtColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  ),
                ],
              ),

          ),
        ),
      ),
    );
  }

  String _shortDate(DateTime d) {
    // Think of "October, 30, 2025"
    final m = _monthAbbrev[d.month - 1];
    final day = d.day.toString().padLeft(2, '0');
    return '$m $day, ${d.year}';
  }

  String _signFor(double v) => v > 0 ? '+' : (v < 0 ? '-' : '');

  static const _monthNames = <String> [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const _monthAbbrev = <String> [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

class _Txn {
  final DateTime? when;
  final String caption;
  final double amount;

  _Txn({
    required this.when,
    required this.caption,
    required this.amount
  });
}