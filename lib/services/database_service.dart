import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_eat_project/models/content_model.dart';
import 'package:jom_eat_project/models/user_model.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import 'package:jom_eat_project/models/promotion_model.dart';
import 'package:jom_eat_project/models/foodie_model.dart';
import 'package:jom_eat_project/models/restaurant_model.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ContentModel>> getContents() {
    return _db.collection('contents').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList());
  }

   Stream<List<RestaurantModel>> getRestaurants() {
    return _db.collection('restaurants').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList());
  }

  Future<void> updateLikes(String contentId, int newLikes) async {
    try {
      await _db.collection('contents').doc(contentId).update({'likes': newLikes});
    } catch (e) {
      print('Error updating likes: $e');
      rethrow;
    }
  }

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
          if (createdByRef != null && createdByRef.path.isNotEmpty) {
            var createdByUser = await getFoodie(createdByRef.id);

            // Create the outing group model with the user information
            return await OutingGroupModel.fromFirestore(doc, createdByUser, getUser, getRestaurant);
          } else {
            throw Exception("Invalid createdByUser reference");
          }
        }).toList());

        yield outingGroups;
      } catch (e) {
        print("Error processing snapshot: $e");
        yield [];
      }
    }
  }

  Future<void> joinOuting(String outingId, String userId) async {
    try {
      DocumentReference outingGroupRef = _db.collection('outingGroups').doc(outingId);
      DocumentReference foodieRef = _db.collection('foodies').doc(userId);

      // Update the outing group
      await outingGroupRef.update({
        'members': FieldValue.arrayUnion([userId])
      });

      // Update the foodie's outingParticipationPoint
      await foodieRef.update({'outingParticipationPoint': FieldValue.increment(10)});

      print("User joined the outing successfully.");
    } catch (e) {
      print("Error joining the outing: $e");
      rethrow;
    }
  }

  Future<void> cancelOuting(String outingId, String userId) async {
    try {
      DocumentReference outingGroupRef = _db.collection('outingGroups').doc(outingId);
      DocumentReference foodieRef = _db.collection('foodies').doc(userId);

      // Update the outing group
      await outingGroupRef.update({
        'members': FieldValue.arrayRemove([userId])
      });

      // Update the foodie's outingParticipationPoint
      await foodieRef.update({'outingParticipationPoint': FieldValue.increment(-10)});

      print("User cancelled the outing successfully.");
    } catch (e) {
      print("Error cancelling the outing: $e");
      rethrow;
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
      if (userId.isEmpty) throw Exception("Invalid userId");

      // Fetching foodie data for user
      DocumentSnapshot foodieDoc = await _db.collection('foodies').doc(userId).get();
      print('Foodie Document snapshot: ${foodieDoc.data()}');

      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
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
      if (userId.isEmpty) throw Exception("Invalid userId");

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
      List<OutingGroupModel> outingGroups = await Future.wait(snapshot.docs.map((doc) async {
        var data = doc.data() as Map<String, dynamic>;

        DocumentReference createdByRef = data['createdByUser'] as DocumentReference;
        if (createdByRef != null && createdByRef.path.isNotEmpty) {
          var createdByUser = await getFoodie(createdByRef.id);

          // Create the outing group model with the user information
          return await OutingGroupModel.fromFirestore(doc, createdByUser, getUser, getRestaurant);
        } else {
          throw Exception("Invalid createdByUser reference");
        }
      }).toList());

      yield outingGroups;
    }
  }

  Stream<List<PromotionModel>> getPromotions() {
    return _db.collection('promotions').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => PromotionModel.fromFirestore(doc)).toList());
  }

  Future<RestaurantModel> getRestaurant(String restaurantId) async {
    DocumentSnapshot doc = await _db.collection('restaurants').doc(restaurantId).get();
    if (doc.exists) {
      return RestaurantModel.fromFirestore(doc);
    } else {
      throw Exception("Restaurant not found");
    }
  }

  Future<OutingGroupModel> getOuting(String outingId) async {
    DocumentSnapshot doc = await _db.collection('outingGroups').doc(outingId).get();
    if (doc.exists) {
      FoodieModel createdByUser = await getFoodie((doc['createdByUser'] as DocumentReference).id);
      return await OutingGroupModel.fromFirestore(
        doc,
        createdByUser,
        getUser,
        getRestaurant,
      );
    } else {
      throw Exception("Outing not found");
    }
  }
}
