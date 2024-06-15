import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jom_eat_project/common%20function/notification.dart';
import 'package:jom_eat_project/common%20function/user_services.dart';
import '../functions/user_manage_functions.dart';

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
  bool _sortAscending = false;
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.arvo(fontSize: 24.0, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 234, 211),
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
                    decoration: InputDecoration(
                      labelText: 'Search by Username',
                      labelStyle: GoogleFonts.roboto(color: const Color(0xFFF88232)),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(45))),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFF88232)),
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
                    showFilterDialog(context, _selectedRole, _selectedStatus, _sortAscending, setState);
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
                        style: GoogleFonts.roboto(
                          color: isSuspended ? Colors.red : Colors.black,
                          fontWeight: isSuspended ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                          'Email: ${user['email']}\nRole: ${getRoleDisplayName(user['role'])}',
                          style: GoogleFonts.roboto(color: Colors.black)),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFFF88232)),
                        onPressed: () {
                          showUserManagementDialog(context, user.id, _notificationService, widget.currentUser);
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
    
    if (_selectedRole != 'All') {
      collectionRef = collectionRef.where('role', isEqualTo: _selectedRole == 'Content Creator' ? 'cc' : 'foodie');
    }

    if (_selectedStatus != 'All') {
      collectionRef = collectionRef.where('isSuspended', isEqualTo: _selectedStatus == 'Suspended');
    }

    collectionRef = collectionRef.orderBy('signedUpAt', descending: !_sortAscending);

    return collectionRef.snapshots();
  }
}
