import 'package:flutter/material.dart';
import 'database_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int? loggedUserId;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    loggedUserId = await DatabaseHelper.instance.getLoggedUserId();
    if (loggedUserId != null) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    if (loggedUserId == null) return;

    final data = await DatabaseHelper.instance.getNotificationsForUser(loggedUserId!);
    print("Notifications brutes: $data");

    final now = DateTime.now();
    final filtered = data.where((notif) {
      if (notif['status'] == 'accepted' || notif['status'] == 'refused') {
        final timestamp = DateTime.parse(notif['timestamp']);
        return now.difference(timestamp).inDays < 2;
      }
      return true;
    }).toList();

    print("Notifications filtrées: $filtered");
    setState(() => notifications = filtered);
  }


  Future<void> _respondToRequest(Map<String, dynamic> notif, bool accepted) async {
    final db = DatabaseHelper.instance;

    // Mettre à jour le statut de la notification
    await db.updateNotificationStatus(
      notif['id'],
      accepted ? 'accepted' : 'refused',
    );

    // Message pour le patient
    String message = accepted
        ? "Bonne nouvelle ! Le donneur a accepté votre demande de ${notif['type']}."
        : "Malheureusement, le donneur n'a pas pu répondre favorablement à votre demande de ${notif['type']}.";

    final senderId = notif['senderId']; // patient
    final donorName = notif['receiverName'] ?? 'Donor';

    if (senderId != null) {
      // Ajouter notification de réponse
      await db.insertNotification({
        'senderName': donorName,
        'senderId': notif['receiverId'], // donneur
        'receiverId': senderId,          // patient
        'type': 'response',
        'message': message,
        'status': 'info',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Récupérer FCM token du patient
      final patientData = await db.getUserById(senderId);
      final patientToken = patientData?['fcmToken'];
      if (patientToken != null && patientToken.isNotEmpty) {
        await db.sendFCM(
          token: patientToken,
          title: accepted ? "Réponse positive à votre demande" : "Réponse négative à votre demande",
          body: message,
        );
      }
    }

    // Recharger la liste des notifications
    _loadNotifications();
  }

  Color _getCardColor(Map<String, dynamic> notif) {
    switch (notif['status']) {
      case 'pending': return Colors.white;
      case 'accepted': return Colors.green.shade50;
      case 'refused': return Colors.red.shade50;
      case 'info': return Colors.blue.shade50;
      default: return Colors.white;
    }
  }

  Color _getSenderNameColor(Map<String, dynamic> notif) {
    switch (notif['status']) {
      case 'accepted': return Colors.green.shade800;
      case 'refused': return Colors.red.shade800;
      default: return Colors.black;
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _getCardColor(notif),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: Center(
              child: Container(
                width: 43, height: 43,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notif['status'] == 'pending' ? Colors.red : Colors.grey.shade400,
                ),
                child: const Center(child: Icon(Icons.notifications, color: Colors.white, size: 24)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif['senderName'] ?? 'System',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _getSenderNameColor(notif),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif['message'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.3),
                ),
                const SizedBox(height: 8),
                if (notif['type'] == 'request' && notif['status'] == 'pending')
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _respondToRequest(notif, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _respondToRequest(notif, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Refuse",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: notifications.length,
        itemBuilder: (context, index) => _buildNotificationCard(notifications[index]),
      ),
    );
  }
}
