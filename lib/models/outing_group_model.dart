import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_eat_project/models/foodie_model.dart';
import 'package:jom_eat_project/models/user_model.dart';
import 'package:jom_eat_project/models/restaurant_model.dart';

class OutingGroupModel {
  final String id;
  final String title;
  final String description;
  final String cuisineType;
  final DateTime date;
  final String day;
  final String startTime;
  final String endTime;
  final FoodieModel createdByUser;
  final List<UserModel> members;
  final int maxMembers;
  final String image;
  final RestaurantModel restaurant;
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
    required this.createdByUser,
    required this.members,
    required this.membersCount,
    required this.maxMembers,
    required this.image,
    required this.restaurant,
  });

  static Future<OutingGroupModel> fromFirestore(
    DocumentSnapshot doc,
    FoodieModel createdByUser,
    Future<UserModel> Function(String) getUser,
    Future<RestaurantModel> Function(String) getRestaurant,
  ) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Ensure 'members' is a non-empty list of valid user IDs
    List<UserModel> members = [];
    if (data['members'] != null && data['members'].isNotEmpty) {
      members = await Future.wait(
        (data['members'] as List<dynamic>).map<Future<UserModel>>((userId) async {
          if (userId != null && userId.isNotEmpty) {
            return await getUser(userId);
          } else {
            throw Exception("Invalid userId in members list");
          }
        }),
      );
    }

    // Ensure 'restaurantId' is a valid document reference
    DocumentReference restaurantRef = data['restaurantId'] as DocumentReference;
    RestaurantModel restaurant = await getRestaurant(restaurantRef.id);

    return OutingGroupModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      cuisineType: data['cuisineType'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      day: data['day'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      createdByUser: createdByUser,
      members: members,
      maxMembers: data['maxMembers'] ?? 0,
      image: data['image'] ?? '',
      restaurant: restaurant,
      membersCount: data['membersCount'] ?? 0,
    );
  }

  bool isUserMember(String userId) {
    return members.any((member) => member.id == userId);
  }
}
