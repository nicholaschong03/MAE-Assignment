import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationService {
  Future<void> sendNotification(String title, String content, String from, {String? to, String? role}) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'content': content,
      'fromID': from,
      'toID': to,
      'toRole': role,
      'time': FieldValue.serverTimestamp(),
      'read_status': false,
    });
  }
}

class NotificationsPage extends StatelessWidget {
  final String userId;
  final String? role;

  const NotificationsPage({required this.userId, this.role, super.key});

  Future<void> _showNotificationDialog(BuildContext context, DocumentSnapshot notification) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification['title']),
          content: Text(notification['content']),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(notification.id)
                    .update({'read_status': true});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.arvo(fontSize: 24.0, letterSpacing: 0.5),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getNotificationStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              bool isRead = notification['read_status'];
              return ListTile(
                tileColor: isRead ? Colors.white : Colors.orange[100],
                title: Text(notification['title']),
                subtitle: Text(notification['time'] != null
                    ? (notification['time'] as Timestamp).toDate().toString()
                    : ''),
                onTap: () {
                  _showNotificationDialog(context, notification);
                },
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getNotificationStream() {
    final notificationsCollection = FirebaseFirestore.instance.collection('notifications');
    if (role != null) {
      // If role is specified, filter by role
      return notificationsCollection.where('toRole', isEqualTo: role).snapshots();
    } else {
      // Otherwise, filter by userId
      return notificationsCollection.where('toID', isEqualTo: userId).snapshots();
    }
  }
}
