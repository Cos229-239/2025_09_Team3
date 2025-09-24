//import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  late Database db;

  DatabaseHandler._create(this.db);

  static Future<DatabaseHandler> create() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pocketbook_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS user_data(userID INTEGER PRIMARY KEY AUTOINCREMENT, fname TEXT, lname TEXT, email TEXT, account_balance REAL, password_hash TEXT, hash_salt TEXT ); CREATE TABLE IF NOT EXISTS spending_logs(userID INTEGER, category TEXT, categoryColor TEXT, caption TEXT, amount REAL, date_time TEXT);', //sql create commands
        );
      },
      version: 1,
    );
    return DatabaseHandler._create(db);
  }

  void updateTable() async {
    //To be manually edited and run, only if needed
 
  }

  void testUser() async {
    await db.insert('user_data', {
      'fname': 'TestPerson',
      'lname': 'TestPersonAgain',
      'email': 'abc@email.com',
      'account_balance': 0.00,
      'password_hash': '#####',
      'hash_salt': 'abcde',
    });
    var result = await db.query('user_data');
    print(result);
  }

  static DatabaseHandler? databaseInstance;

  void addUser(String first, String last, String email, String password) async { //Generate salt, append salt to password, store hashed password and salt, and all other data. Balance will be asked later

  }

  void setUserBalance(int userID, double amount) async { //adjust the user's account balance value

  }

  void addCategory(int userID, String categoryName, String categoryColor) async {

  }

  void addSpending(int userID, String category, String caption, double amount) async {

  }

  void getUserID() async {

  }

  void getUserData() async {

  }

  void getCategory() async {

  }

  void getSpending() async {
    
  }
}
