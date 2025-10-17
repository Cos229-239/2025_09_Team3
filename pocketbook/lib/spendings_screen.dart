import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_handler.dart';
import 'spendings_sub_menu.dart';
import 'package:intl/intl.dart';

class SpendingsScreen extends StatefulWidget{
  const SpendingsScreen({super.key});

  @override
  State<SpendingsScreen> createState() => _SpendingsScreenState();
}

class _SpendingsScreenState extends State<SpendingsScreen> {
  final List<Category> _categories = [];
  bool _loading = true;
  final DateTime _focusedMonth = DateTime.now(); // Current Month

  @override
  void initState(){
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final handler = await DatabaseHandler.create();

      final rows = await handler.getCategories(DatabaseHandler.userID);
      final base = rows.map((r) {
        final name = (r['category'] as String?) ?? 'Unnamed';
        final colorRaw = r['category_color'];
        final color = _colorFromDb(colorRaw) ?? const Color(0xFF3498DB);
        //final value = (r['amount'] as num?)?.toDouble() ?? 0.0;
        return Category(name: name, value: 0.0, color: color);
      }).toList();

      final futures = base.map((c) async {
        final txns = await handler.getSpendingInCategory(
          DatabaseHandler.userID,
          c.name,
        );
        double monthSpent = 0.0;
        for (final t in txns) {
          final whenRaw = t['date_time']?.toString() ?? '';
          DateTime? when;
          try{
            when = DateTime.parse(whenRaw);
          } catch (_) {
            when = null;
          }
          if (when == null) continue;
          if (_isSameMonth(when, _focusedMonth)) {
            final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
            if (amt < 0) {
              monthSpent += -amt;  // Store as positive "spent" for charting
            }
          }
        }
        return Category(name: c.name, value: monthSpent, color: c.color);
      }).toList();

      final loaded = await Future.wait(futures);

      if (!mounted) return;
      setState(() {
        _categories
        ..clear()
        ..addAll(loaded);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categories.clear();
        _loading = false;
      });
      debugPrint('Error loading categories: $e');
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  double get _totalValue => _categories.fold(0.0, (sum, c) => sum + (c.value));

  void _openCategory(Category item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpendingsSubmenu(
          categoryName: item.name,
          categoryColor: item.color,
          totalAmount: item.value, // This months's spendings
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    if(_loading){
      return const Scaffold(
        backgroundColor: Color(0xFF3B0054),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3B0054),
      appBar: AppBar( 
        title: const Text('Spendings'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back Icon',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadCategories,
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 12),

                // Pie Chart
                SizedBox(
                  width: 300,
                  height: 300,
                  child: _categories.isNotEmpty && _totalValue > 0 
                    ? PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 75,
                        borderData: FlBorderData(show: false),
                        sections: _categories.map((c) {
                          return PieChartSectionData(
                            value: c.value, // Month spend per category
                            title: c.name, 
                            color: c.color,
                            radius: 70,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const _EmptyPiePlaceholder(),
                ),

                const SizedBox(height: 16),
                
                // Breakdown header bar
                Container(
                  width: 425,
                  height: 75,
                  decoration: const BoxDecoration(color: Color(0xFF280039)),
                  child: const Center(
                    child: Text(
                    'Breakdown',
                    style: TextStyle(color: Colors.white, fontSize: 36),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Category tiles
                Expanded(
                  child: _categories.isEmpty
                    ? const Center(
                      child: Text(
                        'No categories yet',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder:(context, i) {
                      final item = _categories[i];
                      return Align(
                        alignment: Alignment.center,
                        child: _ActionTile(
                          width: 350,
                          height: 50,
                          label: item.name,
                          color: item.color,
                          onTap: () => _openCategory(item),
                          ),
                        );
                      },
                    ),
                )
              
              ],  // Children
            ),
         ),
        ),
      ),
    );

  }

// Parese a DB-Stored colour value
  Color? _colorFromDb(Object? raw) {
    if (raw == null) return null;
    if (raw is int) {
      // If we ever store as interger value directly
      return Color(raw);
    }
    if (raw is String){
      final s = raw.trim().toLowerCase(); 
      final cleaned = s.startsWith('0x') ? s.substring(2) : s;  // Remove "0x" if there
      final hex = cleaned.length == 6 ? 'ff$cleaned' : cleaned; // Ensures length is 8 (ARGB)
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

// "No data" placeholder for the Pie Chart
class _EmptyPiePlaceholder extends StatelessWidget{
  const _EmptyPiePlaceholder();

  @override
  Widget build(BuildContext context){
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF280039),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No categories yet. \nAdd some to see the chart!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

// Simple data model
class Category {
  final String name;
  final double value; // This Month's Spending (positive)
  final Color color;
  //bool pressed;

  Category({
    required this.name,
    required this.value,
    required this.color,
    //this.pressed = false,
  });
}

// Reusable, tappable rectangle(s) with label text
class _ActionTile extends StatefulWidget {
  final double width;
  final double height;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.width,
    required this.height,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  State<_ActionTile> createState() => _ActionTileState();
}

// Animation
class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;
  Duration _animDuration = const Duration(milliseconds: 65); // Quick Darken

  void _handleTapDown(TapDownDetails _){
    setState(() {
      _animDuration = const Duration(milliseconds: 65); // Fast in
      _pressed = true;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _animDuration = const Duration(milliseconds: 220); // Soft out
      _pressed = false;
    });
  }

  void _handleTap() {
    widget.onTap();  // Trigger
    setState(() {
      _animDuration = const Duration(milliseconds: 220); // Soft Fade
      _pressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    final brightness = ThemeData.estimateBrightnessForColor(widget.color);
    final textColor = brightness == Brightness.light ? Colors.black : Colors.white;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: Stack(
        children: [
          // Base tile
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: radius,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          ClipRRect( // Animated darkening overlay
            borderRadius: radius,
            child: AnimatedOpacity(
              opacity: _pressed ? 0.18 : 0.0, // How Dark it'll get
              duration: _animDuration,
              curve: _pressed ? Curves.easeOutCubic : Curves.easeOut,
              child: Container(
                width: widget.width,
                height: widget.height,
                color: Colors.black, // Pure black <> opacity animates
              ),
            ),
          ),

        ],
      ),

    );
  }
}