import 'package:flutter/material.dart';
import '../ccfunction/content_data.dart';
import '../ccfunction/content_function.dart';
import '../ccfunction/content_card.dart';

class ManageContentScreen extends StatefulWidget {
  @override
  _ManageContentScreenState createState() => _ManageContentScreenState();
}

class _ManageContentScreenState extends State<ManageContentScreen> {
  final ContentFunction _contentFunction = ContentFunction();
  late Stream<List<ContentData>> _contentsStream;

  @override
  void initState() {
    super.initState();
    _contentsStream = _contentFunction.getContentsByCreator('ccId'); // Replace with actual content creator id
  }

  void _deleteContent(String contentId) async {
    await _contentFunction.deleteContent(contentId);
  }

  void _editContent(ContentData content) {
    // Logic to edit content
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Content'),
      ),
      body: StreamBuilder<List<ContentData>>(
        stream: _contentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final contents = snapshot.data!;
            return ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final content = contents[index];
                return ContentCard(
                  content: content,
                  onLike: () {}, // Add logic to like content
                  onComment: () {}, // Add logic to comment on content
                  onEdit: () => _editContent(content),
                  onDelete: () => _deleteContent(content.contentId),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
