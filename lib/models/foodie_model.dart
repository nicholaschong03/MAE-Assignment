import 'package:cloud_firestore/cloud_firestore.dart';
import './user_model.dart';

class FoodieModel extends UserModel {
  final int engagementScore;
  final int points;
  final String userId;
  final String membershipStatus;
  final String badgeImage;
  final String badgeTitle;
  final int level;
  final int badgeCount;
  final int outingParticipationPoint;

  FoodieModel(
      {required String id,
      required String email,
      required String name,
      required String username,
      required String role,
      required DateTime signedUpAt,
      required String profileImage,
      required this.engagementScore,
      required this.points,
      required this.userId,
      required this.membershipStatus,
      required this.badgeImage,
      required this.badgeTitle,
      required this.level,
      required this.badgeCount,
      required this.outingParticipationPoint})
      : super(
          id: id,
          email: email,
          name: name,
          username: username,
          role: role,
          signedUpAt: signedUpAt,
          profileImage: profileImage,
        );

  // Factory constructor to create FoodieModel from Firestore data
  factory FoodieModel.fromFirestore(Map<String, dynamic> userData,
      Map<String, dynamic> foodieData, String docId) {
    // print(
    //     'Converting combined data to FoodieModel: $userData and $foodieData'); // Debug statement

    return FoodieModel(
      id: docId,
      email: userData['email'] ?? '',
      name: userData['name'] ?? '',
      username: userData['username'] ?? '',
      role: userData['role'] ?? '',
      signedUpAt: userData['signedUpAt'] != null
          ? (userData['signedUpAt'] as Timestamp).toDate()
          : DateTime.now(),
      profileImage: userData['profileImage'] ?? '',
      engagementScore: foodieData['engagementScore'] ?? 0,
      points: foodieData['points'] ?? 0,
      membershipStatus: foodieData['membershipStatus'] ?? '',
      userId: foodieData['userId'] ?? '',
      badgeImage: foodieData['badgeImage'] ?? '',
      badgeTitle: foodieData['badgeTitle'] ?? '',
      level: foodieData['level'] ?? 0,
      badgeCount: foodieData['badgeCount'] ?? 0,
      outingParticipationPoint: foodieData['outingParticipationPoint'] ?? 0,
    );
  }
}
