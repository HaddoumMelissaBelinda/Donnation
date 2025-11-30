import 'package:flutter/material.dart';
import 'reset_password.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  final String code;

  const VerifyCodePage({Key? key, required this.email, required this.code}) : super(key: key);

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final TextEditingController codeController = TextEditingController();

  void verify() {
    if (codeController.text.trim() == widget.code) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: widget.email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Code")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Enter the 6-digit code sent to your email."),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter code",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verify,
              child: const Text("Verify"),
            )
          ],
        ),
      ),
    );
  }
}
