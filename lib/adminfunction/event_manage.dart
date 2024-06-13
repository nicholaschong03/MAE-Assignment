import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class EventManagePage extends StatefulWidget {
  const EventManagePage({super.key});

  @override
  _EventManagePageState createState() => _EventManagePageState();
}

class _EventManagePageState extends State<EventManagePage> {
  bool _isAscending = true;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Manage',
          style: GoogleFonts.arvo(fontSize: 24.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter5,color:  Color(0xFFF88232)),
            onPressed: () {
              _showFilterMenu(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('outingGroups').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var events = snapshot.data!.docs;

          if (_selectedDate != null) {
            events = events.where((event) {
              DateTime eventDate = (event['date'] as Timestamp).toDate();
              return eventDate.year == _selectedDate!.year &&
                  eventDate.month == _selectedDate!.month &&
                  eventDate.day == _selectedDate!.day;
            }).toList();
          }

          events.sort((a, b) {
            DateTime dateA = (a['date'] as Timestamp).toDate();
            DateTime dateB = (b['date'] as Timestamp).toDate();
            return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          });

          if (events.isEmpty) {
            return const Center(child: Text('No events available'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              return ListTile(
                title: Text(event['title']),
                subtitle: Text(
                  '${DateFormat('yyyy-MM-dd').format((event['date'] as Timestamp).toDate())} from ${event['startTime']} to ${event['endTime']} \nLocation: ${event['restaurantName']}'
                ),
                trailing: IconButton(
                  icon: const Icon(FeatherIcons.xCircle, color: Color(0xFFF35000)),
                  onPressed: () async {
                    bool confirm = await _showConfirmationDialog(context, 'Are you sure you want to revoke this event?');
                    if (confirm) {
                      try {
                        await FirebaseFirestore.instance.collection('outingGroups').doc(event.id).delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event revoked successfully!')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to revoke event: $e')));
                      }
                    }
                  },
                ),
                onTap: () {
                  _showEventDetailsDialog(context, event);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Sort Order'),
                  trailing: DropdownButton<bool>(
                    value: _isAscending,
                    onChanged: (value) {
                      setState(() {
                        _isAscending = value!;
                      });
                      Navigator.of(context).pop();
                      this.setState(() {});
                    },
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Ascending'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('Descending'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Filter by Date'),
                  trailing: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                        Navigator.of(context).pop();
                        this.setState(() {});
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Clear Filters'),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      Navigator.of(context).pop();
                      this.setState(() {});
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Revoke Event'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showEventDetailsDialog(BuildContext context, DocumentSnapshot event) {
    final String hostUserId = (event['createdByUser'] as DocumentReference).id; // Get the user ID from the DocumentReference
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            event['title'],
            style: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 300, // Fixed width
            height: 400, // Fixed height
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildEventDetail(
                    'Date',
                    '${DateFormat('yyyy-MM-dd').format((event['date'] as Timestamp).toDate())} (${event['day']}) ${event['startTime']} to ${event['endTime']}',
                  ),
                  _buildEventDetail('Venue', event['restaurantName']),
                  _buildEventDetail('Cuisine Type', event['cuisineType']),
                  const SizedBox(height: 8),
                  Text(
                    'Description:',
                    style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['description'],
                    style: GoogleFonts.raleway(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FutureBuilder<String>(
                      future: _getUsernameFromUserId(hostUserId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text(
                            'by: ${snapshot.data ?? 'Unknown'}',
                            style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
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
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _getUsernameFromUserId(String hostUserId) async {
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

  Widget _buildEventDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label: ',
            style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.raleway(),
            ),
          ),
        ],
      ),
    );
  }
}
