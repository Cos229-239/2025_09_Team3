import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpendingsScreen extends StatefulWidget{
  const SpendingsScreen({super.key});

  @override
  State<SpendingsScreen> createState() => _SpendingsScreenState();
}

class _SpendingsScreenState extends State<SpendingsScreen> {
  
  final List<Category> _categories = [
    Category(name: 'Rent',  value: 30, color: const Color(0xFF8E44AD)), 
    Category(name: 'Food',  value: 20, color: const Color(0xFFFF9B71)), 
    Category(name: 'Bills', value: 18, color: Colors.green),
    Category(name: 'Fun',   value: 16, color: const Color.fromARGB(255, 202, 24, 17)),
    Category(name: 'Other', value: 16, color: const Color(0xFF3498DB)),
  ];

  @override
  Widget build(BuildContext context){
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