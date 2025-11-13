import 'package:flutter/material.dart';
import 'database_helper.dart';

class NotificationItem {
  final int id;
  final String senderName;
  final String message;
  final String location;
  final String bloodGroup;
  final String type;
  final DateTime dateTime;

  NotificationItem({
    required this.id,
    required this.senderName,
    required this.message,
    required this.location,
    required this.bloodGroup,
    required this.type,
    required this.dateTime,
  });
}

class NotificationsPage extends StatefulWidget {
  final int receiverId; // id du donneur connecté

  const NotificationsPage({super.key, required this.receiverId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final db = DatabaseHelper.instance;
    final data = await db.getNotifications(widget.receiverId);
    setState(() {
      notifications = data.map((e) {
        return NotificationItem(
          id: e['id'],
          senderName: e['senderName'],
          message: e['message'],
          location: e['location'] ?? '',
          bloodGroup: e['bloodGroup'] ?? '',
          type: e['type'],
          dateTime: DateTime.parse(e['timestamp']),
        );
      }).toList();
    });
  }

  String formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} h ago";
    return "${diff.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("Aucune notification"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                notif.type == "accepted"
                    ? "Demande acceptée"
                    : notif.type == "direct_request"
                    ? "Demande directe"
                    : "Nouvelle demande",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notif.message),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(notif.location, style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text(formatDateTime(notif.dateTime),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.notifications, color: Colors.white),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Notification cliquée: ${notif.senderName}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
