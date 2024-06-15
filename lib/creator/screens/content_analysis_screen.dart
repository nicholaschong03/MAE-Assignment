import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../functions/content_data.dart';
import '../functions/content_function.dart';

class ContentAnalysisScreen extends StatefulWidget {
  @override
  _ContentAnalysisScreenState createState() => _ContentAnalysisScreenState();
}

class _ContentAnalysisScreenState extends State<ContentAnalysisScreen> {
  final ContentFunction _contentFunction = ContentFunction();
  late Stream<List<ContentData>> _contentsStream;
  String selectedMetric = 'posts'; // Default metric to show

  @override
  void initState() {
    super.initState();
    _contentsStream = _contentFunction.getContentsByCreator('ccId');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          if (snapshot.hasData) {
            final contents = snapshot.data!;
            int totalPosts = contents.length;
            int totalLikes = contents.fold(0, (sum, content) => sum + content.likes);
            int totalComments = contents.fold(0, (sum, content) => sum + content.comments.length);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Posts'),
                        selected: selectedMetric == 'posts',
                        onSelected: (bool selected) {
                          setState(() {
                            selectedMetric = 'posts';
                            _showSnackBar('Displaying posts data');
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Likes'),
                        selected: selectedMetric == 'likes',
                        onSelected: (bool selected) {
                          setState(() {
                            selectedMetric = 'likes';
                            _showSnackBar('Displaying likes data');
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Comments'),
                        selected: selectedMetric == 'comments',
                        onSelected: (bool selected) {
                          setState(() {
                            selectedMetric = 'comments';
                            _showSnackBar('Displaying comments data');
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        barGroups: contents.map((content) {
                          double value;
                          switch (selectedMetric) {
                            case 'likes':
                              value = content.likes.toDouble();
                              break;
                            case 'comments':
                              value = content.comments.length.toDouble();
                              break;
                            default:
                              value = 1.0; // Each post counts as one
                          }
                          return BarChartGroupData(
                            x: contents.indexOf(content),
                            barRods: [
                              BarChartRodData(
                                toY: value,
                                width: 16,
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= contents.length) {
                                  return Container();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    contents[index].title,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total ${selectedMetric == 'posts' ? 'Posts' : selectedMetric == 'likes' ? 'Likes' : 'Comments'}: ${selectedMetric == 'posts' ? totalPosts : selectedMetric == 'likes' ? totalLikes : totalComments}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
