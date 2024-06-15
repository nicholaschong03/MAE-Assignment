import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CCProfileScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<DocumentSnapshot> getUserData() async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
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
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData['profileImage']),
                ),
                SizedBox(height: 16.0),
                Text(
                  userData['username'],
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                SizedBox(height: 8.0),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text('Likes'),
                        subtitle: Text('Received likes notifications'),
                        onTap: () {
                          // Navigate to likes notification screen
                        },
                      ),
                      ListTile(
                        title: Text('Comments'),
                        subtitle: Text('Received comments notifications'),
                        onTap: () {
                          // Navigate to comments notification screen
                        },
                      ),
                      ListTile(
                        title: Text('Shares'),
                        subtitle: Text('Received shares notifications'),
                        onTap: () {
                          // Navigate to shares notification screen
                        },
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
