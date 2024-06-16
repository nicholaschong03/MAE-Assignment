import 'package:flutter/material.dart';
import 'package:jom_eat_project/models/content_model.dart';
import 'package:jom_eat_project/models/user_model.dart';
import 'package:jom_eat_project/services/database_service.dart';

class FeedPostCard extends StatefulWidget {
  final ContentModel content;
  final DataService _dataService = DataService();

  FeedPostCard({required this.content});

  @override
  _FeedPostCardState createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _isLiked = false;
  int _likesCount = 0;
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likesCount = widget.content.likes;
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    // Update Firestore
    try {
      await widget._dataService.updateLikes(widget.content.id, _likesCount);
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: widget._dataService.getUser(widget.content.ccId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('User data not found.'));
        } else {
          UserModel user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profileImage.isNotEmpty
                          ? NetworkImage(user.profileImage)
                          : null,
                      child: user.profileImage.isEmpty
                          ? Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user.username),
                  ),
                  if (widget.content.mediaUrls.isNotEmpty)
                    Image.network(widget.content.mediaUrls[0]),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.content.description),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up,
                                color: _isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleLike,
                            ),
                            SizedBox(width: 4),
                            Text(_likesCount.toString()),
                          ],
                        ),
                        Text(formatDate(widget.content.createdAt.toDate())),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _toggleComments,
                          child: Text(_showComments ? "Hide Comments" : "Show Comments"),
                        ),
                      ],
                    ),
                  ),
                  if (_showComments)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.content.comments.length,
                      itemBuilder: (context, index) {
                        var comment = widget.content.comments[index];
                        return ListTile(
                          title: Text(comment['user']),
                          subtitle: Text(comment['comment']),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

// Function to format DateTime to yyyy-MM-dd
String formatDate(DateTime dateTime) {
  return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
}