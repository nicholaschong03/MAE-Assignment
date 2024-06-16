import 'package:cloud_firestore/cloud_firestore.dart';

class ContentData {
  String contentId;
  String ccId;
  String title;
  String description;
  List<String> mediaUrls;
  DateTime createdAt;
  DateTime scheduledAt;
  List<String> tags;
  int likes;
  List<Map<String, dynamic>> comments;

  ContentData({
    required this.contentId,
    required this.ccId,
    required this.title,
    required this.description,
    required this.mediaUrls,
    required this.createdAt,
    required this.scheduledAt,
    required this.tags,
    required this.likes,
    required this.comments,
  });

  factory ContentData.fromFirestore(Map<String, dynamic> data) {
    return ContentData(
      contentId: data['contentId'] ?? '',
      ccId: data['ccId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'contentId': contentId,
      'ccId': ccId,
      'title': title,
      'description': description,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt,
      'scheduledAt': scheduledAt,
      'tags': tags,
      'likes': likes,
      'comments': comments,
    };
  }
}
