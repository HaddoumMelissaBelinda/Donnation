import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('donnation.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Table requests
    await db.execute('''
      CREATE TABLE requests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age TEXT NOT NULL,
        gender TEXT NOT NULL,
        needType TEXT NOT NULL,
        bloodGroup TEXT NOT NULL,
        phone TEXT NOT NULL,
        location TEXT NOT NULL
      )
    ''');

    // Table notifications
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receiverId INTEGER NOT NULL,
        message TEXT NOT NULL,
        location TEXT,
        bloodGroup TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

  }

<<<<<<< HEAD
Future<List<Map<String, dynamic>>> getNotifications(int receiverId) async {
  final db = await instance.database;
  return await db.query(
    'notifications',
    where: 'receiverId = ?',
    whereArgs: [receiverId],
    orderBy: 'id DESC',
  );
}
  Future<Map<String, dynamic>?> getCurrentUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'isLoggedIn = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  Future<void> markUserAsLoggedIn(int id) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'isLoggedIn': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
Future close() async {
  final db = await instance.database;
  db.close();
=======
  // Méthodes pour requests
  Future<int> insertRequest(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('requests', row);
  }

  // Méthodes pour notifications
  Future<int> insertNotification(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('notifications', data);
  }

  Future<List<Map<String, dynamic>>> getNotifications(int receiverId) async {
    final db = await instance.database;
    return await db.query(
      'notifications',
      where: 'receiverId = ?',
      whereArgs: [receiverId],
      orderBy: 'id DESC',
    );
  }

  // Méthode close
  Future close() async {
    final db = await instance.database;
    db.close();
  }
>>>>>>> origin/main
}
