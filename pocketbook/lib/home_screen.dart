import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketbook/add_deposit.dart';
import 'package:pocketbook/categories_screen.dart';
import 'package:pocketbook/helper_files.dart';
import 'package:pocketbook/log_screen.dart';
import 'package:pocketbook/sign_in_screen.dart';
import 'package:pocketbook/spendings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_handler.dart';

class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenStateManager();
}

class _HomeScreenStateManager extends State<HomeScreenState> {
  String? userName = "";
  double? balance = 0.00;
  List<String> categoryList = [];
  List<DropdownMenuEntry<String>> dropdownItems = [];
  final TextEditingController addAmountController = TextEditingController();
  final TextEditingController addCaptionController = TextEditingController();
  final TextEditingController addCategoryController = TextEditingController();
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;
  int userID = DatabaseHandler.userID;

  void reloadPage() {
    clearFields();
    setState(() {
      userName = "";
      balance = 0.00;
      categoryList = [];
      dropdownItems = [];
    });
    getUserData();
  }

  void clearFields() {
    addAmountController.clear();
    addCaptionController.clear();
    addCategoryController.clear();
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    clearFields();
    setState(() {
      userName = "";
      balance = 0.00;
      categoryList = [];
      dropdownItems = [];
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (Route<dynamic> route) => false,
    );
    //.then((value) => reloadPage());
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    //Grab info from DB
    List<Map<String, Object?>> userData = await db.getUserData(userID);
    List<Map<String, Object?>> userCategories = await db.getCategories(userID);
    if (mounted) {
      setState(() {
        if (userData.isNotEmpty) {
          String initialName = userData.first['fname'] as String;
          userName = firstLetterCapital(initialName);
          balance = 0;
        }

        if (userData.isNotEmpty && userData.first['account_balance'] != null) {
          balance = userData.first['account_balance'] as double;
        }

        if (userCategories.isNotEmpty) {
          categoryList = [];
          for (int i = 0; i < userCategories.length; i++) {
            categoryList.add(userCategories[i]['category'] as String);
          }
          dropdownItems = categoryList.map((value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList();
        } else {
          dropdownItems = [
            DropdownMenuEntry(
              value: "No categories created",
              label: "No categories created",
              enabled: false,
            ),
          ];
        }
      });
    }
  }

  void _addSpending() async {
    //Getting an error when amount is empty and trying to parse to double(JD)<-----------
    double amount = double.parse(addAmountController.text).abs();
    //make the amount auto negated
    amount = -amount.abs();
    String caption = addCaptionController.text;
    String category = addCategoryController.text;

    if (addAmountController.text.isEmpty ||
        addCaptionController.text.isEmpty ||
        addCategoryController.text.isEmpty) {
      
      showErrorSnackBar(context, 'Please fill in all fields.');
      return;
    }

    await db.addSpending(userID, category, caption, amount);

    double theBalance = (balance ?? 0.0) + amount;
    await db.setUserBalance(userID, theBalance);
   
    
    clearFields();
    getUserData();
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
            logout();
          },
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
                      'Account Balance\n\$${balance?.toStringAsFixed(2) ?? '0.00'}',
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
                          keyboardType: TextInputType.numberWithOptions(
                            signed: false,
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Amount',
                            //prefixText: '\$',
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
                              controller: addCategoryController,
                              width: 200,
                              hintText: "Category",
                              dropdownMenuEntries: dropdownItems,
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF3B0054),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          //calendar button for adding date if not today
                          IconButton.filled(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {
                              //add date picker functionality
                            },
                         ),
                          
                          IconButton.filled(
                            onPressed: () {
                              _addSpending();
                            },
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
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(),
                              ),
                            )
                            .then((value) => reloadPage());
                      }, // Added navigation to the categories button
                      icon: Icon(Icons.view_day),
                      style: IconButton.styleFrom(
                        fixedSize: Size(60, 60),
                        backgroundColor: Color(0xFFFF9B71),
                      ),
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
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const SpendingsScreen(),
                              ),
                            )
                            .then((value) => reloadPage());
                      },
                      icon: Icon(Icons.pie_chart),
                      style: IconButton.styleFrom(
                        fixedSize: Size(60, 60),
                        backgroundColor: Color(0xFFFF9B71),
                      ),
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
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const LogScreen(),
                              ),
                            )
                            .then((value) => reloadPage());
                      },
                      icon: Icon(Icons.attach_money),
                      style: IconButton.styleFrom(
                        fixedSize: Size(60, 60),
                        backgroundColor: Color(0xFFFF9B71),
                      ),
                    ),
                    Text('Log', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
               SizedBox(
                width: 80,
                child: Column(
                  children: [
                    IconButton.filled(
                      onPressed: () async{
                        
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddDeposit(),
                          ),
                        );
                        getUserData();
                      },
                      icon: Icon(Icons.add),
                      style: IconButton.styleFrom(
                        fixedSize: Size(60, 60),
                        backgroundColor: Color(0xFFFF9B71),
                      ),
                    ),
                    Text('Deposit', style: TextStyle(color: Colors.white)),
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
