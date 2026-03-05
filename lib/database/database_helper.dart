import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  static Future<DatabaseHelper> getInstance() async {
    _database ??= await _instance._openDatabase();
    return _instance;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'paul_budget.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            currency TEXT NOT NULL,
            tag TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertExpense(Expense expense) async {
    return _database!.insert('expenses', expense.toMap());
  }

  Future<void> deleteExpense(int id) async {
    await _database!.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    final prefix = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-';
    final rows = await _database!.query(
      'expenses',
      where: "created_at LIKE ?",
      whereArgs: ['$prefix%'],
      orderBy: 'created_at DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }
}
