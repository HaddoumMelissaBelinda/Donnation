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
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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
    // Création initiale de la table
    await db.execute('''
  CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    senderId INTEGER,
    senderName TEXT,
    receiverId INTEGER NOT NULL,
    type TEXT,
    message TEXT NOT NULL,
    location TEXT,
    bloodGroup TEXT,
    status TEXT,
    timestamp TEXT NOT NULL
  )
''');

    // Table users (optionnelle, si tu veux gérer login)
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        isLoggedIn INTEGER DEFAULT 0
      )
    ''');
  }

  // ---------------- Méthodes Requests ----------------
  Future<int> insertRequest(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('requests', row);
  }

  // ---------------- Méthodes Notifications ----------------
  // Insérer une notification
  Future<int> insertNotification(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('notifications', data);
  }

  // Récupérer toutes les notifications (sans filtrer)
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await instance.database;
    final result = await db.query(
      'notifications',
      orderBy: 'timestamp DESC', // les plus récentes en premier
    );
    return result;
  }

  Future<void> sendRequestNotifications(int requestId) async {
    final db = await database;

    // Récupérer uniquement les utilisateurs qui sont des donneurs
    final donors = await db.query(
      'users',
      where: 'type = ?',
      whereArgs: ['Donor'],
    );

    for (var donor in donors) {
      await insertNotification({
        'senderId': null,
        'senderName': 'System',
        'receiverId': donor['id'], // id du donneur
        'type': 'request',
        'message': 'Un patient a besoin de sang !',
        'status': 'pending',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }



  // Mettre à jour le statut d'une notification
  Future<int> updateNotificationStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'notifications',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- Méthodes Users ----------------
  Future<Map<String, dynamic>?> getCurrentUser(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'utilisateur',
      where: 'email = ? AND mot_de_passe = ?',
      whereArgs: [email, password],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }


  /// Marquer un utilisateur comme connecté
  Future<void> markUserAsLoggedIn(int userId) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'isLoggedIn': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
//-----------------search donors----------
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final db = await instance.database;

    if (query.isEmpty) {
      // Si la barre de recherche est vide → renvoie tous les enregistrements
      return await db.query('users');
    }

    // Rechercher dans plusieurs colonnes
    return await db.query(
      'users',
      where: '''
      name LIKE ? OR
      age LIKE ? OR
      gender LIKE ? OR
      needType LIKE ? OR
      bloodGroup LIKE ? OR
      phone LIKE ? OR
      location LIKE ?
    ''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%'
      ],
    );
  }


  // ---------------- Close DB ----------------
  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
