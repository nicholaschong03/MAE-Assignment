import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/adminfunction/user_manage.dart';
import 'package:jom_eat_project/adminfunction/event_manage.dart';
import 'package:jom_eat_project/adminfunction/content_service.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class HomePanel extends StatelessWidget {
  final ContentService contentService = ContentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: GoogleFonts.georama(color: const Color(0xFFF88232))),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
              );
            },
            color: const Color(0xFFF88232),
          ),
          IconButton(
            icon: const Icon(Icons.event_note_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventManagePage()),
              );
            },
            color: const Color(0xFFF88232),
          ),
        ],
      ),
      body: StreamBuilder<List<Content>>(
        stream: contentService.getContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No content available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var content = snapshot.data![index];
              return PostItem(content: content, onDelete: () => contentService.deleteContent(content.id));
            },
          );
        },
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final Content content;
  final VoidCallback onDelete;

  const PostItem({super.key, required this.content, required this.onDelete});

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                onDelete(); // Perform the deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile picture and username
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(content.profilePictureUrl),
            ),
            title: Text(content.username),
            trailing: IconButton(
              icon: const Icon(FeatherIcons.trash2, color: Color(0xFFF35000)),
              onPressed: () => _confirmDeletion(context),
            ),
          ),
          // Image
          if (content.mediaUrls.isNotEmpty)
            Image.network(content.mediaUrls.first),
          // Title (description)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(content.description),
              ],
            ),
          ),
          // Likes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(FeatherIcons.filter,color:  Color(0xFFF88232)),
                const SizedBox(width: 10.0),
                Text('${content.likes} likes'),
              ],
            ),
          ),
          // Comments
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content.comments.map((comment) {
                return Text('${comment.user}: ${comment.comment}');
              }).toList(),
            ),
          ),
          // Tags
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: content.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
