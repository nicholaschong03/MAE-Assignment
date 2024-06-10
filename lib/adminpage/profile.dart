import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Loginpage/login.dart';
import 'package:intl/intl.dart';

class ProfilePanel extends StatefulWidget {
  const ProfilePanel({super.key});

  @override
  _ProfilePanelState createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = getUserData();
  }

  Future<Map<String, dynamic>> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userData.data() as Map<String, dynamic>;
    } else {
      throw Exception("No user logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            var userData = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/images/logo.png'), // Placeholder image
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userData['name'] ?? 'No name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String newName = userData['name'] ?? '';
                              String newUsername = userData['username'] ?? '';
                              String newPhone = userData['phone'] ?? '';
                              return AlertDialog(
                                title: const Text('Edit Profile'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller:
                                          TextEditingController(text: newName),
                                      onChanged: (value) {
                                        newName = value;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Name',
                                      ),
                                    ),
                                    TextField(
                                      controller: TextEditingController(
                                          text: newUsername),
                                      onChanged: (value) {
                                        newUsername = value;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                      ),
                                    ),
                                    TextField(
                                      controller:
                                          TextEditingController(text: newPhone),
                                      onChanged: (value) {
                                        newPhone = value;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number (+60)',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      User? user =
                                          FirebaseAuth.instance.currentUser;
                                      // Perform the update operation here
                                      Map<String, dynamic> updateData = {};
                                      if (newName.isNotEmpty) {
                                        updateData['name'] = newName;
                                      }
                                      if (newUsername.isNotEmpty) {
                                        updateData['username'] = newUsername;
                                      }
                                      if (newPhone.isNotEmpty) {
                                        updateData['phone'] = newPhone;
                                      }
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user!.uid)
                                          .update(updateData)
                                          .then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Profile updated successfully!'),
                                          ),
                                        );
                                        // Refresh the profile panel
                                        setState(() {
                                          _userDataFuture = getUserData();
                                        });
                                        Navigator.of(context).pop();
                                      }).catchError((error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Failed to update profile!'),
                                          ),
                                        );
                                      });
                                    },
                                    child: const Text('Save'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Username: ${userData['username'] ?? 'No username'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${userData['email'] ?? 'No email'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Role: ${userData['role'] ?? 'No role'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phone: ${userData['phone'] ?? 'No phone'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Joined: ${userData['signedUpAt'] != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(userData['signedUpAt'].toDate()) : 'No join date'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Platform Policy',
                      border: OutlineInputBorder(),
                    ),
                    // Add controller and onChanged for handling policy update
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add your logic for updating policy here
                        },
                        child: const Text('Update Policy'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(
                            email: FirebaseAuth.instance.currentUser!.email!,
                          )
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Password reset email sent successfully!'),
                              ),
                            );
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to send password reset email!'),
                              ),
                            );
                          });
                        },
                        child: const Text('Reset Password'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                    'Are you sure you want to logout?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut().then((_) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(),
                                          ),
                                        );
                                      });
                                    },
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('No'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No user data found'));
          }
        },
      ),
    );
  }
}
