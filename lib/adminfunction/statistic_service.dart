import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalUsersByDate({DateTime? startDate, DateTime? endDate}) async {
    QuerySnapshot querySnapshot;

    if (startDate != null && endDate != null) {
      querySnapshot = await _firestore.collection('users')
          .where('signedUpAt', isGreaterThanOrEqualTo: startDate)
          .where('signedUpAt', isLessThanOrEqualTo: endDate)
          .get();
    } else {
      querySnapshot = await _firestore.collection('users').get();
    }

    return querySnapshot.docs.length;
  }

  Future<Map<String, int>> getTotalUsersByRole({DateTime? startDate, DateTime? endDate}) async {
    QuerySnapshot querySnapshot;

    if (startDate != null && endDate != null) {
      querySnapshot = await _firestore.collection('users')
          .where('signedUpAt', isGreaterThanOrEqualTo: startDate)
          .where('signedUpAt', isLessThanOrEqualTo: endDate)
          .get();
    } else {
      querySnapshot = await _firestore.collection('users').get();
    }

    Map<String, int> roleCount = {};

    for (var doc in querySnapshot.docs) {
      String role = doc['role'];
      if (roleCount.containsKey(role)) {
        roleCount[role] = roleCount[role]! + 1;
      } else {
        roleCount[role] = 1;
      }
    }

    return roleCount;
  }

  Future<int> getTotalOutingsByDate({DateTime? startDate, DateTime? endDate}) async {
    QuerySnapshot querySnapshot;

    if (startDate != null && endDate != null) {
      querySnapshot = await _firestore.collection('outingGroups')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();
    } else {
      querySnapshot = await _firestore.collection('outingGroups').get();
    }

    return querySnapshot.docs.length;
  }

  Future<int> getTotalUsersByRoleAndCount(String role, {DateTime? startDate, DateTime? endDate}) async {
    QuerySnapshot querySnapshot;

    if (startDate != null && endDate != null) {
      querySnapshot = await _firestore.collection('users')
          .where('role', isEqualTo: role)
          .where('signedUpAt', isGreaterThanOrEqualTo: startDate)
          .where('signedUpAt', isLessThanOrEqualTo: endDate)
          .get();
    } else {
      querySnapshot = await _firestore.collection('users')
          .where('role', isEqualTo: role)
          .get();
    }

    return querySnapshot.docs.length;
  }
}
