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
          'CREATE TABLE IF NOT EXISTS user_data(userID INTEGER PRIMARY KEY AUTOINCREMENT, fname TEXT, lname TEXT, email TEXT, account_balance REAL, password_hash TEXT, hash_salt TEXT, monthly_budget REAL DEFAULT 1500.0)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS spending_logs(userID INTEGER, category TEXT, category_color TEXT, caption TEXT, amount REAL, date_time TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Check if monthly_budget column exists before adding
          final result = await db.rawQuery(
            "PRAGMA table_info(user_data)",
          );
          bool columnExists = result.any((row) => row['name'] == 'monthly_budget');
          if (!columnExists) {
            await db.execute('ALTER TABLE user_data ADD COLUMN monthly_budget REAL DEFAULT 1500.0');
          }
        }
      },
      version: 2,
    );
    return DatabaseHandler._create(db);
  }

  void manualUpdate() async {
    // To be manually edited and run, only if needed
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
      'monthly_budget': 1500.0, // Default budget for new users
    });
  }

  Future<void> setUserBalance(int userID, double amount) async {
    db.update(
      'user_data',
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

  Future<void> updateEmail(
    int userID,
    String email,
  ) async {
    await db.update(
      'user_data',
      {'email': email},
      where: 'userID = ?',
      whereArgs: [userID],
    );
  }

  Future<void> updatePassword(int userID, String password) async {
    final String salt = BCrypt.gensalt();
    await db.update(
      'user_data',
      {'password_hash': BCrypt.hashpw(password, salt), 'hash_salt': salt},
      where: 'userID = ?',
      whereArgs: [userID],
    );
  }

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
      'spending_logs',
      {'category': newName},
      where: 'userID = ? AND category = ? AND caption IS NOT NULL',
      whereArgs: [userID, categoryName],
    );
  }

  Future<void> updateLogs(
    int userID,
    String category,
    String caption,
    String newCaption,
    double amount,
    String dateAndTime,
    String newDateAndTime,
  ) async {
    await db.update(
      'spending_logs',
      {'caption': newCaption, 'amount': amount, 'date_time': newDateAndTime},
      where: 'userID = ? AND category = ? AND date_time = ? AND caption IS NOT NULL',
      whereArgs: [userID, category, dateAndTime],
    );
  }

  Future<void> deleteAllFromUser(int userID) async {
    await db.delete('spending_logs', where: 'userID = ?', whereArgs: [userID]);
  }

  Future<void> deleteCategory(int userId, String categoryName) async {
    await db.delete(
      'spending_logs',
      where: 'userID = ? AND category = ?',
      whereArgs: [userId, categoryName],
    );
  }

  Future<void> deleteLog(int userID, String caption, String dateAndTime) async {
    await db.delete(
      'spending_logs',
      where: 'userID = ? AND caption = ? AND date_time = ?',
      whereArgs: [userID, caption, dateAndTime],
    );
  }

  Future<void> deleteAllLogs(int userID) async {
    await db.delete(
      'spending_logs',
      where: 'userID = ? AND caption IS NOT NULL',
      whereArgs: [userID],
    );
  }

  Future<void> addSpending(
    int userID,
    String category,
    String caption,
    double amount, {
    String? customDateTime,
  }) async {
    await db.insert('spending_logs', {
      'userID': userID,
      'category': category,
      'caption': caption,
      'amount': amount,
      'date_time': customDateTime ?? await getCurrentTime(),
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

  Future<List<Map<String, Object?>>> getCategoriesFromName(
    int userID,
    String category,
  ) async {
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

  Future<List<Map<String, Object?>>> getSpendingLog(int userID) async {
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
            )) {
      return true;
    }
    return false;
  }

  Future<bool> verifyPassword(int userID, String password) async {
    final user = await db.query(
      'user_data',
      where: 'userID = ?',
      whereArgs: [userID],
    );

    if (user.isNotEmpty &&
        user.first["password_hash"] ==
            BCrypt.hashpw(
              password,
              user.first["hash_salt"] as String,
            )) {
      return true;
    }
    return false;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("MMM-dd-yyyy").format(now);
    String formattedTime = DateFormat("h:mm:ss a").format(now);
    String customDateTime = "$formattedDate\n$formattedTime";
    return customDateTime;
  }

  Future<bool> userExists(String email) async {
    List<Map<String, Object?>> user = await getUserDataFromEmail(email);

    if (user.isEmpty) {
      return false;
    }
    return true;
  }

  Future<bool> categoryExists(String category) async {
    List<Map<String, Object?>> categoryList = await getCategoriesFromName(
      userID,
      category,
    );

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

  Future<void> setMonthlyBudget(int userId, double budget) async {
    final db = this.db;
    await db.update(
      'user_data',
      {'monthly_budget': budget},
      where: 'userID = ?',
      whereArgs: [userId],
    );
  }

  Future<double> getMonthlyBudget(int userId) async {
    final db = this.db;
    final result = await db.query(
      'user_data',
      columns: ['monthly_budget'],
      where: 'userID = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty && result.first['monthly_budget'] != null
        ? result.first['monthly_budget'] as double
        : 1500.0; // Default if not set
  }
}