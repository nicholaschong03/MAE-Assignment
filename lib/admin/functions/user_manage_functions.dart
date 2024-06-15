import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/common%20function/notification.dart';
import 'package:jom_eat_project/common%20function/user_services.dart';

// Function to show user management dialog
Future<void> showUserManagementDialog(BuildContext context, String userId, NotificationService notificationService, String currentUser) async {
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
            title: Text(
              'Edit: ${userDoc['name']}',
              style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.bold),
            ),
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
                      await notificationService.sendNotification(
                        'Account Reinstated',
                        'Your account has been reinstated.',
                        currentUser,
                        to: userId,
                        role: userDoc['role'],
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

// Function to get role display name
String getRoleDisplayName(String role) {
  switch (role) {
    case 'cc':
      return 'Content Creator';
    case 'foodie':
      return 'Foodie';
    default:
      return role;
  }
}

// Function to show filter dialog
Future<void> showFilterDialog(BuildContext context, String selectedRole, String selectedStatus, bool sortAscending, Function setState) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Filter Users', style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'User Role',
                      labelStyle: GoogleFonts.roboto(color: const Color(0xFFF88232)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Content Creator', child: Text('Content Creator')),
                      DropdownMenuItem(value: 'Foodie', child: Text('Foodie')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Account Status',
                      labelStyle: GoogleFonts.roboto(color: const Color(0xFFF88232)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  DropdownButtonFormField<bool>(
                    value: sortAscending,
                    decoration: InputDecoration(
                      labelText: 'Signup Date',
                      labelStyle: GoogleFonts.roboto(color: const Color(0xFFF88232)),
                    ),
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Descending')),
                      DropdownMenuItem(value: true, child: Text('Ascending')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortAscending = value!;
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
                    selectedRole = 'All';
                    selectedStatus = 'All';
                    sortAscending = false;
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
    },
  );
}
