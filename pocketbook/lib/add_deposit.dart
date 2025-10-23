import 'package:flutter/material.dart';
import 'package:pocketbook/helper_files.dart';
import 'database_handler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';



class AddDeposit extends StatefulWidget {
  const AddDeposit({super.key});

  @override
  State<AddDeposit> createState() => _AddDepositState();
}

class _AddDepositState extends State<AddDeposit> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;

   //date variables
  DateTime selectedDate = DateTime.now();
  String dateDisplay = "Today";

  Future<void> _selectDate() async{
DateTime? picked = await showDatePicker(

  context: context,
  initialDate: selectedDate,
  firstDate: DateTime(2000),
  lastDate: DateTime.now(),
  );

  if(picked != null){
    setState((){
      selectedDate = picked;
      DateTime now = DateTime.now();
      if (picked.year == now.year && picked.month == now.month && picked.day == now.day) {
        dateDisplay = "Today";
      } else {
        dateDisplay = DateFormat('MMM dd, yyyy').format(picked);
      }
    });
  }

}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color.fromARGB(255, 200, 200, 200),
 
      appBar: AppBar(
        title: const Text('Add Deposit'),
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
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child:  Center(
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
                        'Add a Deposit',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF280039),
                        ),
                      ),
                         const SizedBox(height: 10),
                              Text(
                                'Date: $dateDisplay',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255,50,50,50),
                                ),
                              ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _amountController,
                         inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ), 
                                ],
                        keyboardType: TextInputType.numberWithOptions(
                          signed: false,
                          decimal: true,
                        ),
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
                        onPressed: () async{
                          _selectDate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, 
                          foregroundColor: Colors.black,
                        ),
                        
                        child: const Text('Select Date')
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async{
                          _addDeposit();
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
          )
        ]
      )
    );
  }

  //Function for adding deposit to database
  void _addDeposit()  
  async{
    //error checking for fields
    if(_amountController.text.isEmpty || _originController.text.isEmpty){
      showErrorSnackBar(context, 'Please fill in all fields to add a deposit');
      return;
    }

    try{
      double amount = double.parse(_amountController.text);
      amount =amount.abs(); //keeps deposits positive
      String origin = firstLetterCapital(_originController.text.trim());
      
      
      //adds deposit to database
      await db.addSpending(
        DatabaseHandler.userID,
        'Deposit',
        origin,
        amount,
      );

      //obtain user data
      final userData = await db.getUserData(DatabaseHandler.userID);
      double theBalance = 0.0;
      if(userData.isNotEmpty&& userData.first['account_balance'] !=null){
        //updates balance to the first index of user data
        theBalance = userData.first['account_balance'] as double;
      }
      //updates the users balance
      double newBalance = theBalance + amount;
      await db.setUserBalance(DatabaseHandler.userID, newBalance);

      if(mounted) {
        showErrorSnackBar(context, 'Deposit of \$${amount.toStringAsFixed(2)} from $origin added successfully!');
        Navigator.of(context).pop();
      }
    }catch(e){
     showErrorSnackBar(context, 'Invalid amount. Please enter a valid amount.');
    }
  }
}