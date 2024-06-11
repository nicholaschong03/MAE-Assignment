import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/notification.dart';

class UserManagementPage extends StatefulWidget {
  final String userID;

  const UserManagementPage({super.key, required this.userID});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final NotificationService _notificationService = NotificationService(); // Instantiate NotificationService

  Future<void> _showUserManagementDialog(
      BuildContext context, DocumentSnapshot userData) async {
    TextEditingController roleController =
        TextEditingController(text: userData['role']);

    bool isSuspended = userData['isSuspended'] ?? false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit: ${userData['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: userData['role'],
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'cc',
                          child: Text('Content Creator'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'foodie',
                          child: Text('Foodie'),
                        ),
                      ],
                      onChanged: (value) {
                        roleController.text = value!;
                      },
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(isSuspended ? 'Reinstate' : 'Suspend'),
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userData.id)
                          .update({
                        'isSuspended': !isSuspended,
                      });
                      if (isSuspended) {
                        // Send notification if the user is being reinstated
                        await _notificationService.sendNotification(
                          'Account Reinstated',
                          'Your account has been reinstated.',
                          widget.userID,
                          to: userData.id,
                          role: userData['role'], // Send to the user's role
                        );
                      }
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update status: $e')),
                      );
                    }
                  },
                ),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userData.id)
                          .update({
                        'role': roleController.text,
                      });
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update role: $e')),
                      );
                    }
                  },
                ),
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'cc':
        return 'Content Creator';
      case 'foodie':
        return 'Foodie';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Manage',
          style: GoogleFonts.arvo(fontSize: 24.0),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Username',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(45))),
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role',
                      isNotEqualTo:
                          'admin') // Ensure only non-admin users are shown
                  .orderBy('signedUpAt', descending: true) // Order by signup date
                  .orderBy('role')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var userData = snapshot.data!.docs;
                var filteredUsers = userData.where((user) {
                  var username =
                      user['username']?.toString().toLowerCase() ?? '';
                  return username.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var user = filteredUsers[index];
                    var profileImageUrl = user['profileImage'] ??
                        'https://via.placeholder.com/200';
                    var isSuspended = user['isSuspended'] ?? false;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(profileImageUrl),
                      ),
                      title: Text(
                        user['username'],
                        style: TextStyle(
                          color: isSuspended ? Colors.red : Colors.black,
                          fontWeight: isSuspended ? FontWeight.bold : null,
                        ),
                      ),
                      subtitle: Text(
                          'Email: ${user['email']}\nRole: ${_getRoleDisplayName(user['role'])}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          _showUserManagementDialog(context, user);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
