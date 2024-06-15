import 'package:flutter/material.dart';
import '../functions/content_data.dart';
import '../functions/content_function.dart';
import 'package:jom_eat_project/common function/user_services.dart';

class ContentAnalysisScreen extends StatefulWidget {
  @override
  _ContentAnalysisScreenState createState() => _ContentAnalysisScreenState();
}

class _ContentAnalysisScreenState extends State<ContentAnalysisScreen> {
  final ContentFunction _contentFunction = ContentFunction();
  late Stream<List<ContentData>> _contentsStream;

  @override
  void initState() {
    super.initState();
    _contentsStream = _contentFunction.getContentsByCreator(UserData.getCurrentUserID());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content Analysis'),
      ),
      body: StreamBuilder<List<ContentData>>(
        stream: _contentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Data Found'));
          }

          final contents = snapshot.data!;
          int totalPosts = contents.length;
          int totalLikes = contents.fold(0, (sum, content) => sum + content.likes);
          int totalComments = contents.fold(0, (sum, content) => sum + content.comments.length);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Posts: $totalPosts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Likes: $totalLikes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Comments: $totalComments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
