import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainPage.dart';
import 'package:path/path.dart' as p; // alias pour éviter le conflit
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'login_page.dart';
// Fonction pour supprimer la DB
Future<void> resetDatabase() async {
  WidgetsFlutterBinding.ensureInitialized(); // garantit l'initialisation avant DB
  final dbPath = await getDatabasesPath();
  final dbFile = p.join(dbPath, 'donnation.db');
  await deleteDatabase(dbFile);
  print('✅ Database deleted: $dbFile');
}

void main() async {
  //await resetDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Donat Algeria',
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

  // 🔹 Vérifier la session avec SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  bool? loggedIn = prefs.getBool('isLoggedIn');
  int? userId = prefs.getInt('userId');

  Widget nextPage;
  if (loggedIn == true && userId != null) {
    nextPage = const MainPage(); // Utilisateur connecté
  } else {
    nextPage = LoginPage(); // Pas connecté
  }

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
