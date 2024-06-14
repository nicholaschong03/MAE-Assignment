import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String id;
  final String title;
  final String description;
  final String restaurantLogo;
  final DateTime validUntil;
  final String restaurantId;
  final String restaurantName;

  PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.restaurantLogo,
    required this.validUntil,
    required this.restaurantId,
    required this.restaurantName,
  });

  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return PromotionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      restaurantLogo: data['restaurantLogo'] ?? '',
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
    );
  }
}
