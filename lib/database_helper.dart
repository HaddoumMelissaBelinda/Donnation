import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

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
    // Requests
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

    // Notifications
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

    // Users
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
        isLoggedIn INTEGER DEFAULT 0
      )
    ''');

    // Utilisateur test
    await db.insert('users', {
      'fullName': 'Test Donor',
      'gender': 'Male',
      'birthDate': '1990-01-01',
      'bloodGroup': 'A+',
      'address': 'Alger-Centre',
      'email': 'testdonor@mail.com',
      'phone': '0600000000',
      'password': hashPassword('123456'),
      'healthCondition': 'Good',
      'isLoggedIn': 1
    });
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

  // ---------------- REQUESTS ----------------
  Future<int> insertRequest(Map<String, dynamic> row) async {
      print('$row');
      final db = await instance.database;
      final result = await db.insert('requests', row);
      return result;
  }
  // ---------------- GET ALL USERS ----------------
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

// ---------------- GET DONORS (utilisateurs connectés) ----------------
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
    return await db.query(
      'notifications',
      where: 'receiverId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> updateNotificationStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update('notifications', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> sendRequestNotifications(int requestId) async {
    await insertNotification({
      'senderId': null,
      'senderName': 'System',
      'receiverId': 1,
      'type': 'request',
      'message': 'Un patient a besoin de sang !',
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
