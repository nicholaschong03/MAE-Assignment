import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_data.dart';

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
}
