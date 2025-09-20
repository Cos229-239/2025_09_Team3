import 'package:flutter/material.dart';

class SpendingsSubmenu extends StatelessWidget {
  const SpendingsSubmenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0054),
      appBar: AppBar( 
        title: const Text('SubMenu Place Holder'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go Back',
          onPressed: () {}, 
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
                    color: const Color(0xFFFF9B71), 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 3)),
                  child: const Center(
                    child: Text(
                      'Spending Data Here',
                      style: TextStyle(color: Colors.black, fontSize: 24),
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
                    color: const Color(0xFFFF9B71),
                    border: Border.all(color: Colors.white, width: 3)),
                  child: const Center(
                    child: Text(
                      'Transactions',
                      style: TextStyle(color: Colors.black, fontSize: 36),
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