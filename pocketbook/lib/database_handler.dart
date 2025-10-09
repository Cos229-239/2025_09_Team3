//import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:intl/intl.dart';

class DatabaseHandler {
  late Database db;
  static int userID = -1;
  static DatabaseHandler? databaseInstance;
  DatabaseHandler._create(this.db);

  static Future<DatabaseHandler> create() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pocketbook_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS user_data(userID INTEGER PRIMARY KEY AUTOINCREMENT, fname TEXT, lname TEXT, email TEXT, account_balance REAL, password_hash TEXT, hash_salt TEXT);',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS spending_logs(userID INTEGER, category TEXT, category_color TEXT, caption TEXT, amount REAL, date_time TEXT);',
        );
      },
      version: 1,
    );
    return DatabaseHandler._create(db);
  }

  void manualUpdate() async {
    //To be manually edited and run, only if needed
    
  }

  Future<void> addUser(
    String first,
    String last,
    String email,
    String password,
  ) async {
    final String salt = BCrypt.gensalt();

    await db.insert('user_data', {
      'fname': first,
      'lName': last,
      'email': email,
      'password_hash': BCrypt.hashpw(password, salt),
      'hash_salt': salt,
    });
  }

  Future<void> setUserBalance(int userID, double amount) async {
    db.update('user_data', 
    {'account_balance': amount},
    where: 'userID = ?',
    whereArgs: [userID],
    );
  }

  Future<void> addCategory(
    int userID,
    String categoryName,
    String categoryColor,
    double amount,
  ) async {
    await db.insert('spending_logs', {
      'userID': userID,
      'category': categoryName,
      'category_color': categoryColor,
      'amount': amount,
      'date_time': await getCurrentTime(),
    });
  }

  //For updating edited categories
  Future<void> updateCategory(
    int userID,
    String categoryName,
    String newName,
    String categoryColor,
    double amount,
  ) async {
    await db.update(
      'spending_logs',
      {'category': newName, 'category_color': categoryColor, 'amount': amount},
      where: 'userID = ? AND category = ? AND caption IS NULL',
      whereArgs: [userID, categoryName],
    );
    await db.update(
      // Update logs within a category as well
      'spending_logs',
      {'category': newName},
      where: 'userID = ? AND category = ? AND caption IS NOT NULL',
      whereArgs: [userID, categoryName],
    );
  }

  Future<void> updateLogs(int userID, String category, String caption, String newCaption, double amount, String dateAndTime, String newDateAndTime) async {
    await db.update(
      'spending_logs',
      {'caption': newCaption, 'amount' : amount, 'date_time' : newDateAndTime},
      where: 'userID = ? AND category = ? AND date_time = ? AND caption IS NOT NULL',
      whereArgs: [userID, category, dateAndTime],
    );
  }
//For deleting categories
  Future<void> deleteCategory(int userId, String categoryName)
  async{
    await db.delete(
      'spending_logs',
      where: 'userID = ? AND category = ?',
      whereArgs: [userId, categoryName]
    );
  }

  Future<void> deleteLog(int userID, String caption, String dateAndTime) async {
    await db.delete(
      'spending_logs',
      where: 'userID = ? AND caption = ? AND date_time = ?',
      whereArgs: [userID, caption, dateAndTime]
    );
  }

  Future<void> addSpending(
    int userID,
    String category,
    String caption,
    double amount,
  ) async {
    await db.insert('spending_logs', {
      'userID': userID,
      'category': category,
      'caption': caption,
      'amount': amount,
      'date_time': await getCurrentTime(),
    });
  }

  Future<int> getUserID(String email) async {
    final result = await db.query(
      'user_data',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.first['userID'] as int;
  }

  Future<void> setUserIDVar(String email) async {
    userID = await getUserID(email);
  }

  Future<List<Map<String, Object?>>> getUserData(int userID) async {
    return db.query('user_data', where: 'userID = ?', whereArgs: [userID]);
  }

  Future<List<Map<String, Object?>>> getUserDataFromEmail(String email) async {
    return db.query('user_data', where: 'email = ?', whereArgs: [email]);
  }

  Future<List<Map<String, Object?>>> getCategories(int userID) async {
    return db.query(
      'spending_logs',
      where: 'userID = ? AND caption IS NULL',
      whereArgs: [userID],
    );
  }
  
  Future<List<Map<String, Object?>>> getCategoriesFromName(int userID, String category) async {
    return db.query(
      'spending_logs',
      where: 'userID = ? AND category = ? AND caption IS NULL',
      whereArgs: [userID, category],
      
    );
  }

  Future<List<Map<String, Object?>>> getSpendingInCategory(
    int userID,
    String category,
  ) async {
    return db.query(
      'spending_logs',
      where: 'userID = ? AND category = ? AND caption IS NOT NULL',
      whereArgs: [userID, category],
      orderBy: 'date_time DESC',
    );
  }

  Future<List<Map<String, Object?>>> getSpendingLog(
    int userID,
  ) async {
    return db.query(
      'spending_logs',
      where: 'userID = ? AND caption IS NOT NULL',
      whereArgs: [userID],
      orderBy: 'date_time DESC',
    );
  }

  Future<bool> verifyUser(String email, String password) async {
    final user = await db.query(
      'user_data',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (user.isNotEmpty &&
        user.first["password_hash"] ==
            BCrypt.hashpw(
              password,
              user.first["hash_salt"] as String,
            )) // if email is registered, and if hashes match
    {
      return true;
    }
    return false;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat("MMM-dd-yyyy\nhh:mm:ss a");
    
    return formatter.format(now);
  }

  Future<bool> userExists(String email) async { // FUNCTION HAS NOT BEEN TESTED
    List<Map<String, Object?>> user = await getUserDataFromEmail(email);

    if (user.isEmpty) {
      return false;
    }
    return true;
  }

  Future<bool> categoryExists(String category) async { // FUNCTION HAS NOT BEEN TESTED
    List<Map<String, Object?>> categoryList = await getCategoriesFromName(userID, category);

    if (categoryList.isEmpty) {
      return false;
    }
    return true;
  }

  void debugClearLog() {
    db.execute("DELETE FROM spending_logs");
  }

  void debugClearUsers() {
    db.execute("DELETE FROM user_data");
  }
}
