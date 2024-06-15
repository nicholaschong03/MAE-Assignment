import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jom_eat_project/admin/functions/policy.dart'; // Import the new file

class UpdatePolicyPage extends StatefulWidget {
  final String userId;

  UpdatePolicyPage({required this.userId});

  @override
  _UpdatePolicyPageState createState() => _UpdatePolicyPageState();
}

class _UpdatePolicyPageState extends State<UpdatePolicyPage> {
  late Future<List<Map<String, dynamic>>> _policiesFuture;
  late PolicyData policyData; // Use PolicyData instead of UserData

  @override
  void initState() {
    super.initState();
    policyData = PolicyData(); // Initialize PolicyData
    _policiesFuture = policyData.getPolicies();
  }

  void _showUpdateDialog(Map<String, dynamic> policy) {
    TextEditingController titleController =
        TextEditingController(text: policy['title'] ?? '');
    TextEditingController detailsController =
        TextEditingController(text: policy['details'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Policy'),
          content: Container(
            width: 340,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'Details'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updateData = {
                  'title': titleController.text,
                  'details': detailsController.text,
                };
                await policyData.updatePolicy(policy['id'], updateData);
                setState(() {
                  _policiesFuture = policyData.getPolicies();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
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
          title: const Text('Add Policy'),
          content: Container(
            width: 340,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'Details'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> newPolicy = {
                  'title': titleController.text,
                  'details': detailsController.text,
                };
                await policyData.addPolicy(newPolicy);
                setState(() {
                  _policiesFuture = policyData.getPolicies();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
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
        title: const Text('Update Policies'),
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
                  subtitle:
                      JustifiedText(policy['details'] ?? 'Details not found'),
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
        child: const Icon(
          Iconsax.add5,
          color: Color(0xFFF88232),
        ),
      ),
    );
  }
}

class JustifiedText extends StatelessWidget {
  final String text;
  const JustifiedText(this.text, {super.key});
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
