import 'package:flutter/material.dart';

class SpendingsSubmenu extends StatelessWidget {
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
  Widget build(BuildContext context) {

    Color textOn(Color bg) => ThemeData.estimateBrightnessForColor(bg) == Brightness.light ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFF3B0054),
      appBar: AppBar( 
        title:  Text(categoryName),  // Uses the category's name
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go Back',
          onPressed: () => Navigator.pop(context), 
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

            Positioned(
              bottom: 600,
              child: SizedBox(
                width: 375,
                height: 200,
                child: Container(
                  decoration: BoxDecoration(
                    color: categoryColor,  // Category Specific Color 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Spending Data',
                          style: TextStyle(
                            color: textOn(categoryColor),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          categoryName,  // Show category being viewed
                          style: TextStyle(
                            color: textOn(categoryColor).withValues(alpha: 0.9),
                            fontSize: 18,
                          ),
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 500,
              child: SizedBox(
                width: 425,
                height: 75,
                child: Container(
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.85),
                    border: Border.all(color: Colors.white, width: 3)),
                  child: Center(
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        color: textOn(categoryColor.withValues(alpha: 0.85)),
                        fontSize: 36,
                      ),
                    ),
                  ),
                )
              ),
            ),

          ],  // Children
        ),
      ),


    );
  }

  
}