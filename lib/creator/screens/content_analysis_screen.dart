import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
  String selectedMetric = 'posts'; // Default metric to show

  @override
  void initState() {
    super.initState();
    _contentsStream = _contentFunction.getContentsByCreator(UserData.getCurrentUserID());
  }

  List<FlSpot> _generateData(List<ContentData> contents) {
    Map<DateTime, int> monthlyData = {};
    for (var content in contents) {
      final DateTime monthYear = DateTime(content.createdAt.year, content.createdAt.month);
      if (!monthlyData.containsKey(monthYear)) {
        monthlyData[monthYear] = 0;
      }
      switch (selectedMetric) {
        case 'likes':
          monthlyData[monthYear] = monthlyData[monthYear]! + content.likes;
          break;
        case 'comments':
          monthlyData[monthYear] = monthlyData[monthYear]! + content.comments.length;
          break;
        default:
          monthlyData[monthYear] = monthlyData[monthYear]! + 1; // Count pos ts
          break;
      }
    }

    List<FlSpot> spots = [];
    int i = 0;
    for (var entry in monthlyData.entries) {
      spots.add(FlSpot(i.toDouble(), entry.value.toDouble()));
      i++;
    }
    return spots;
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
          final spots = _generateData(contents);

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
                          _generateData(contents); // Refresh data
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Displaying posts data')));
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
                          _generateData(contents); // Refresh data
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Displaying likes data')));
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
                          _generateData(contents); // Refresh data
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Displaying comments data')));
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 4,
                          color: Colors.blue,
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              if (value.toInt() >= 0 && value.toInt() < contents.length) {
                                return Text(
                                  DateFormat('MMM yyyy').format(contents[value.toInt()].createdAt),
                                  style: TextStyle(fontSize: 10),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Text(value.toInt().toString()),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total ${selectedMetric == 'posts' ? 'Posts' : selectedMetric == 'likes' ? 'Likes' : 'Comments'}: ${spots.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
