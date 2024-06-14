import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserData {
  final String userId;

  UserData({required this.userId});


  Future<List<String>> fetchDefaultImages() async {
    final ListResult result = await FirebaseStorage.instance.ref().child('default_pictures').listAll();
    final List<String> urls = await Future.wait(result.items.map((Reference ref) => ref.getDownloadURL()).toList());
    return urls;
  }

  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<void> uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child('$userId.jpg');
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'profileImage': downloadUrl});
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> setImage(String url) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({'profileImage': url});
  }

  static Future<void> updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<void> signUpUser({
    required String email,
    required String password,
    required String name,
    required String username,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.sendEmailVerification();
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'role': role,
        'name': name,
        'username': username,
        'id': userCredential.user?.uid,
        'phone': '',
        'signedUpAt': FieldValue.serverTimestamp(),
        'profileImage': '',
        'isSuspended': false,
        'gender': 'Not specified',
      });
    } catch (e) {
      throw Exception("Sign up failed: The email had already been used, If you can't remember the password, kindly reset the password");
    }
  }

  // Get current userID
  static String getCurrentUserID() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
  
  //get user data based on user id
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

}