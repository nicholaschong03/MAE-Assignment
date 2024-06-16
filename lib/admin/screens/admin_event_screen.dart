import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../functions/event_manage_functions.dart'; // Import the new file

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
          'Event Management',
          style: GoogleFonts.arvo(fontSize: 24.0, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 234, 211),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter5, color: Color(0xFFF88232)),
            onPressed: () {
              _showFilterMenu(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getOutingGroupsStream(), // Use the new function here
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
              return FutureBuilder<Map<String, String>>(
                future: getRestaurantDataFromId(event['restaurantId']),
                builder: (context, restaurantSnapshot) {
                  if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (restaurantSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading restaurant info', style: GoogleFonts.anekDevanagari(fontSize: 18, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${DateFormat('yyyy-MM-dd').format((event['date'] as Timestamp).toDate())} from ${event['startTime']} to ${event['endTime']}',
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                    );
                  } else {
                    var restaurantData = restaurantSnapshot.data!;
                    return ListTile(
                      leading: restaurantData['logo'] != null
                        ? Image.network(restaurantData['logo']!, width: 50, height: 50, fit: BoxFit.cover)
                        : const CircleAvatar(
                          backgroundImage: NetworkImage('https://via.placeholder.com/200'),
                        ),
                      title: Text(
                        event['title'],
                        style: GoogleFonts.anekDevanagari(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${DateFormat('yyyy-MM-dd').format((event['date'] as Timestamp).toDate())} from ${event['startTime']} to ${event['endTime']} \nLocation: ${restaurantData['name']}',
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(FeatherIcons.xCircle, color: Color(0xFFF35000)),
                        onPressed: () async {
                          bool confirm = await showConfirmationDialog(context, 'Are you sure you want to revoke this event?');
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
                        showEventDetailsDialog(context, event);
                      },
                    );
                  }
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
                  title: const Text('Sort Order', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  title: const Text('Filter by Date', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  title: const Text('Clear Filters', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
