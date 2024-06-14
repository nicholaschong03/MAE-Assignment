import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import 'package:jom_eat_project/models/promotion_model.dart';
import 'package:jom_eat_project/models/user_model.dart';
import 'package:jom_eat_project/models/foodie_model.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<OutingGroupModel>> getTodayDiningGroups() async* {
    var outingGroupsSnapshot = _db
        .collection('outingGroups')
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .snapshots();

    await for (var snapshot in outingGroupsSnapshot) {
      try {
        print("Number of documents retrieved: ${snapshot.docs.length}");
        List<OutingGroupModel> outingGroups = await Future.wait(snapshot.docs.map((doc) async {
          var data = doc.data() as Map<String, dynamic>;

          // Ensure 'createdByUser' is extracted as a document reference
          DocumentReference createdByRef = data['createdByUser'] as DocumentReference;
          var createdByUser = await getFoodie(createdByRef.id);

          // Create the outing group model with the user information
          return await OutingGroupModel.fromFirestore(doc, createdByUser, getUser);
        }).toList());

        yield outingGroups;
      } catch (e) {
        print("Error processing snapshot: $e");
        yield [];
      }
    }
  }

  Future<void> addMemberToOutingGroup(String outingId, String userId) async {
    DocumentReference outingGroupRef = _db.collection('outingGroups').doc(outingId);

    try {
      await outingGroupRef.update({
        'members': FieldValue.arrayUnion([userId])
      });
      print("User ID added to members list successfully.");
    } catch (e) {
      print("Error adding user ID to members list: $e");
    }
  }

  Future<FoodieModel> getFoodie(String userId) async {
    try {
      // Fetching foodie data for user
      DocumentSnapshot foodieDoc =
          await _db.collection('foodies').doc(userId).get();
      print('Foodie Document snapshot: ${foodieDoc.data()}');

      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userId).get();
      print('User Document snapshot: ${userDoc.data()}');

      if (foodieDoc.exists && userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        var foodieData = foodieDoc.data() as Map<String, dynamic>;

        // Create FoodieModel
        return FoodieModel.fromFirestore(userData, foodieData, userId);
      } else {
        print('Foodie or User not found');
        throw Exception("Foodie or User not found");
      }
    } catch (e) {
      print("Error getting foodie: $e");
      rethrow;
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        return UserModel.fromFirestore(userDoc);
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      print("Error getting user: $e");
      rethrow;
    }
  }

  Stream<List<OutingGroupModel>> getAllOutingGroups() async* {
    var outingGroupsSnapshot = _db.collection('outingGroups').snapshots();

    await for (var snapshot in outingGroupsSnapshot) {
      List<OutingGroupModel> outingGroups =
          await Future.wait(snapshot.docs.map((doc) async {
        var data = doc.data() as Map<String, dynamic>;

        DocumentReference createdByRef = data['createdByUser'] as DocumentReference;
        // Fetch the user and foodie information
        var createdByUser = await getFoodie(createdByRef.id);

        // Create the outing group model with the user information
        return await OutingGroupModel.fromFirestore(doc, createdByUser, getUser);
      }).toList());

      yield outingGroups;
    }
  }

  Stream<List<PromotionModel>> getPromotions() {
    return _db.collection('promotions').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => PromotionModel.fromFirestore(doc)).toList());
  }

  Future<OutingGroupModel> getOuting(String outingId) async {
    try {
      DocumentSnapshot outingDoc = await _db.collection('outingGroups').doc(outingId).get();
      if (outingDoc.exists) {
        var data = outingDoc.data() as Map<String, dynamic>;

        // Ensure 'createdByUser' is extracted as a document reference
        DocumentReference createdByRef = data['createdByUser'] as DocumentReference;
        var createdByUser = await getFoodie(createdByRef.id);

        // Create the outing group model with the user information
        return await OutingGroupModel.fromFirestore(outingDoc, createdByUser, getUser);
      } else {
        throw Exception("Outing not found");
      }
    } catch (e) {
      print("Error getting outing: $e");
      rethrow;
    }
  }
}
