import 'package:flutter/material.dart';
import 'package:pocketbook/categories_screen.dart';
import 'package:pocketbook/home_screen.dart';

class CategoryCreation extends StatelessWidget {
  const CategoryCreation({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Category Creation'),
        centerTitle: true,
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back Icon',
          onPressed: () {
            Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                    );
          }, //TODO: Assign button action
        ),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 500,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9B71),
            border: Border.all(
              color: const Color(0xFF280039),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}