import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../ccfunction/content_data.dart';
import '../ccfunction/content_function.dart';

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
    _contentsStream = _contentFunction.getContentsByCreator('ccId');
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
            return Column(
              children: [
                Expanded(
                  child: BarChart(
                    BarChartData(
                      barGroups: contents.map((content) => BarChartGroupData(
                        x: contents.indexOf(content),
                        barRods: [
                          BarChartRodData(fromY: content.likes.toDouble(), color: Colors.blue, toY: 0.0)
                        ],
                      )).toList(),
                    ),
                  ),
                ),
                // ListView.builder remains the same
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