import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ccfunction/note_data.dart';
import '../ccfunction/content_data.dart';
import '../ccfunction/content_function.dart';

class ScheduleContentScreen extends StatefulWidget {
  @override
  _ScheduleContentScreenState createState() => _ScheduleContentScreenState();
}

class _ScheduleContentScreenState extends State<ScheduleContentScreen> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<ContentData>> _scheduledContents = {};
  Map<DateTime, List<NoteData>> _notes = {};
  final ContentFunction _contentFunction = ContentFunction();

  @override
  void initState() {
    super.initState();
    _fetchScheduledContents();
    _fetchNotes();
  }

  void _fetchScheduledContents() async {
    // Fetch and populate _scheduledContents map
  }

  void _fetchNotes() async {
    // Fetch and populate _notes map
  }

  void _addNote() {
    // Logic to add a note
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Contents'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          Expanded(
            child: ListView(
              children: [
                ..._scheduledContents[_selectedDay]?.map((content) {
                  return ListTile(
                    title: Text(content.title),
                    subtitle: Text(content.description),
                  );
                }) ?? [],
                ..._notes[_selectedDay]?.map((note) {
                  return ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.description),
                  );
                }) ?? [],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
      ),
    );
  }
}
