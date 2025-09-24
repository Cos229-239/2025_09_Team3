import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Category {
  String name;
  double budget;
  Color color;

  Category({
    required this.name,
    required this.budget,
    required this.color,
  });
}

class CategoryCreation extends StatefulWidget {
  final void Function(Category) onSave;
  const CategoryCreation({super.key, required this.onSave});

  @override
  State<CategoryCreation> createState() => _CategoryCreationState();
}
class _CategoryCreationState extends State<CategoryCreation> {
  final TextEditingController _categoryNameController = TextEditingController();
  double _budgetValue = 0.0;
  Color _chosenColor = const Color.fromARGB(255, 2, 128, 77);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color.fromARGB(255, 200, 200, 200),
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
                   max: 2000,
                   divisions: 200,
                   label: '$_budgetValue',
                   onChanged: (value) {
                     setState(() {
                       _budgetValue = value;
                     });
                   },
                 ),
                 SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Choose a Color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: _chosenColor,
                              onColorChanged: (color) {
                                setState(() {
                                  _chosenColor = color;
                                });
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _chosenColor, // <-- Use the chosen color here
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Choose Color')
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      Category(
                        name: _categoryNameController.text,
                        budget: _budgetValue,
                        color: _chosenColor,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, 
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Save')
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

