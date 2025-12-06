import 'package:firebase_messaging/firebase_messaging.dart';
import 'database_helper.dart';

class FCMTokenService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initFCM() async {
    String? token = await _messaging.getToken();

    if (token != null) {
      await saveTokenToDatabase(token);
      print("🔥 Token enregistré : $token");
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      print("🔄 Nouveau token FCM : $newToken");
      await saveTokenToDatabase(newToken);
    });
  }

  static Future<void> saveTokenToDatabase(String token) async {
    final db = DatabaseHelper.instance;
    final userId = await db.getLoggedUserId();
    if (userId != null) {
      await db.updateUserProfile(userId, {"fcmToken": token});
      print("💾 Token sauvegardé dans SQLite pour user $userId");
    }
  }
}
