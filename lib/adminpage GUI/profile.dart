import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Loginpage/login.dart';
import 'package:intl/intl.dart';
import 'package:jom_eat_project/verification.dart';

class ProfilePanel extends StatefulWidget {
  const ProfilePanel({super.key});

  @override
  _ProfilePanelState createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  late Future<Map<String, dynamic>> _userDataFuture;
  File? _image;

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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await storageRef.putFile(_image!);

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImage': downloadUrl});

      setState(() {
        _userDataFuture = getUserData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
            var profileImageUrl =
                userData['profileImage'] ?? 'https://via.placeholder.com/150';
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl.startsWith('http')
                        ? NetworkImage(profileImageUrl)
                        : AssetImage(profileImageUrl) as ImageProvider,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      _showImageSourceActionSheet(context);
                    },
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
                                      if (verifyPhoneNumber(newPhone)) {
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
                                        updateData['phone'] = newPhone;
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
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        }).catchError((error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Failed to update profile!'),
                                            ),
                                          );
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please enter a valid phone number.'),
                                          ),
                                        );
                                      }
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
                          style: TextStyle(color: Color(0xFFF88232)),
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
                    'Phone(+60): ${userData['phone'] ?? 'No phone'}',
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
