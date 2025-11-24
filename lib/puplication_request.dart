import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestProfileSheet extends StatelessWidget {
  final Map<String, dynamic> request;
  final String userName;

  const RequestProfileSheet({
    super.key,
    required this.request,
    required this.userName,
  });

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber == "0") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Numéro invalide')),
      );
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(callUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Impossible de lancer l’appel')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = 500.0;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Center(
            child: Text(
              'Request Information',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Published by: $userName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Age: ${request['age'] ?? '--'}"),
                Text("Gender: ${request['gender'] ?? '--'}"),
                Text("Need Type: ${request['needType'] ?? '--'}"),
                Text("Blood Type: ${request['bloodGroup'] ?? '--'}"),
                Text("Location: ${request['location'] ?? '--'}"),
                Text("Phone: ${request['phone'] ?? '--'}"),
              ],
            ),
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _makePhoneCall(context, request['phone'] ?? '0'),
              icon: const Icon(Icons.call),
              label: const Text('Call Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
