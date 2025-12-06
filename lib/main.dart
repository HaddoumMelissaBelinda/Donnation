import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainPage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'login_page.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_service.dart';
import 'fcm_token_service.dart';
import 'firebase_background.dart';

// Instance globale
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// 🔥 Handler background (notifications quand app fermée)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 Notification en arrière-plan : ${message.notification?.title}");
}

// Fonction reset DB
Future<void> resetDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbPath = await getDatabasesPath();
  final dbFile = p.join(dbPath, 'donnation.db');
  await deleteDatabase(dbFile);
  print('✅ Database deleted: $dbFile');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Permissions + listeners
  await FCMService().initNotifications();


  // Token + stockage SQLite
  await FCMTokenService.initFCM();

  // Notifications locales
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const init = InitializationSettings(android: android);
  await flutterLocalNotificationsPlugin.initialize(init);

  // Channel unique et correct
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'donation_channel',
    'Notifications Donnation',
    description: 'Notifications pour Donnation',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Foreground → afficher notification
  FirebaseMessaging.onMessage.listen((message) {
    const androidDetails = AndroidNotificationDetails(
      'donation_channel',
      'Notifications Donnation',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notif = NotificationDetails(android: androidDetails);
    flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notif,
    );
  });

  runApp(const MyApp());
}

void showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', // identifiant du channel
    'Notifications', // nom du channel
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformDetails,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DonAlgeria',
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainPage();
  }

  Future<void> _navigateToMainPage() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('isLoggedIn');
    int? userId = prefs.getInt('userId');

    Widget nextPage =
    (loggedIn == true && userId != null) ? const MainPage() : LoginPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF990309),
      body: Center(
        child: Image.asset(
          'assets/logo1.png',
          width: 450,
          height: 450,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
