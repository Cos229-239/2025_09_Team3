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
import 'package:intl/intl.dart';

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

  //date variables
  DateTime selectedDate = DateTime.now();
  String dateDisplay = "Today";

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

  void changeEmail() async {
    final TextEditingController oldEmailController = TextEditingController();
    final TextEditingController newEmailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        title: const Text('Change Email'),
        actions: <Widget>[
          TextField(
            controller: oldEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Current Email',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: newEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'New Email',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async => {
                  if (oldEmailController.text.isEmpty ||
                      newEmailController.text.isEmpty ||
                      passwordController.text.isEmpty)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter all fields'),
                        ),
                      ),
                    }
                  else if (await db.userExists(newEmailController.text))
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email is already in use'),
                        ),
                      ),
                    }
                  else if (await db.verifyUser(
                    oldEmailController.text,
                    passwordController.text,
                  ))
                    {
                      db.updateEmail(userID, newEmailController.text),
                      Navigator.pop(context, true),
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email updated')),
                      ),
                    }
                  else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid email or password'),
                        ),
                      ),
                    },
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;

    //verify new email is available, and that old email and password match
  }

  void changePassword() async {
    final TextEditingController oldPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController =
        TextEditingController();
    final TextEditingController confirmNewPassword = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Change Password'),
        scrollable: true,
        actions: <Widget>[
          TextField(
            controller: oldPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Current Password',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: confirmNewPassword,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async => {
                  if (oldPasswordController.text.isEmpty ||
                      newPasswordController.text.isEmpty ||
                      confirmNewPassword.text.isEmpty)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter all fields'),
                        ),
                      ),
                    }
                  else if (!await db.verifyPassword(
                    userID,
                    oldPasswordController.text,
                  ))
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Current password is incorrect'),
                        ),
                      ),
                    }
                  else if (oldPasswordController.text ==
                      newPasswordController.text)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New and old passwords cannot match'),
                        ),
                      ),
                    }
                  else if (newPasswordController.text !=
                      confirmNewPassword.text)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New passwords do not match'),
                        ),
                      ),
                    }
                  else
                    {
                      db.updatePassword(userID, newPasswordController.text),
                      Navigator.pop(context, true),
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated')),
                      ),
                    },
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;
    // Have user enter password to confirm
  }

  void resetLog() async {
    // Show confirmation dialog
    final TextEditingController passwordController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset Log'),
        scrollable: true,
        content: const Text(
          'Are you sure you want reset your logs? This action cannot be undone.\n\nEnter password to confirm',
        ),
        actions: <Widget>[
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async => {
                  if (await db.verifyPassword(userID, passwordController.text))
                    {db.deleteAllLogs(userID), Navigator.pop(context, true)}
                  else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incorrect Password')),
                      ),
                    },
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;
  }

  void resetAccount() async {
    // Show confirmation dialog
    final TextEditingController passwordController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Account'),
        scrollable: true,
        content: const Text(
          'Are you sure you want reset your account? This action cannot be undone.\n\nEnter password to confirm',
        ),
        actions: <Widget>[
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF3B0054),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 117, 20, 158),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async => {
                  if (await db.verifyPassword(userID, passwordController.text))
                    {
                      db.deleteAllFromUser(userID),
                      db.setUserBalance(userID, 0),
                      Navigator.pop(context, true),
                      reloadPage(),
                    }
                  else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incorrect Password')),
                      ),
                    },
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;
  }

  void logout() async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    // Selectively clear login-related preferences
    await prefs.clear();
    // Reset userID
    DatabaseHandler.userID = -1;

    clearFields();
    setState(() {
      userName = "";
      balance = 0.00;
      categoryList = [];
      dropdownItems = [];
    });

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (Route<dynamic> route) => false,
    );
  }


  @override
  void initState() {
    super.initState();
    getUserData();
  }

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
    if (addAmountController.text.isEmpty ||
        addCaptionController.text.isEmpty ||
        addCategoryController.text.isEmpty) {
      showErrorSnackBar(context, 'Please fill in all fields.');
      return;
    }
    double amount = double.parse(addAmountController.text).abs();
    //make the amount auto negated
    amount = -amount.abs();
    String caption = firstLetterCapital(addCaptionController.text).trim();
    String category = addCategoryController.text;

    String formattedDate = DateFormat("MMM-dd-yyyy").format(selectedDate);
    String formattedTime = DateFormat("h:mm:ss a").format(DateTime.now());
    String customDateTime = "$formattedDate\n$formattedTime";

    await db.addSpending(userID, category, caption, amount, customDateTime: customDateTime);

    double theBalance = (balance ?? 0.0) + amount;
    await db.setUserBalance(userID, theBalance);
    //Shows successful addition of expense
    showErrorSnackBar(context, 'Expense of \$${(-amount).toStringAsFixed(2)} for $caption added successfully.');

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
        leading: PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          icon: Icon(Icons.settings),
          tooltip: 'User Settings',
          onSelected: (String selection) {
            switch (selection) {
              case "ChangeEmail": // updateUser
                changeEmail();
              case "ChangePass": // updateUser
                changePassword();
              case "ResetLog": // deleteLog
                resetLog();
              case "ResetAcc": // deleteAllFromUser
                resetAccount();
              case "LogOut":
                logout();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: "ChangeEmail",
              child: Text("Change Email"),
            ),
            const PopupMenuItem<String>(
              value: "ChangePass",
              child: Text("Change Password"),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: "ResetLog",
              child: Text("Reset Log"),
            ),
            const PopupMenuItem<String>(
              value: "ResetAcc",
              child: Text("Reset Account"),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: "LogOut",
              child: Text("Log Out"),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
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
                          border: Border.all(
                            color: Color(0xFF3B0054),
                            width: 3,
                          ),
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
                          border: Border.all(
                            color: Color(0xFF3B0054),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                              children: [
                                Text(
                                  'Add Spending',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              //added a date display to show selected date.
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
                            
                          ],
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
                                    _selectDate();
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
                                      builder: (context) =>
                                          const CategoriesScreen(),
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
                          Text(
                            'Categories',
                            style: TextStyle(color: Colors.white),
                          ),
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
                                      builder: (context) =>
                                          const SpendingsScreen(),
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
                          Text(
                            'Spending',
                            style: TextStyle(color: Colors.white),
                          ),
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
                            onPressed: () async {
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
                          Text(
                            'Deposit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsetsGeometry.all(10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
