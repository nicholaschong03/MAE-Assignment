import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_eat_project/models/foodie_model.dart';
import 'package:jom_eat_project/models/user_model.dart';
import 'package:jom_eat_project/services/database_service.dart';

class OutingGroupModel {
  final String id;
  final String title;
  final String description;
  final String cuisineType;
  final DateTime date;
  final String day;
  final String startTime;
  final String endTime;
  final String restaurantId;
  final String restaurantName;
  final FoodieModel createdByUser;
  final List<UserModel> members;
  final int maxMembers;
  final String image;
  final List<String> restaurantPhotos;
  final String location;
  final int membersCount;

  OutingGroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cuisineType,
    required this.date,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.restaurantId,
    required this.restaurantName,
    required this.createdByUser,
    required this.members,
    required this.membersCount,
    required this.maxMembers,
    required this.image,
    required this.location,
    required this.restaurantPhotos,
  });

  static Future<OutingGroupModel> fromFirestore(
      DocumentSnapshot doc, FoodieModel createdByUser, Future<UserModel> Function(String) getUser) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<UserModel> members = await Future.wait(
      (data['members'] ?? []).map<Future<UserModel>>((userId) async => await getUser(userId)),
    );

    return OutingGroupModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      cuisineType: data['cuisineType'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      day: data['day'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      createdByUser: createdByUser,
      members: members,
      maxMembers: data['maxMembers'] ?? 0,
      image: data['image'] ?? '',
      location: data['location'] ?? '',
      membersCount: data['membersCount'] ?? 0,
      restaurantPhotos: List<String>.from(data['restaurantPhotos'] ?? []),
    );
  }
}
