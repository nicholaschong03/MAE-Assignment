import 'package:flutter/material.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import 'package:jom_eat_project/services/database_service.dart';

class EditOutingScreen extends StatefulWidget {
  final OutingGroupModel outing;

  const EditOutingScreen({super.key, required this.outing});

  @override
  _EditOutingScreenState createState() => _EditOutingScreenState();
}

class _EditOutingScreenState extends State<EditOutingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.outing.title;
    _descriptionController.text = widget.outing.description;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> updatedData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          // Add more fields as needed
        };
        await _dataService.updateOuting(widget.outing.id, updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outing updated successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating outing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Outing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
