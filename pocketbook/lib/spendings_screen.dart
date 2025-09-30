import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_handler.dart';

class SpendingsScreen extends StatefulWidget{
  const SpendingsScreen({super.key});

  @override
  State<SpendingsScreen> createState() => _SpendingsScreenState();
}

class _SpendingsScreenState extends State<SpendingsScreen> {
  
  final List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState(){
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final handler = await DatabaseHandler.create();
      final rows = await handler.getCategories(DatabaseHandler.userID);
      final loaded = rows.map((r) {
        final name = (r['category'] as String?) ?? 'Unnamed';
        final value = (r['amount'] as num?)?.toDouble() ?? 0.0;
        final colorRaw = r['category_color'];
        final color = _colorFromDb(colorRaw) ?? const Color(0xFF3498DB);

        return Category(name: name, value: value, color: color);
      }).toList();

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

  double get _totalValue => 
    _categories.fold(0.0, (sum, c) => sum + (c.value));

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

      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Breakdown box & text
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

          if (_categories.isNotEmpty && _totalValue > 0)

            // Constrained pie_chart
            Positioned(
              bottom: 125,
              child: SizedBox(
                width: 300,
                height: 300,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 75,
                    borderData: FlBorderData(show: false),
                    sections: _categories.map((c) {
                      return PieChartSectionData(
                        value: c.value,
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
                ),
              ),
            )
            else 

              Positioned(
                bottom: 125,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF280039),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No categories yet. \nAdd some to see the chart!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 24),
                      )
                    )
                  ),
                ),
              ),

            // Tappable categorys with matching labels
            for (int i = 0; i < _categories.length; i++)
              Positioned(
                bottom: -70 - (i * 70),
                child: _ActionTile(
                  width: 350, 
                  height: 50, 
                  label: _categories[i].name, 
                  color: _categories[i].pressed
                      ? Colors.green
                      : _categories[i].color, 
                  onTap: (){
                    setState(() {
                      _categories[i].pressed = !_categories[i].pressed;
                    });
                  },
                ),
              ),


          ],  // Children
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

// Simple data model
class Category {
  final String name;
  final double value;
  final Color color;
  bool pressed;

  Category({
    required this.name,
    required this.value,
    required this.color,
    this.pressed = false,
  });
}

// Reusable, tappable rectangle(s) with label text
class _ActionTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    final textColor = brightness == Brightness.light ? Colors.black : Colors.white;

    return Material( 
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.greenAccent.withValues(alpha: 0.3), 
        highlightColor: Colors.green.withValues(alpha: 0.2),   
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}