import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_data.dart';
import 'content_function.dart';
import '../common function/user_services.dart';

class CreateContentScreen extends StatefulWidget {
  @override
  _CreateContentScreenState createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _mediaUrls = [];
  final List<String> _tags = [];
  DateTime? _scheduledAt;
  final ContentFunction _contentFunction = ContentFunction();

  void _pickMedia() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaUrls.add(pickedFile.path);
      });
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

  void _createContent() async {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      final content = ContentData(
        contentId: _contentFunction.firestore.collection('contents').doc().id,
        ccId: UserData.getCurrentUserID(),
        title: _titleController.text,
        description: _descriptionController.text,
        mediaUrls: _mediaUrls,
        createdAt: DateTime.now(),
        scheduledAt: _scheduledAt ?? DateTime.now(),
        tags: _tags,
        likes: 0,
        comments: [],
      );

      await _contentFunction.createContent(content);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Title and Description are required.'),
      ));
    }
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickMedia();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  _pickMedia();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Content'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              Wrap(
                spacing: 8.0,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _showImageOptions(context),
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
                child: Text('Schedule Date and Time'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createContent,
                child: Text('Create Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
