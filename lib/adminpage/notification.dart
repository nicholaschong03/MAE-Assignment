import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<void> _showNotificationDialog(
      BuildContext context, DocumentSnapshot notification) async {
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
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('to',
                isEqualTo: 'admin') // Ensure only admin notifications are shown
            .snapshots(),
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
                subtitle: Text(
                    notification['time'].toDate().toString()), // Add this line
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
}
