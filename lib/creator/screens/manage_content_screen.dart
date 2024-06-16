import 'package:flutter/material.dart';
import '../functions/content_data.dart';
import '../functions/content_function.dart';
import '../functions/content_card.dart';
import '../../common function/user_services.dart';
import 'edit_content_screen.dart';

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
    _contentsStream = _contentFunction.getContentsByCreator(UserData.getCurrentUserID());
  }

  void _deleteContent(String contentId) async {
    await _contentFunction.deleteContent(contentId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Content deleted')));
    setState(() {
      _contentsStream = _contentFunction.getContentsByCreator(UserData.getCurrentUserID());
    });
  }

  void _editContent(ContentData content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContentScreen(content: content),
      ),
    );
  }

  void _likeContent(String contentId) async {
    await _contentFunction.likeContent(contentId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Content liked')));
  }

  void _commentOnContent() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comment added')));
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
                  onLike: () => _likeContent(content.contentId),
                  onComment: _commentOnContent,
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
