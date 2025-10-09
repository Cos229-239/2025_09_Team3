import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pocketbook/database_handler.dart';
import 'package:pocketbook/helper_files.dart';

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
  //allows for editing categories
  final Category? initialCategory;
  const CategoryCreation({super.key, this.initialCategory});

  @override
  State<CategoryCreation> createState() => _CategoryCreationState();
}

class _CategoryCreationState extends State<CategoryCreation> {
  @override
  void initState() {
    super.initState();
    //allows for Prefilling of fields when editing
    if (widget.initialCategory != null) {
      _categoryNameController.text = widget.initialCategory!.name;
      _budgetValue = widget.initialCategory!.budget;
      _chosenColor = widget.initialCategory!.color;
    }
  }
  final TextEditingController _categoryNameController = TextEditingController();
  double _budgetValue = 0.0;
  Color _chosenColor = const Color.fromARGB(255, 2, 128, 77);
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;

  Future<void> addCategory() async {
    //string for text controller and auto capitalize first letter of category name
    String catName = _categoryNameController.text;
    bool nameExists = await db.categoryExists(catName);
    if (nameExists) {
      showErrorSnackBar(context, 'Category already exists');
      return;
    }
    if (catName.isNotEmpty&&_budgetValue!=0) {
      catName = firstLetterCapital(catName);
    }
    else {
      showErrorSnackBar(context, 'Please enter category name and budget greater than 0.');
      return;
    }
    await db.addCategory(DatabaseHandler.userID, catName, _chosenColor.toHexString(), _budgetValue);
    Navigator.of(context).pop();
    
  }

//for saving edited categories
    void saveEditedCategory() async {
    String catName = _categoryNameController.text;
    bool nameExists = false;
    if (catName.isNotEmpty && _budgetValue != 0) {
      catName = firstLetterCapital(catName);
    }
    else {
      showErrorSnackBar(context, 'Please enter category name and budget greater than 0.');
      return;
    }
    if (widget.initialCategory?.name != catName) // if name is changed
    {
      nameExists = await db.categoryExists(catName);
    }
    if (widget.initialCategory != null && !nameExists) {
      await db.updateCategory(DatabaseHandler.userID, widget.initialCategory!.name, catName, _chosenColor.toHexString(), _budgetValue);
      Navigator.of(context).pop();
    }
    else if (nameExists)
    {
      showErrorSnackBar(context, 'Category already exists');
      
    }
  }

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
          height: 525,
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
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Category Name',
                    hintText: 'Enter category name',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF3B0054),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 117, 20, 158),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                    // updated to save edited categories
                    if (widget.initialCategory != null) {
                      saveEditedCategory();
                    } else {
                      addCategory();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, 
                    foregroundColor: Colors.black,
                  ),
                  
                  child: const Text('Save')
                ),
                if(widget.initialCategory !=null)
                const SizedBox(height: 15),
                if(widget.initialCategory !=null)
                ElevatedButton(
                  onPressed: () 
                  async {
                    //dailog box to confirm deletion
                    bool? deleteConfirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: Text('Are you sure you would like to continue with the deletion of the "${widget.initialCategory!.name}" category and all related transaction logs? This action cannot be undone.'),
                          actions:[
                            TextButton(
                              onPressed:() => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),

                            TextButton(
                              onPressed:() => Navigator.of(context).pop(true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red),),
                            ),
                          ]
                        );
                      }

                    );

                    if (deleteConfirm == true) {
                    await db.deleteCategory(
                      DatabaseHandler.userID, widget.initialCategory!.name);
                      Navigator.of(context).pop();
                     
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 17, 0), 
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete Category'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

