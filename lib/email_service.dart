import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  static Future<bool> sendResetCode(String email, String code) async {
    String username = "haddoummelissa@gmail.com";
    String password = "dfsj zvyz sykn slyc"; // mdp application Google

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, "Blood Donation App")
      ..recipients.add(email)
      ..subject = "Password Reset Code"
      ..text = "Your password reset code is: $code";

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print("Email error: $e");
      return false;
    }
  }
}
