import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';
import 'dart:io';


class DonorProfileSheet extends StatelessWidget {
  final Map<String, dynamic> donor;
  final Map<String, dynamic> patient;

  const DonorProfileSheet({Key? key, required this.donor, required this.patient}) : super(key: key);

  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    } else {
      return const AssetImage('assets/profile.png');
    }
  }

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
        SnackBar(content: Text('❌ Impossible de lancer l’appel vers $phoneNumber')),
      );
    }
  }

  Future<void> _sendRequest(BuildContext context) async {
    final db = DatabaseHelper.instance;
    await db.insertNotification({
      'senderName': patient['name'],
      'receiverId': donor['id'],
      'type': 'request',
      'message': 'Voulez-vous donner votre sang ?',
      'location': donor['location'],
      'bloodGroup': donor['blood'],
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Demande envoyée au donneur')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: _getImageProvider(donor['image']),
          ),
          const SizedBox(height: 10),
          Text(
            donor['name'] ?? 'Unknown Donor',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Location: ${donor['location'] ?? 'Unknown'} • Blood Type: ${donor['blood'] ?? '--'}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _makePhoneCall(context, donor['phone'] ?? '0'),
                icon: const Icon(Icons.call),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.bloodtype),
                label: const Text('Request'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _sendRequest(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
