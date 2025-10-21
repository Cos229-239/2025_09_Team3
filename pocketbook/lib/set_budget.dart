import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketbook/database_handler.dart';
import 'package:pocketbook/helper_files.dart';

class SetBudget extends StatefulWidget {
  const SetBudget({super.key});

  @override
  State<SetBudget> createState() => _SetBudgetState();
}

class _SetBudgetState extends State<SetBudget> {
  final TextEditingController _budgetController = TextEditingController();
  double _budgetValue = 0.0;
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  Future<void> _loadCurrentBudget() async {
    try {
      final budget = await db.getMonthlyBudget(DatabaseHandler.userID);
      setState(() {
        _budgetValue = budget;
        _budgetController.text = budget.toStringAsFixed(2);
      });
    } catch (e) {
      debugPrint('Error loading budget: $e');
    }
  }

  Future<void> _saveBudget() async {
    if (_budgetController.text.isEmpty || _budgetValue <= 0) {
      showErrorSnackBar(context, 'Please enter a budget greater than 0.');
      return;
    }
    try {
      await db.setMonthlyBudget(DatabaseHandler.userID, _budgetValue);
      showErrorSnackBar(context, 'Monthly budget set to \$${(_budgetValue).toStringAsFixed(2)}.');
      Navigator.of(context).pop();
    } catch (e) {
      showErrorSnackBar(context, 'Error saving budget.');
      debugPrint('Error saving budget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 200, 200, 200),
      appBar: AppBar(
        title: const Text('Set Monthly Budget'),
        centerTitle: true,
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back Icon',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
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
                        'Set Monthly Budget',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF280039),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Monthly Budget',
                          hintText: 'Enter monthly budget',
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
                        onChanged: (value) {
                          setState(() {
                            try {
                              _budgetValue = double.parse(value);
                            } catch (e) {
                              _budgetValue = 0.0;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}