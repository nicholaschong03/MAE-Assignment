import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jom_eat_project/common%20function/notification.dart';
import 'package:jom_eat_project/common%20function/user_services.dart';

class UserManagementPage extends StatefulWidget {
  late final String currentUser = UserData.getCurrentUserID();
  UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All';
  String _selectedStatus = 'All';
  bool _sortAscending = false; // false for descending, true for ascending
  final NotificationService _notificationService = NotificationService(); // Instantiate NotificationService

  Future<void> _showUserManagementDialog(BuildContext context, String userId) async {
    UserData userData = UserData(userId: userId);
    Map<String, dynamic> userDoc = await userData.getUserData();

    TextEditingController roleController = TextEditingController(text: userDoc['role']);
    bool isSuspended = userDoc['isSuspended'] ?? false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit: ${userDoc['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: userDoc['role'],
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
                          .doc(userId)
                          .update({
                        'isSuspended': !isSuspended,
                      });
                      if (!isSuspended) {
                        // Send notification if the user is being reinstated
                        await _notificationService.sendNotification(
                          'Account Reinstated',
                          'Your account has been reinstated.',
                          widget.currentUser,
                          to: userId,
                          role: userDoc['role'], // Send to the user's role
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
                          .doc(userId)
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
            child: Row(
              children: [
                Expanded(
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
                IconButton(
                  icon: const Icon(Iconsax.filter5, color: Color(0xFFF88232)),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredUsersStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var userData = snapshot.data!.docs;
                var filteredUsers = userData.where((user) {
                  var username = user['username']?.toString().toLowerCase() ?? '';
                  return username.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var user = filteredUsers[index];
                    var profileImageUrl = user['profileImage'] ?? 'https://via.placeholder.com/200';
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
                          _showUserManagementDialog(context, user.id);
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

  Stream<QuerySnapshot> _getFilteredUsersStream() {
    Query<Map<String, dynamic>> collectionRef = FirebaseFirestore.instance.collection('users').where('role', whereIn: ['cc', 'foodie']);
    
    // Apply role filter
    if (_selectedRole != 'All') {
      collectionRef = collectionRef.where('role', isEqualTo: _selectedRole == 'Content Creator' ? 'cc' : 'foodie');
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      collectionRef = collectionRef.where('isSuspended', isEqualTo: _selectedStatus == 'Suspended');
    }

    // Sort by signup date
    collectionRef = collectionRef.orderBy('signedUpAt', descending: !_sortAscending);

    return collectionRef.snapshots();
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Users'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'User Role'),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Content Creator', child: Text('Content Creator')),
                    DropdownMenuItem(value: 'Foodie', child: Text('Foodie')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Account Status'),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                DropdownButtonFormField<bool>(
                  value: _sortAscending,
                  decoration: const InputDecoration(labelText: 'Signup Date'),
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Descending')),
                    DropdownMenuItem(value: true, child: Text('Ascending')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortAscending = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                setState(() {
                  _selectedRole = 'All';
                  _selectedStatus = 'All';
                  _sortAscending = false;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
