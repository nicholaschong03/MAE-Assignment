import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchFeedbackTitles() async {
    QuerySnapshot snapshot = await _firestore.collection('feedback').get();
    List<String> titles = snapshot.docs.map((doc) => doc['title'] as String).toSet().toList();
    return titles;
  }

  Stream<QuerySnapshot> getFeedbackStream(DateTime? selectedDate, String? selectedTitle) {
    Query query = _firestore.collection('feedback');

    if (selectedDate != null) {
      DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      query = query.where('createDate', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay);
    }

    if (selectedTitle != null) {
      query = query.where('title', isEqualTo: selectedTitle);
    }

    query = query.orderBy('createDate', descending: true);

    return query.snapshots();
  }

  Future<void> addFeedback(String feedback, String fromID, String title) async {
    await _firestore.collection('feedback').add({
      'createDate': FieldValue.serverTimestamp(),
      'feedback': feedback,
      'fromID': fromID,
      'title': title,
    });
  }
}
