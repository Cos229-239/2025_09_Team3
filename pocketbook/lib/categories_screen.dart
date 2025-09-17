import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
     leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back Icon',
          onPressed: () {}, //TODO: Assign button action
        ),
      ),
      body: const Center(
        child: Text(
          'Categories Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}