import 'package:flutter/material.dart';
import 'content_data.dart';
import 'content_function.dart';
import 'package:jom_eat_project/common function/user_services.dart';

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
  }) : super(key: key);

  final TextEditingController _commentController = TextEditingController();

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
            if (content.tags.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: content.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: onLike,
                ),
                Text('${content.likes}'),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    _showCommentDialog(context);
                  },
                ),
                Text('${content.comments.length}'),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (content.comments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content.comments.map((comment) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Text(
                          '${comment['user']}: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(comment['comment'])),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: 'Enter your comment'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await ContentFunction().commentOnContent(content.contentId, UserData.getCurrentUserID(), _commentController.text);
                Navigator.of(context).pop();
                onComment();
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
