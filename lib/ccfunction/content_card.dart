import 'package:flutter/material.dart';
import 'content_data.dart';

class ContentCard extends StatelessWidget {
  final ContentData content;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ContentCard({
    Key? key,
    required this.content,
    required this.onLike,
    required this.onComment,
    required this.onEdit,
    required this.onDelete,
  }): super(key : key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(content.description),
            SizedBox(height: 8.0),
            if (content.mediaUrls.isNotEmpty)
              Image.network(content.mediaUrls.first),
            SizedBox(height: 8.0),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: onLike,
                ),
                Text('${content.likes}'),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: onComment,
                ),
                Text('${content.comments.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
