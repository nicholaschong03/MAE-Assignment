import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Function to get restaurant name and logo from ID
Future<Map<String, String>> getRestaurantDataFromId(DocumentReference restaurantRef) async {
  DocumentSnapshot restaurantSnapshot = await restaurantRef.get();
  if (restaurantSnapshot.exists && restaurantSnapshot.data() != null) {
    var data = restaurantSnapshot.data() as Map<String, dynamic>;
    if (data.containsKey('name') && data.containsKey('logo')) {
      return {'name': data['name'], 'logo': data['logo']};
    } else {
      throw Exception('name or logo field does not exist in the restaurants document');
    }
  } else {
    throw Exception('restaurants document does not exist');
  }
}

// Function to get username from user ID
Future<String> getUsernameFromUserId(String hostUserId) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(hostUserId).get();
  if (userSnapshot.exists && userSnapshot.data() != null) {
    var data = userSnapshot.data() as Map<String, dynamic>;
    if (data.containsKey('username')) {
      return data['username'];
    } else {
      throw Exception('Username field does not exist in the user document');
    }
  } else {
    throw Exception('User document does not exist');
  }
}

// Function to show confirmation dialog
Future<bool> showConfirmationDialog(BuildContext context, String message) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Revoke Event', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFF88232))),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Confirm', style: TextStyle(color: Color(0xFFF88232))),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;
}

// Function to build event detail
Widget buildEventDetail(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label: ',
          style: GoogleFonts.anekDevanagari(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.anekDevanagari(),
          ),
        ),
      ],
    ),
  );
}

// Function to show event details dialog
void showEventDetailsDialog(BuildContext context, DocumentSnapshot event) {
  final String hostUserId = (event['createdByUser'] as DocumentReference).id;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          event['title'],
          style: GoogleFonts.anekDevanagari(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Container(
          width: 300,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildEventDetail(
                  'Date',
                  '${DateFormat('yyyy-MM-dd').format((event['date'] as Timestamp).toDate())} (${event['day']}) ${event['startTime']} to ${event['endTime']}',
                ),
                FutureBuilder<Map<String, String>>(
                  future: getRestaurantDataFromId(event['restaurantId']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var restaurantData = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildEventDetail('Venue', restaurantData['name'] ?? 'Unknown'),
                          if (restaurantData['logo'] != null)
                            Image.network(
                              restaurantData['logo']!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                        ],
                      );
                    }
                  },
                ),
                buildEventDetail('Cuisine Type', event['cuisineType']),
                const SizedBox(height: 8),
                Text(
                  'Description:',
                  style: GoogleFonts.anekDevanagari(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  event['description'],
                  style: GoogleFonts.anekDevanagari(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<String>(
                    future: getUsernameFromUserId(hostUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          'by: ${snapshot.data ?? 'Unknown'}',
                          style: GoogleFonts.anekDevanagari(fontWeight: FontWeight.bold),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close', style: TextStyle(color: Color(0xFFF88232))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
