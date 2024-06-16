import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jom_eat_project/foodie/widgets/create_outing_screen_widget/select_restaurant_model.dart';
import 'dart:typed_data';
import 'package:jom_eat_project/models/restaurant_model.dart';
import 'package:jom_eat_project/services/database_service.dart';

class CreateOutingScreen extends StatefulWidget {
  const CreateOutingScreen({super.key, required this.userId});
  final String userId;

  @override
  State<CreateOutingScreen> createState() => _CreateOutingScreenState();
}

class _CreateOutingScreenState extends State<CreateOutingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController restaurantController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxParticipantsController =
      TextEditingController();
  DateTime? outingDate;
  TimeOfDay? outingStartTime;
  TimeOfDay? outingEndTime;
  String? restaurantId;
  String? restaurantName;
  String? selectedCuisineType;
  Uint8List? _imageFile;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    outingDate = DateTime.now();
  }

  Future<DateTime?> datePicker(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  Future<TimeOfDay?> timePicker(BuildContext context) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = bytes;
      });
    }
  }

  void _submitForm(String userId) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create outing group document in Firestore
      FirebaseFirestore.instance.collection('outingGroups').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'cuisineType': selectedCuisineType, // Selected cuisine type
        'date': outingDate,
        'day': DateFormat('EEEE').format(outingDate!),
        'startTime': startTimeController.text,
        'endTime': endTimeController.text,
        'createdByUser': FirebaseFirestore.instance
            .collection('users')
            .doc(userId), // Example user ID
        'members': [],
        'maxMembers': int.parse(maxParticipantsController.text),
        'image':
            'https://media.istockphoto.com/id/480163910/photo/group-of-students-communicating-during-lunch-in-cafeteria.jpg?s=612x612&w=0&k=20&c=ArSQqUPFGGQd7sVG129EJO0kjEvPtyO-BiE_ZCpWaFc=', // Add image URL after uploading the image
        'location': locationController.text,
        'restaurantId': FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId), // Example business ID
      }).then((value) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outing created successfully!')),
        );
        // Reset the form
        setState(() {
          _formKey.currentState!.reset();
          dateController.clear();
          startTimeController.clear();
          endTimeController.clear();
          restaurantController.clear();
          locationController.clear();
          titleController.clear();
          descriptionController.clear();
          maxParticipantsController.clear();
          _imageFile = null;
          restaurantId = null;
          restaurantName = null;
          outingDate = DateTime.now();
          selectedCuisineType = null;
        });
      }).catchError((error) {
        print("Failed to create outing: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Outing')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Outing Date
              GestureDetector(
                onTap: () async {
                  DateTime? date = await datePicker(context);
                  setState(() {
                    outingDate = date;
                    dateController.text =
                        DateFormat('dd MMM yyyy').format(outingDate!);
                  });
                },
                child: TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the date of the outing.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Outing Time
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        TimeOfDay? time = await timePicker(context);
                        setState(() {
                          outingStartTime = time;
                          startTimeController.text =
                              formatTimeOfDay(outingStartTime!);
                        });
                      },
                      child: TextFormField(
                        controller: startTimeController,
                        decoration:
                            const InputDecoration(labelText: 'Start Time'),
                        enabled: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the start time of the outing.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        TimeOfDay? time = await timePicker(context);
                        setState(() {
                          outingEndTime = time;
                          endTimeController.text =
                              formatTimeOfDay(outingEndTime!);
                        });
                      },
                      child: TextFormField(
                        controller: endTimeController,
                        decoration:
                            const InputDecoration(labelText: 'End Time'),
                        enabled: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the end time of the outing.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Select Cuisine Type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Cuisine Type'),
                items: [
                  'Chinese',
                  'Western',
                  'Indian',
                  'Malay',
                  'Japanese',
                  'Korean'
                ]
                    .map((cuisine) => DropdownMenuItem(
                          value: cuisine,
                          child: Text(cuisine),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCuisineType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the cuisine type of the outing.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Select Business
              GestureDetector(
                onTap: _showSelectBusinessModal,
                child: TextFormField(
                  controller: restaurantController,
                  decoration: const InputDecoration(labelText: 'Business'),
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the business of the outing.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Location
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location of the outing.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Title
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title of the outing.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description of the outing.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Maximum Participants
              TextFormField(
                controller: maxParticipantsController,
                decoration:
                    const InputDecoration(labelText: 'Maximum Participants'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the maximum number of participants.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Image Picker
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFile == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : Image.memory(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton(
                onPressed: () => _submitForm(widget.userId),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.orange), // Change to orange color
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: const Text(
                  'Create Outing',
                  style: TextStyle(
                      color: Colors.white), // Ensure text color is white
                ),
              ),
              const SizedBox(height: 128),
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectBusinessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SelectRestaurantModal(
          onSelect: (selectedRestaurant) {
            setState(() {
              restaurantId = selectedRestaurant.id;
              restaurantName = selectedRestaurant.name;
              restaurantController.text = selectedRestaurant.name;
              locationController.text = selectedRestaurant.location;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
