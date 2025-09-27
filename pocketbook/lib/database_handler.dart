//import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseHandler {
  late Database db;
  static int userID = -1;

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
    db.update('user_data', {'account_balance': amount});
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

  Future<List<Map<String, Object?>>> getCategories(int userID) async {
    return db.query(
      'spending_logs',
      where: 'userID = ? AND caption IS NULL',
      whereArgs: [userID],
    );
  }

  Future<List<Map<String, Object?>>> getSpendingInCategory(
    int userID,
    String category,
  ) async {
    return db.query(
      'spending_logs',
      where: 'userID = ? AND category = ?AND caption IS NOT NULL',
      whereArgs: [userID, category],
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

  Future<String> getCurrentTime() async {
    final result = await db.rawQuery('SELECT datetime("now") as currentTime');
    return result.first["currentTime"] as String;
  }

  void debugClearLog() {
    db.execute("DELETE FROM spending_logs");
  }
}
