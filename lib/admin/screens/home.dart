import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jom_eat_project/admin/functions/content_service.dart';

class HomePanel extends StatelessWidget {
  final ContentService contentService = ContentService();
  HomePanel({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 255, 234, 211), // Set background color to the specified color
      body: StreamBuilder<List<Content>>(
        stream: contentService.getContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No content available', style: TextStyle(color: Colors.black)));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var content = snapshot.data![index];
              return PostItem(
                  content: content,
                  onDelete: () => contentService.deleteContent(content.id));
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
          title: const Text('Post Deletion'),
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
      color: const Color(0xFFFFFAFB), // Background for the card
      margin: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile picture and username
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(content.profilePictureUrl),
            ),
            title: Text(content.username,
                style: GoogleFonts.georama(fontWeight: FontWeight.w700, color: Colors.black)),
            trailing: IconButton(
              icon: const Icon(Iconsax.trash4, color: Colors.black),
              onPressed: () => _confirmDeletion(context),
            ),
          ),
          // Image
          if (content.mediaUrls.isNotEmpty)
            Image.network(content.mediaUrls.first),
          // Title (description)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: GoogleFonts.anekDevanagari(
                      fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const SizedBox(height: 8.0),
                Text(
                  content.description,
                  style: GoogleFonts.anekDevanagari(
                      fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.black),
                ),
              ],
            ),
          ),
          // Likes
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Iconsax.heart5, color: Color(0xFFF88232)),
                const SizedBox(width: 10.0),
                Text(
                  '${content.likes} likes',
                  style: GoogleFonts.ptMono(fontSize: 14.0, color: Colors.black),
                ),
              ],
            ),
          ),
          // Comments
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content.comments.map((comment) {
                return Text(
                  '${comment.user}: ${comment.comment}',
                  style: GoogleFonts.hindVadodara(fontSize: 16.0, color: Colors.black),
                );
              }).toList(),
            ),
          ),
          // Tags
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8.0,
              children: content.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: GoogleFonts.hindVadodara(
                        fontSize: 16.0, color: const Color(0xFFF35000), fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: const Color(0xFFFFFAFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45.0),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
