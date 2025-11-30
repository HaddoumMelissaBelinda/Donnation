import 'dart:math';
import 'package:flutter/material.dart';
import 'email_service.dart';
import 'verify_code.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  String generateCode() {
    return (100000 + Random().nextInt(900000)).toString(); // 6 digits
  }

  Future<void> sendCode() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your email")),
      );
      return;
    }

    String code = generateCode();

    bool sent = await EmailService.sendResetCode(email, code);

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send email")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyCodePage(email: email, code: code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                hintText: "Enter your Email",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendCode,
              child: const Text("Send reset code"),
            ),
          ],
        ),
      ),
    );
  }
}
