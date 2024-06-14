import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String location;
  final String logo;
  final List<String> photos;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.location,
    required this.logo,
    required this.photos,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      logo: data['logo'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
    );
  }
}
