import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String username;
  final String role;
  final DateTime signedUpAt;
  final String profileImage;

  UserModel(
      {required this.id,
      required this.email,
      required this.name,
      required this.username,
      required this.role,
      required this.signedUpAt,
      required this.profileImage});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    print('UserModel fromFirestore data: $data'); // Debug statement
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      signedUpAt: (data['signedUpAt'] as Timestamp).toDate(),
      profileImage: data['profileImage'] ?? '',
    );
  }
}
