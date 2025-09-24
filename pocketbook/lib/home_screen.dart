import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbook/account_creation.dart';
import 'package:flutter/services.dart';
import 'package:pocketbook/categories_screen.dart';
import 'package:pocketbook/spendings_screen.dart';

class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenStateManager();
}

class _HomeScreenStateManager extends State<HomeScreenState> {
  String userName = "PLACEHOLDER";
  double balance = 0;
  List<String> categoryList = ["Bills", "Leisure"];
  final TextEditingController addAmountController = TextEditingController();
  final TextEditingController addCaptionController = TextEditingController();
  final TextEditingController addCategotyController = TextEditingController();

  //TODO: Method here to draw variable details from database
  void _populatePageVars() {
    //Grab info from DB

    userName = "NewUsername";
    balance = 15.00;
    categoryList = ["Things", "More Things"];
  }

  //TODO: Database integration and edge cases for addSpending
  void _addSpending() {
    double amount = double.parse(addAmountController.text);
    String caption = addCaptionController.text;
    print('$amount $caption'); //add to spending DB
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3B0054),
      appBar: AppBar(
        //Top bar across screen
        title: Text('PocketBook'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings),
          tooltip: 'Setting Icon',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AccountCreation()),
            );}, //TODO: Assign button actions
        ),
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(30), //Welcome Message
            child: Text(
              'Hi, $userName!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ), //Balance section outer border
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  //Balance section content
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9B71),
                    border: Border.all(color: Color(0xFF3B0054), width: 3),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      'Account Balance\n\$$balance',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ), //Spending Section padding
            child: Center(
              child: Container(
                //spending section outer border
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  //Spending section content
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9B71),
                    border: Border.all(color: Color(0xFF3B0054), width: 3),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Add Spending',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: TextField(
                          controller: addAmountController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ), //Not fully sure what this means, but it should lock the $ amount to 2 decimal places
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Amount',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF3B0054),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 117, 20, 158),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: TextField(
                          controller: addCaptionController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Caption',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF3B0054),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 117, 20, 158),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      //DropdownMenu<>(),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            
                            child: DropdownMenu<String>(
                              width: 250,
                              hintText: "Category",
                              dropdownMenuEntries: categoryList.map((selection) {
                                return DropdownMenuEntry<String>(
                                  value: selection,
                                  label: selection,
                                );
                              }).toList(),
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF3B0054),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(15)
                                ),
                              ),
                            ),
                          ),
                          IconButton.filled(
                            //TODO: Match fill color with background
                            onPressed: _addSpending,
                            icon: Icon(Icons.add),
                            color: Colors.white,
                            //style: IconButton.styleFrom(backgroundColor: Color(0xFF3B0054))
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Container()),
          Row(
            children: [
              //Navigation buttons
              Expanded(child: Container()),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    IconButton.filled(
                      onPressed: () { 
                        Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                    );}, // Added navigation to the categories button
                      icon: Icon(Icons.view_day),
                      style: IconButton.styleFrom(fixedSize: Size(60, 60), backgroundColor: Color(0xFFFF9B71)),
                    ),
                    Text('Categories', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    IconButton.filled(
                      onPressed: () {Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SpendingsScreen()),
                    );},
                      icon: Icon(Icons.pie_chart),
                      style: IconButton.styleFrom(fixedSize: Size(60, 60), backgroundColor: Color(0xFFFF9B71)),
                    ),
                    Text('Spending', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    IconButton.filled(
                      onPressed: () {},
                      icon: Icon(Icons.attach_money),
                      style: IconButton.styleFrom(fixedSize: Size(60, 60), backgroundColor: Color(0xFFFF9B71)),
                    ),
                    Text('Log', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsetsGeometry.all(10)),
        ],
      ),
    );
  }
}
