import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../common function/user_services.dart';
import '../functions/content_data.dart';
import '../functions/content_function.dart';
import '../functions/note_data.dart';
import '../functions/note_function.dart';

class ScheduleContentScreen extends StatefulWidget {
  @override
  _ScheduleContentScreenState createState() => _ScheduleContentScreenState();
}

class _ScheduleContentScreenState extends State<ScheduleContentScreen> {
  DateTime _selectedDay = DateTime.now();
  late Map<DateTime, List<ContentData>> _scheduledContents;
  late Map<DateTime, List<NoteData>> _notes;
  final ContentFunction _contentFunction = ContentFunction();
  final NoteFunction _noteFunction = NoteFunction();
  final String _ccId = UserData.getCurrentUserID();

  @override
  void initState() {
    super.initState();
    _scheduledContents = {};
    _notes = {};
    _fetchScheduledContents();
    _fetchNotes();
  }

  Future<void> _fetchScheduledContents() async {
    _contentFunction.getContentsByCreator(_ccId).listen((contents) {
      setState(() {
        _scheduledContents = {};
        for (var content in contents) {
          final date = DateTime(content.scheduledAt.year, content.scheduledAt.month, content.scheduledAt.day);
          if (_scheduledContents[date] == null) {
            _scheduledContents[date] = [];
          }
          _scheduledContents[date]!.add(content);
        }
      });
    });
  }

  Future<void> _fetchNotes() async {
    _noteFunction.getNotesByCreator(_ccId).listen((notes) {
      setState(() {
        _notes = {};
        for (var note in notes) {
          final date = DateTime(note.createdAt.toDate().year, note.createdAt.toDate().month, note.createdAt.toDate().day);
          if (_notes[date] == null) {
            _notes[date] = [];
          }
          _notes[date]!.add(note);
        }
      });
    });
  }

  void _addNote() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final note = NoteData(
                  noteId: _noteFunction.firestore.collection('notes').doc().id,
                  ccId: _ccId,
                  title: titleController.text,
                  description: descriptionController.text,
                  createdAt: Timestamp.fromDate(_selectedDay),
                );

                await _noteFunction.createNote(note);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note added')));
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final contents = _scheduledContents[day] ?? [];
    final notes = _notes[day] ?? [];
    return [...contents, ...notes];
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: events.any((e) => e is ContentData) ? Colors.blue : Colors.red,
      ),
      child: Text(
        '${events.length}',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
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
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return _buildEventsMarker(date, events);
                }
                return SizedBox.shrink();
              },
            ),
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
