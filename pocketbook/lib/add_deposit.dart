import 'package:flutter/material.dart';
import 'database_handler.dart';


class AddDeposit extends StatefulWidget {
  const AddDeposit({super.key});

  @override
  State<AddDeposit> createState() => _AddDepositState();
}

class _AddDepositState extends State<AddDeposit> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;

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
                  'Add a Depostit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF280039),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Deposit Amount',
                    hintText: 'Enter deposit amount',
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
                  'Where is the deposit from?: ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF280039),
                  ),
                ),
                const SizedBox(height: 30),
                 TextFormField(
                  controller: _originController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Deposit Source',
                    hintText: 'Enter deposit source',
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
               
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // add functionality to add deposit to database
                  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, 
                    foregroundColor: Colors.black,
                  ),
                  
                  child: const Text('Add Deposit')
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Function for adding deposit to database
  void _addDeposit()  
  async{
    //error checking for fields
    if(_amountController.text.isEmpty || _originController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields to add a deposit'))
      );
      return;
    }

    try{
      double amount = double.parse(_amountController.text);
      amount =amount.abs(); //keeps deposits positive
      String origin = _orginController
    }
  }
}