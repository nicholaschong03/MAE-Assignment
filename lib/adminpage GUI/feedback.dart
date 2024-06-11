import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FeedbackPanel extends StatefulWidget {
  const FeedbackPanel({super.key});

  @override
  _FeedbackPanelState createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends State<FeedbackPanel> {
  DateTime? _selectedDate;
  String? _selectedTitle;
  List<String> _feedbackTitles = [];

  @override
  void initState() {
    super.initState();
    _fetchFeedbackTitles();
  }

  void _fetchFeedbackTitles() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('feedback').get();
    List<String> titles =
        snapshot.docs.map((doc) => doc['title'] as String).toSet().toList();
    setState(() {
      _feedbackTitles = titles;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Apply Filters',
            style: GoogleFonts.raleway(fontSize: 20),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width *
                0.8, // Set a fixed width for the dialog
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Title',
                      style: GoogleFonts.raleway(fontSize: 18),
                    ),
                    trailing: DropdownButton<String>(
                      value: _selectedTitle,
                      hint: Text(
                        'Select Title',
                        style: GoogleFonts.raleway(fontSize: 15),
                      ),
                      items: _feedbackTitles.map((String title) {
                        return DropdownMenuItem<String>(
                          value: title,
                          child: Text(title),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedTitle = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Date',
                      style: GoogleFonts.raleway(fontSize: 18),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
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
              child: const Text('Clear'),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                  _selectedTitle = null;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFeedbackStream() {
    Query query = FirebaseFirestore.instance.collection('feedback');

    if (_selectedDate != null) {
      DateTime startOfDay = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      DateTime endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, 23, 59, 59);
      query = query.where('createDate',
          isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay);
    }

    if (_selectedTitle != null) {
      query = query.where('title', isEqualTo: _selectedTitle);
    }

    query = query.orderBy('createDate', descending: true);

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                _selectedTitle != null
                    ? 'Filtered by: $_selectedTitle'
                    : _selectedDate != null
                        ? 'Filtered by Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                        : 'All Feedbacks',
                style: GoogleFonts.dosis(
                    color: const Color(0xFFF88232),
                    fontSize: 21.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFeedbackStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var feedbacks = snapshot.data!.docs;
                if (feedbacks.isEmpty) {
                  return const Center(child: Text('No feedbacks available'));
                }
                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    var feedback = feedbacks[index];
                    return ListTile(
                      title: Text(feedback['feedback']),
                      subtitle: Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format((feedback['createDate'] as Timestamp).toDate())}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}