import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/common function/userdata.dart';

class UpdatePolicyPage extends StatefulWidget {
  final String userId;

  UpdatePolicyPage({required this.userId});

  @override
  _UpdatePolicyPageState createState() => _UpdatePolicyPageState();
}

class _UpdatePolicyPageState extends State<UpdatePolicyPage> {
  late Future<List<Map<String, dynamic>>> _policiesFuture;
  late UserData userData;

  @override
  void initState() {
    super.initState();
    userData = UserData(userId: widget.userId);
    _policiesFuture = userData.getPolicies();
  }

  void _showUpdateDialog(Map<String, dynamic> policy) {
    TextEditingController titleController = TextEditingController(text: policy['title'] ?? '');
    TextEditingController detailsController = TextEditingController(text: policy['details'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Policy'),
          content: Container(
            width: 340,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(labelText: 'Details'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updateData = {
                  'title': titleController.text,
                  'details': detailsController.text,
                };
                await userData.updatePolicy(policy['id'], updateData);
                setState(() {
                  _policiesFuture = userData.getPolicies();
                });
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddPolicyDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Policy'),
          content: Container(
            width: 340,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(labelText: 'Details'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> newPolicy = {
                  'title': titleController.text,
                  'details': detailsController.text,
                };
                await userData.addPolicy(newPolicy);
                setState(() {
                  _policiesFuture = userData.getPolicies();
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jom Eat Policies',style: GoogleFonts.arvo(fontSize: 24.0, letterSpacing: 0.5),),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _policiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No policies found.'));
          } else {
            List<Map<String, dynamic>> policies = snapshot.data!;
            return ListView.builder(
              itemCount: policies.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> policy = policies[index];
                return ListTile(
                  title: Text(policy['title'] ?? 'Title not found'),
                  subtitle: JustifiedText(policy['details'] ?? 'Details not found'),
                  onTap: () {
                    _showUpdateDialog(policy);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPolicyDialog,
        child: const Icon(Icons.add_rounded, color: Color(0xFFF35000),),
      ),
    );
  }
}

class JustifiedText extends StatelessWidget {
  final String text;

  JustifiedText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.justify,
      ),
    );
  }
}
