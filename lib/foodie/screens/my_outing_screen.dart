import 'package:flutter/material.dart';
import 'package:jom_eat_project/foodie/screens/foodie_profile_screen.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import 'package:jom_eat_project/services/database_service.dart';
import 'package:jom_eat_project/foodie/screens/edit_outing_screen.dart'; // Import the screen to edit outings

class MyOutingsScreen extends StatelessWidget {
  final String userId;
  final DataService _dataService = DataService();

  MyOutingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Outings'),
      ),
      body: StreamBuilder<List<OutingGroupModel>>(
        stream: _dataService.getUserOutings(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You haven\'t created any food outings yet.'));
          } else {
            var outings = snapshot.data!;
            return ListView.builder(
              itemCount: outings.length,
              itemBuilder: (context, index) {
                var outing = outings[index];
                return ListTile(
                  title: Text(outing.title),
                  subtitle: Text(formatDate(outing.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOutingScreen(outing: outing),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _dataService.deleteOuting(outing.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Outing deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
