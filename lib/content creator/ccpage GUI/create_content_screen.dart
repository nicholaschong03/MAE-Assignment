import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ccfunction/content_data.dart';
import '../ccfunction/content_function.dart';

class CreateContentScreen extends StatefulWidget {
  @override
  _CreateContentScreenState createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _mediaUrls = [];
  DateTime? _scheduledAt;
  final ContentFunction _contentFunction = ContentFunction();

  void _pickMedia() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaUrls.add(pickedFile.path);
      });
    }
  }

  void _createContent() async {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      final content = ContentData(
        contentId: _contentFunction.firestore.collection('contents').doc().id,
        ccId: 'ccId', // Replace with actual content creator id
        title: _titleController.text,
        description: _descriptionController.text,
        mediaUrls: _mediaUrls,
        createdAt: DateTime.now(),
        scheduledAt: _scheduledAt != null ? (_scheduledAt! as Timestamp).toDate() : Timestamp.now().toDate(),
        tags: [], // Add logic to add tags if needed
        likes: 0,
        comments: [],
      );

      await _contentFunction.createContent(content);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Content'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickMedia,
              child: Text('Add Media'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  setState(() {
                    _scheduledAt = pickedDate;
                  });
                }
              },
              child: Text('Schedule Date'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createContent,
              child: Text('Create Content'),
            ),
          ],
        ),
      ),
    );
  }
}
