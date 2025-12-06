import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;



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

    // Optionnel : supprimer la base existante pour repartir à zéro (en dev seulement)
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // <-- ne pas oublier
    );
  }

// Fonction de migration
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajoute la colonne userId si elle n'existe pas
      await db.execute(
          'ALTER TABLE requests ADD COLUMN userId INTEGER DEFAULT NULL'
      );
    }
  }



  Future _createDB(Database db, int version) async {
    // TABLE USERS
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        gender TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        bloodGroup TEXT NOT NULL,
        address TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        healthCondition TEXT NOT NULL,
        isLoggedIn INTEGER DEFAULT 0,
        profileImage TEXT,
        fcmToken TEXT
      )
    ''');

    // TABLE REQUESTS
    await db.execute('''
      CREATE TABLE requests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT NOT NULL,
        age TEXT NOT NULL,
        gender TEXT NOT NULL,
        needType TEXT NOT NULL,
        bloodGroup TEXT NOT NULL,
        phone TEXT NOT NULL,
        location TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // TABLE NOTIFICATIONS
    await db.execute('''
      CREATE TABLE notifications(
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
  }

  // ---------------- UTILS ----------------
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ---------------- USERS ----------------
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isNotEmpty) return res.first;
    return null;
  }
  Future<int?> getLoggedUserId() async {
    final db = await instance.database;
    final users = await db.query('users', where: 'isLoggedIn = ?', whereArgs: [1]);
    if (users.isNotEmpty) return users.first['id'] as int?;
    return null;
  }
  Future<int> insertUser(Map<String, dynamic> userData) async {
    final db = await instance.database;
    userData['password'] = hashPassword(userData['password']);
    return await db.insert('users', userData);
  }

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData) async {
    final existingUser = await getUserByEmail(userData['email']);
    if (existingUser != null) {
      return {'success': false, 'message': 'Cet email est déjà utilisé'};
    }
    final id = await insertUser(userData);
    return {'success': true, 'message': 'Inscription réussie', 'userId': id};
  }

  // Update user profile (name, phone, address, email, etc.)
  Future<void> updateUserProfile(int userId, Map<String, dynamic> updatedData) async {
    final db = await instance.database;
    await db.update(
      'users',
      updatedData,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserProfileImage(int userId, String imagePath) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'profileImage': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }


  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await instance.database;
    final hashed = hashPassword(password);
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashed],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<void> markUserAsLoggedIn(int userId) async {
    final db = await instance.database;
    await db.update('users', {'isLoggedIn': 1}, where: 'id = ?', whereArgs: [userId]);
  }
  Future<void> markUserAsLoggedOut(int userId) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'isLoggedIn': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    final db = await instance.database;
    final hashed = hashPassword(newPassword);

    final res = await db.update(
      'users',
      {'password': hashed},
      where: 'email = ?',
      whereArgs: [email],
    );

    return res > 0; // true si modification OK
  }
  // ---------------- REQUESTS ----------------
  Future<int> insertRequest(Map<String, dynamic> row) async {
    final db = await instance.database;
    row['date'] = DateTime.now().toIso8601String();
    print('$row');
    final result = await db.insert('requests', row);
    print('Inserted request ID: $result');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getDonors() async {
    final db = await instance.database;
    return await db.query(
        'users',
        where: 'isLoggedIn = ?',
        whereArgs: [1]
    );
  }
  // ---------------- NOTIFICATIONS ----------------
  Future<int> insertNotification(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('notifications', data);
  }

  Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) async {
    final db = await instance.database;
    return await db.query('notifications', where: 'receiverId = ?', whereArgs: [userId], orderBy: 'timestamp DESC');
  }

  Future<int> updateNotificationStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update('notifications', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  // Récupérer un utilisateur par ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await instance.database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // ENVOI NOTIFICATIONS → DONNEURS
  Future<void> sendGeneralRequest(int requestId) async {
    final db = await instance.database;
    final requestList = await db.query('requests', where: 'id = ?', whereArgs: [requestId]);
    if (requestList.isEmpty) return;
    final req = requestList.first;

    final donors = await db.query(
      'users',
      where: 'bloodGroup = ? AND address = ? AND id != ? AND isLoggedIn = ?',
      whereArgs: [req['bloodGroup'], req['location'], req['userId'], 1],
    );

    for (var donor in donors) {
      final notif = {
        'senderId': req['userId'],
        'senderName': req['name'],
        'receiverId': donor['id'],
        'type': 'general_request',
        'message': "Un patient à ${req['location']} a besoin de sang ${req['bloodGroup']}. Voulez-vous aider ?",
        'location': req['location'],
        'bloodGroup': req['bloodGroup'],
        'status': 'pending',
        'timestamp': DateTime.now().toIso8601String(),
      };

      await insertNotification(notif);

      final token = donor['fcmToken'] as String?;
      if (token != null && token.isNotEmpty) {
        await sendFCM(token: token, title: "Nouvelle demande générale", body: notif['message'] as String);
      }
    }
  }

  Future<void> sendDirectRequest(int patientId, int donorId, String patientName, String bloodGroup) async {
    final notif = {
      'senderId': patientId,
      'senderName': patientName,
      'receiverId': donorId,
      'type': 'direct_request',
      'message': "$patientName souhaite recevoir votre aide pour une transfusion.",
      'bloodGroup': bloodGroup,
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await insertNotification(notif);

    final donor = await getUserById(donorId);
    final token = donor?['fcmToken'] as String?;
    if (token != null && token.isNotEmpty) {
      await sendFCM(token: token, title: "Demande directe", body: notif['message'] as String);
    }
  }

  Future<void> respondToRequest(int notificationId, bool accepted) async {
    final db = await database;
    final notifList = await db.query('notifications', where: 'id = ?', whereArgs: [notificationId]);
    if (notifList.isEmpty) return;

    final notif = notifList.first;

    await db.update('notifications', {'status': accepted ? 'accepted' : 'refused'}, where: 'id = ?', whereArgs: [notificationId]);

    final patientData = await getUserById(notif['senderId'] as int);
    final patientToken = patientData?['fcmToken'] as String?;
    if (patientToken != null && patientToken.isNotEmpty) {
      await sendFCM(
        token: patientToken,
        title: accepted ? "Donneur accepté" : "Donneur refusé",
        body: accepted
            ? "Le donneur ${notif['receiverId']} a accepté votre demande."
            : "Le donneur ${notif['receiverId']} a refusé votre demande.",
      );
    }

    await insertNotification({
      'senderId': notif['receiverId'] as int,
      'senderName': notif['senderName'] ?? 'Donor',
      'receiverId': notif['senderId'] as int,
      'type': accepted ? 'donor_accepted' : 'donor_refused',
      'message': accepted
          ? "Le donneur a accepté votre demande."
          : "Le donneur a refusé votre demande.",
      'status': 'info',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ENVOYER FCM
  Future<void> sendFCM({required String token, required String title, required String body}) async {
    final data = {
      "to": token,
      "notification": {"title": title, "body": body, "sound": "default"},
      "priority": "high",
      "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "status": "done"}
    };

    await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=TON_SERVER_KEY_FCM",
      },
      body: jsonEncode(data),
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}