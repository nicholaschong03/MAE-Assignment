import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_eat_project/common%20function/notification.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Content>> getContents() {
    return _firestore.collection('contents').snapshots().asyncMap((snapshot) async {
      List<Content> contents = [];
      for (var doc in snapshot.docs) {
        var content = Content.fromMap(doc.data(), doc.id);
        // Fetch user details
        var userDoc = await _firestore.collection('users').doc(content.userId).get();
        if (userDoc.exists) {
          content.username = userDoc.data()?['username'] ?? '';
          content.profilePictureUrl = userDoc.data()?['profileImage'] ?? '';
        }
        contents.add(content);
      }
      return contents;
    });
  }

  Future<void> deleteContent(String contentId) async {
    // Fetch the content details before deleting
    var contentDoc = await _firestore.collection('contents').doc(contentId).get();
    if (contentDoc.exists) {
      var content = Content.fromMap(contentDoc.data()!, contentId);

      // Delete the content
      await _firestore.collection('contents').doc(contentId).delete();

      // Send notification to the user
      final NotificationService notificationService = NotificationService();
      await notificationService.sendNotification(
        'Post Deleted',
        'Your post titled "${content.title}" has been deleted by the admin.',
        'admin', // assuming 'admin' as the sender
        to: content.userId, // sending to the user
      );
    }
  }
}

class Content {
  final String id;
  final String userId;
  String username;
  String profilePictureUrl;
  final String description;
  final List<String> mediaUrls;
  final int likes;
  final List<Comment> comments;
  final DateTime createdAt;
  final List<String> tags;
  final String title;

  Content({
    required this.id,
    required this.userId,
    this.username = '',
    this.profilePictureUrl = '',
    required this.description,
    required this.mediaUrls,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.tags,
    required this.title,
  });

  factory Content.fromMap(Map<String, dynamic> data, String id) {
    return Content(
      id: id,
      userId: data['ccId'] ?? '',
      description: data['description'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      likes: data['likes'] ?? 0,
      comments: (data['comments'] as List? ?? []).map((c) => Comment.fromMap(c)).toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      title: data['title'] ?? '',
    );
  }
}

class Comment {
  final String user;
  final String comment;

  Comment({
    required this.user,
    required this.comment,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      user: data['user'] ?? '',
      comment: data['comment'] ?? '',
    );
  }
}
