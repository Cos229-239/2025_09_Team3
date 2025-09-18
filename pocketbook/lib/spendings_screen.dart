import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpendingsScreen extends StatefulWidget{
  const SpendingsScreen({super.key});

  @override
  State<SpendingsScreen> createState() => _SpendingsScreenState();
}

class _SpendingsScreenState extends State<SpendingsScreen> {
  final List<bool> _pressed = List<bool>.filled(5, false);

  @override
  Widget build(BuildContext context){



    return Scaffold(
      backgroundColor: Color(0xFF3B0054),
      appBar: AppBar( 
        title: Text('Spendings'),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.settings), tooltip: 'Setting Icon', onPressed: () {}, 
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

            Container( // Breakdown box & text
              width: 425,
              height: 75,
              decoration: BoxDecoration(color: Color(0xFF280039),
              ), 
              child: const Center(
                child: Text('Breakdown',
                style: TextStyle(color: Colors.white, fontSize: 36),
                ),
              ),
            ),


            Positioned(
              bottom: 125,
              child: SizedBox(
                width: 300,
                height: 300,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 75,
                    sections: _demoSections(),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),


            for (int i = 0; i < 5; i++) // Demo Tappable Categories
              Positioned(
                bottom: -70 - (i * 70),
                child: _ActionTile(
                  width: 350, 
                  height: 50, 
                  color: _pressed[i]
                    ? Colors.green
                    :const Color(0xFFFF9B71), 
                  onTap: (){
                    setState(() {
                      _pressed[i] = !_pressed[i];
                    });
                  },
                ),
              ),
          ],  // Children
        ),
      ),
    );
  }

  List<PieChartSectionData> _demoSections() {
    return[
      PieChartSectionData(value: 30, title: 'Rent',   radius: 70, titleStyle: const TextStyle(color: Colors.white)),
      PieChartSectionData(value: 20, title: 'Food',   radius: 70, color: const Color(0xFFFF9B71), titleStyle: const TextStyle(color: Colors.black)),
      PieChartSectionData(value: 18, title: 'Bills',  radius: 70, color: Colors.green, titleStyle: const TextStyle(color: Colors.white)),
      PieChartSectionData(value: 16, title: 'Fun',    radius: 70, color: const Color(0xFF9B59B6), titleStyle: const TextStyle(color: Colors.white)),
      PieChartSectionData(value: 16, title: 'Other',  radius: 70, color: const Color(0xFF3498DB), titleStyle: const TextStyle(color: Colors.white)),
    ];
  }

}




// Reusable, tappable rectangle(s)
class _ActionTile extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.width,
    required this.height,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material( 
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.greenAccent.withValues(alpha: 0.3), // ripple color
        highlightColor: Colors.green.withValues(alpha: 0.2),   // pressed color
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

