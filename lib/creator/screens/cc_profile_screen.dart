import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../common function/user_services.dart';

class CCProfileScreen extends StatefulWidget {
  @override
  _CCProfileScreenState createState() => _CCProfileScreenState();
}

class _CCProfileScreenState extends State<CCProfileScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<List<String>> _defaultImagesFuture;
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    String userId = UserData.getCurrentUserID();
    _userDataFuture = UserData(userId: userId).getUserData();
    _defaultImagesFuture = UserData(userId: userId).fetchDefaultImages();
  }

  Future<void> _pickImage(ImageSource source) async {
    String userId = UserData.getCurrentUserID();
    File? pickedFile = await UserData(userId: userId).pickImage(source);
    if (pickedFile != null) {
      await UserData(userId: userId).uploadImage(pickedFile);
      setState(() {
        _userDataFuture = UserData(userId: userId).getUserData();
      });
      _showSnackBar('Profile image updated successfully.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showImageOptions(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showImageSourceActionSheet();
                },
                child: Text('Change Image'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Default Images'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDefaultImageOptions();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDefaultImageOptions() async {
    List<String> defaultImages = await _defaultImagesFuture;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Default Image'),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: defaultImages.length,
              itemBuilder: (context, index) {
                String imageUrl = defaultImages[index];
                return GestureDetector(
                  onTap: () {
                    _setImage(imageUrl);
                    Navigator.of(context).pop();
                  },
                  child: Image.network(imageUrl),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _setImage(String imageUrl) async {
    String userId = UserData.getCurrentUserID();
    await UserData(userId: userId).setImage(imageUrl);
    setState(() {
      _userDataFuture = UserData(userId: userId).getUserData();
    });
    _showSnackBar('Profile image updated successfully.');
  }

  Future<void> _updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    await UserData.updateUserProfile(userId, updateData);
    setState(() {
      _userDataFuture = UserData(userId: userId).getUserData();
    });
    _showSnackBar('Profile updated successfully.');
  }

  void _showEditProfileDialog(Map<String, dynamic> userData) {
    String userId = UserData.getCurrentUserID();
    String newName = userData['name'];
    String newUsername = userData['username'];
    String newPhone = userData['phone'];
    String newGender = userData['gender'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: newName),
                  onChanged: (value) {
                    newName = value;
                  },
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: TextEditingController(text: newUsername),
                  onChanged: (value) {
                    newUsername = value;
                  },
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: TextEditingController(text: newPhone),
                  onChanged: (value) {
                    newPhone = value;
                  },
                  decoration: InputDecoration(labelText: 'Phone Number (+60)'),
                ),
                DropdownButtonFormField<String>(
                  value: newGender,
                  items: ['Male', 'Female', 'Not specified'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    newGender = value!;
                  },
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUserProfile(userId, {
                  'name': newName,
                  'username': newUsername,
                  'phone': newPhone,
                  'gender': newGender,
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
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
        title: Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No Data Found'));
          }

          final userData = snapshot.data!;
          String imageUrl = userData['profileImage'] ?? '';

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showImageOptions(imageUrl);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl) as ImageProvider<Object>
                        : AssetImage('assets/images/default_profile.png') as ImageProvider<Object>,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  userData['username'],
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text('Name'),
                        subtitle: Text(userData['name']),
                      ),
                      ListTile(
                        title: Text('Email'),
                        subtitle: Text(userData['email']),
                      ),
                      ListTile(
                        title: Text('Role'),
                        subtitle: Text(userData['role']),
                      ),
                      ListTile(
                        title: Text('Gender'),
                        subtitle: Text(userData['gender']),
                      ),
                      ListTile(
                        title: Text('Phone (+60)'),
                        subtitle: Text(userData['phone']),
                      ),
                      ListTile(
                        title: Text('Joined'),
                        subtitle: Text(userData['signedUpAt'] != null
                            ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(userData['signedUpAt'].toDate())
                            : 'No join date'),
                      ),
                      TextButton(
                        onPressed: () {
                          _showEditProfileDialog(userData);
                        },
                        child: Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
