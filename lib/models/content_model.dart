import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String ccId;
  final String description;
  final String title;
  final List<String> mediaUrls;
  final List<String> tags;
  final int likes;
  final Timestamp createdAt;
  final List<Map<String, dynamic>> comments; // Change to List<Map<String, dynamic>>

  ContentModel({
    required this.id,
    required this.ccId,
    required this.description,
    required this.title,
    required this.mediaUrls,
    required this.tags,
    required this.likes,
    required this.createdAt,
    required this.comments,
  });

  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ContentModel(
      id: doc.id,
      ccId: data['ccId'] ?? '',
      description: data['description'] ?? '',
      title: data['title'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []), // Update to parse comments
    );
  }
}
