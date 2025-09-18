import 'package:flutter/material.dart';

class CategoryCreation extends StatefulWidget {
  const CategoryCreation({super.key});

  @override
  State<CategoryCreation> createState() => _CategoryCreationState();
}
class _CategoryCreationState extends State<CategoryCreation> {
  final TextEditingController _categoryNameController = TextEditingController();
   double _budgetValue = 0.0;

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
            Navigator.of(context).pop();
          },
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create a Category',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF280039),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Category Name',
                    hintText: 'Enter category name',
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Set Budget Limit: \$${_budgetValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF280039),
                  ),
                ),
                Slider(
                   value: _budgetValue,
                   min: 0,
                   max: 5000,
                   divisions: 100,
                   label: '$_budgetValue',
                   onChanged: (value) {
                     setState(() {
                       _budgetValue = value;
                     });
                   },
                 )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

