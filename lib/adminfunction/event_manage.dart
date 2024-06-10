import 'package:flutter/material.dart';

class EventManagePage extends StatefulWidget {
  const EventManagePage({super.key});

  @override
  _EventManagePageState createState() => _EventManagePageState();
}

class _EventManagePageState extends State<EventManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Management'),
      ),
      body: Center(
        child: Text(
          'Event Management Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}