import 'package:flutter/material.dart';
import 'package:jom_eat_project/models/content_model.dart';
import 'package:jom_eat_project/services/database_service.dart';
import 'package:jom_eat_project/foodie/widgets/feed_post_widget/feed_post_card.dart';

class FeedPostScreen extends StatefulWidget {
  @override
  _FeedPostScreenState createState() => _FeedPostScreenState();
}

class _FeedPostScreenState extends State<FeedPostScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feed Posts")),
      body: StreamBuilder<List<ContentModel>>(
        stream: _dataService.getContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts found.'));
          } else {
            List<ContentModel> contents = snapshot.data!;
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: contents.length,
              itemBuilder: (context, index) {
                return FeedPostCard(content: contents[index]);
              },
            );
          }
        },
      ),
    );
  }
}