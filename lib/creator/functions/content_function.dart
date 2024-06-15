import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_data.dart';
import 'package:jom_eat_project/common function/user_services.dart';


class ContentFunction {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  FirebaseFirestore get firestore => _firestore;

  Future<void> createContent(ContentData content) async {
    await _firestore.collection('contents').doc(content.contentId).set(content.toFirestore());
  }

  Future<void> updateContent(ContentData content) async {
    await _firestore.collection('contents').doc(content.contentId).update(content.toFirestore());
  }

  Future<void> deleteContent(String contentId) async {
    await _firestore.collection('contents').doc(contentId).delete();
  }

  Future<ContentData?> getContent(String contentId) async {
    DocumentSnapshot doc = await _firestore.collection('contents').doc(contentId).get();
    if (doc.exists) {
      return ContentData.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<ContentData>> getContentsByCreator(String ccId) {
    return _firestore.collection('contents')
      .where('ccId', isEqualTo: ccId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => ContentData.fromFirestore(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> likeContent(String contentId) async {
    DocumentReference contentRef = _firestore.collection('contents').doc(contentId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(contentRef);
      if (!snapshot.exists) {
        throw Exception("Content does not exist!");
      }
      int newLikes = (snapshot.data() as Map<String, dynamic>)['likes'] + 1;
      transaction.update(contentRef, {'likes': newLikes});
    });
  }

  Future<void> commentOnContent(String contentId, String userId, String comment) async {
    DocumentReference contentRef = _firestore.collection('contents').doc(contentId);
    final userData = await UserData(userId: userId).getUserData();
    final username = userData['username'];

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(contentRef);
      if (!snapshot.exists) {
        throw Exception("Content does not exist!");
      }
      List<dynamic> comments = (snapshot.data() as Map<String, dynamic>)['comments'];
      comments.add({
        'user': username,
        'comment': comment,
        'createdAt': Timestamp.now(),
      });
      transaction.update(contentRef, {'comments': comments});
    });
  }
}
