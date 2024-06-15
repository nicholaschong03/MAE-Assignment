import 'package:cloud_firestore/cloud_firestore.dart';

class NoteData {
  String noteId;
  String ccId;
  String title;
  String description;
  Timestamp createdAt;

  NoteData({
    required this.noteId,
    required this.ccId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'ccId': ccId,
      'title': title,
      'description': description,
      'createdAt': createdAt,
    };
  }

  factory NoteData.fromMap(Map<String, dynamic> map) {
    return NoteData(
      noteId: map['noteId'],
      ccId: map['ccId'],
      title: map['title'],
      description: map['description'],
      createdAt: map['createdAt'],
    );
  }
}
