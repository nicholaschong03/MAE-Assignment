import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_data.dart';

class NoteFunction {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  FirebaseFirestore get firestore => _firestore;

  Future<void> createNote(NoteData note) async {
    await _firestore.collection('notes').doc(note.noteId).set(note.toFirestore());
  }

  Future<void> updateNote(NoteData note) async {
    await _firestore.collection('notes').doc(note.noteId).update(note.toFirestore());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  Future<NoteData?> getNote(String noteId) async {
    DocumentSnapshot doc = await _firestore.collection('notes').doc(noteId).get();
    if (doc.exists) {
      return NoteData.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<NoteData>> getNotesByCreator(String ccId) {
    return _firestore.collection('notes')
      .where('ccId', isEqualTo: ccId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => NoteData.fromFirestore(doc.data() as Map<String, dynamic>)).toList());
  }
}
