import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/verification.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _showUserManagementDialog(
      BuildContext context, DocumentSnapshot userData) async {
    TextEditingController nameController =
        TextEditingController(text: userData['name']);
    TextEditingController roleController =
        TextEditingController(text: userData['role']);
    TextEditingController phoneController =
        TextEditingController(text: userData['phone']);
    TextEditingController usernameController =
        TextEditingController(text: userData['username']);

    bool isSuspended = userData['isSuspended'] ?? false;
    bool _isPhoneValid = true;

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
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
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
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone (+60)',
                        errorText: _isPhoneValid ? null : 'Please enter a valid phone number',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isPhoneValid = verifyPhoneNumber(value);
                        });
                      },
                    ),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(isSuspended ? 'Reinstate' : 'Suspend'),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userData.id)
                        .update({
                      'isSuspended': !isSuspended,
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () {
                    if (_isPhoneValid) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(userData.id)
                          .update({
                        'name': nameController.text,
                        'role': roleController.text,
                        'phone': phoneController.text,
                        'username': usernameController.text,
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid phone number.'),
                        ),
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
          'User Management Page',
          style: GoogleFonts.arvo(fontSize: 24.0, letterSpacing: 0.5),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
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
                  .where('role', isNotEqualTo: 'admin') // Ensure only non-admin users are shown
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
                        'https://via.placeholder.com/150';
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
