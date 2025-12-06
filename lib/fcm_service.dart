import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // 🔥 Récupérer le token FCM
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // 🔥 Demander la permission + écouter les notifications
  Future<void> initNotifications() async {
    await _messaging.requestPermission();

    String? token = await _messaging.getToken();
    print("🔥 FCM TOKEN = $token");
  }
}
