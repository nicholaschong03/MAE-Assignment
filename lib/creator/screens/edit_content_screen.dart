import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_data.dart';
import 'content_function.dart';
import '../common function/user_services.dart';

class EditContentScreen extends StatefulWidget {
  final ContentData content;

  EditContentScreen({required this.content});

  @override
  _EditContentScreenState createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _mediaUrls = [];
  DateTime? _scheduledAt;
  final ContentFunction _contentFunction = ContentFunction();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.content.title;
    _descriptionController.text = widget.content.description;
    _mediaUrls.addAll(widget.content.mediaUrls);
    _scheduledAt = widget.content.scheduledAt;
    _tags.addAll(widget.content.tags);
  }

  void _pickMedia() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaUrls.add(pickedFile.path);
      });
    }
  }

  void _updateContent() async {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      final content = ContentData(
        contentId: widget.content.contentId,
        ccId: UserData.getCurrentUserID(),
        title: _titleController.text,
        description: _descriptionController.text,
        mediaUrls: _mediaUrls,
        createdAt: widget.content.createdAt,
        scheduledAt: _scheduledAt != null ? _scheduledAt! : DateTime.now(),
        tags: _tags,
        likes: widget.content.likes,
        comments: widget.content.comments,
      );

      await _contentFunction.updateContent(content);
      Navigator.pop(context, content);
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Content'),
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
            Wrap(
              spacing: 8.0,
              children: _tags.map((tag) => Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
              )).toList(),
            ),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: 'Add Tag',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _scheduledAt ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _scheduledAt = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text('Schedule Date'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateContent,
              child: Text('Update Content'),
            ),
          ],
        ),
      ),
    );
  }
}
