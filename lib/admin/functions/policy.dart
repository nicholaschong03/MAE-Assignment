import 'package:cloud_firestore/cloud_firestore.dart';

class PolicyData {
  PolicyData();

  Future<List<Map<String, dynamic>>> getPolicies() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('policies').get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            })
        .toList();
  }

  Future<Map<String, dynamic>> getPolicy(String policyId) async {
    DocumentSnapshot policyData = await FirebaseFirestore.instance
        .collection('policies')
        .doc(policyId)
        .get();
    return policyData.data() as Map<String, dynamic>;
  }

  Future<void> updatePolicy(
      String policyId, Map<String, dynamic> updateData) async {
    try {
      await FirebaseFirestore.instance
          .collection('policies')
          .doc(policyId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update policy: $e');
    }
  }

  Future<void> addPolicy(Map<String, dynamic> policyData) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('policies')
          .add(policyData);
      await FirebaseFirestore.instance
          .collection('policies')
          .doc(docRef.id)
          .update({'id': docRef.id});
    } catch (e) {
      throw Exception('Failed to add policy: $e');
    }
  }
}
