import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../adminpage GUI/updatepolicy.dart';
import '../Loginpage/login.dart';
import '../common function/verification.dart';
import '../common function/user_services.dart';

class ProfilePanel extends StatefulWidget {
  late final String currentUser = UserData.getCurrentUserID();
  ProfilePanel({super.key});

  @override
  _ProfilePanelState createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late final UserData userData;
  List<String> _defaultImageUrls = [];
  
  @override
  void initState() {
    super.initState();
    userData = UserData(userId: widget.currentUser);
    _userDataFuture = userData.getUserData();
    _fetchDefaultImages();
  }

  Future<void> _fetchDefaultImages() async {
    final urls = await userData.fetchDefaultImages();
    setState(() {
      _defaultImageUrls = urls;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await userData.pickImage(source);

    if (image != null) {
      await userData.uploadImage(image);
      setState(() {
        _userDataFuture = userData.getUserData();
      });

      _showSnackBar('Profile image updated successfully!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showImageOptions(BuildContext context, String profileImageUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Preview'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showImagePreview(context, profileImageUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select New'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showImageSourceActionSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePreview(BuildContext context, String profileImageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.network(profileImageUrl),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
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
                title: const Text('Select from Device'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeviceOptions(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Select Default'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDefaultImageOptions(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeviceOptions(BuildContext context) {
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

  void _showDefaultImageOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Default Image'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10.0,
              children: _defaultImageUrls.map((url) {
                return GestureDetector(
                  onTap: () {
                    _setImage(url);
                    Navigator.of(context).pop();
                  },
                  child: Image.network(
                    url,
                    width: 50,
                    height: 50,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setImage(String url) async {
    await userData.setImage(url);
    setState(() {
      _userDataFuture = userData.getUserData();
    });
    _showSnackBar('Profile image updated to default image.');
  }

  Future<void> _updateUserProfile(Map<String, dynamic> updateData) async {
    try {
      await UserData.updateUserProfile(widget.currentUser , updateData);
      setState(() {
        _userDataFuture = userData.getUserData();
      });
      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      _showSnackBar('Failed to update profile: $e');
    }
  }

  void _showEditProfileDialog(Map<String, dynamic> userData) {
    String newName = userData['name'] ?? '';
    String newUsername = userData['username'] ?? '';
    String newPhone = userData['phone'] ?? '';
    String newGender = userData['gender'] ?? 'Not specified';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Container(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
          TextField(
            controller: TextEditingController(text: newName),
            onChanged: (value) {
              newName = value;
            },
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: TextEditingController(text: newUsername),
            onChanged: (value) {
              newUsername = value;
            },
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
          ),
          TextField(
            controller: TextEditingController(text: newPhone),
            onChanged: (value) {
              newPhone = value;
            },
            decoration: const InputDecoration(
              labelText: 'Phone Number (+60)',
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: newGender,
            onChanged: (String? newValue) {
              newGender = newValue!;
            },
            items: <String>['Not specified', 'Male', 'Female']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Gender',
            ),
          ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
          if (verifyPhoneNumber(newPhone)) {
            Map<String, dynamic> updateData = {
              'name': newName,
              'username': newUsername,
              'phone': newPhone,
              'gender': newGender,
            };
            _updateUserProfile(updateData);
            Navigator.of(context).pop();
          } else {
            _showSnackBar('Please enter a valid phone number.');
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
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showImageOptions(context, profileImageUrl);
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImageUrl.startsWith('http')
                              ? NetworkImage(profileImageUrl)
                              : AssetImage(profileImageUrl) as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userData['username'] ?? 'No username',
                              style: GoogleFonts.georama(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _showEditProfileDialog(userData);
                              },
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Color(0xFFF88232)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileDetail('Name', userData['name'] ?? 'No name'),
                        _buildProfileDetail('Email', userData['email'] ?? 'No email'),
                        _buildProfileDetail('Role', userData['role'] ?? 'No role'),
                        _buildProfileDetail('Gender', userData['gender'] ?? 'Not specified'),
                        _buildProfileDetail('Phone(+60)', userData['phone'] ?? 'No phone'),
                        _buildProfileDetail(
                          'Joined',
                          userData['signedUpAt'] != null
                              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(userData['signedUpAt'].toDate())
                              : 'No join date',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdatePolicyPage(userId: widget.currentUser),
                                  ),
                                );
                              },
                              child: Text(
                                'Platform Policy',
                                style: GoogleFonts.georama(
                                    color: const Color(0xFFF88232),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                  _showSnackBar('Password reset email sent successfully!');
                                }).catchError((error) {
                                  _showSnackBar('Failed to send password reset email!');
                                });
                              },
                              child: Text(
                                'Reset Password',
                                style: GoogleFonts.georama(
                                    color: const Color(0xFFF88232),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text('Are you sure you want to logout?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            FirebaseAuth.instance.signOut().then((_) {
                                              Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) => const LoginPage(),
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
                              child: Text(
                                'Logout',
                                style: GoogleFonts.georama(
                                    color: const Color(0xFFF88232),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
