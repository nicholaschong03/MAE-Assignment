import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jom_eat_project/adminfunction/statistic_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPanel extends StatefulWidget {
  const ReportsPanel({super.key});

  @override
  _ReportsPanelState createState() => _ReportsPanelState();
}

class _ReportsPanelState extends State<ReportsPanel> {
  late Future<int> _totalUsers;
  late Future<int> _totalOutings;
  late Future<Map<String, int>> _usersByRole;
  late Future<int> _totalAdmins;

  DateTime startDate = DateTime.now()
      .subtract(const Duration(days: 30)); // Default to last 30 days
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  void _fetchStatistics() {
    StatisticsService statisticsService = StatisticsService();
    _totalUsers = statisticsService.getTotalUsersByDate(
        startDate: startDate, endDate: endDate);
    _totalOutings = statisticsService.getTotalOutingsByDate(
        startDate: startDate, endDate: endDate);
    _usersByRole = statisticsService.getTotalUsersByRole(
        startDate: startDate, endDate: endDate);
    _totalAdmins = statisticsService.getTotalUsersByRoleAndCount('admin', startDate: startDate, endDate: endDate);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDate : endDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
          if (endDate.isBefore(startDate)) {
            startDate = endDate;
          }
        }
        _fetchStatistics();
      });
    }
  }

  Widget _buildPieChart() {
    return FutureBuilder<Map<String, int>>(
      future: _usersByRole,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.black));
        } else {
          var roleCounts = snapshot.data ?? {};
          List<PieChartSectionData> sections = [];

          roleCounts.forEach((role, count) {
            if ((role == 'cc' || role == 'foodie') &&
                count.isFinite &&
                count > 0) {
              sections.add(PieChartSectionData(
                color: role == 'cc'
                    ? const Color(0xFFFACA58)
                    : const Color(0xFFF88232),
                value: count.toDouble(),
                title: role == 'cc' ? 'Content Creator' : 'Foodie',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Label color
                ),
              ));
            }
          });

          if (sections.isEmpty) {
            return const Center(
                child: Text('No data available for the selected period.'));
          }

          return AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event,
                        PieTouchResponse? pieTouchResponse) {}),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 234, 211),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 234, 211),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Statistics & Reports',
              style: GoogleFonts.dosis(
                color: const Color(0xFFF35000),
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<int>(
                    future: Future.wait([_totalUsers, _totalAdmins]).then((results) => results[0] - results[1]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.black));
                      } else {
                        return Text(
                          'Total Users: ${snapshot.data}',
                          style: GoogleFonts.niramit(
                              fontSize: 16.0, color: Colors.black),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  FutureBuilder<int>(
                    future: _totalOutings,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.black));
                      } else {
                        return Text(
                          'Total Outings: ${snapshot.data}',
                          style: GoogleFonts.niramit(
                              fontSize: 16.0, color: Colors.black),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    'User Stats for the selected period:',
                    style: GoogleFonts.niramit(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14.0),
                  _buildPieChart(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(
                    'Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}',
                    style: GoogleFonts.georama(
                      color: const Color(0xFFF88232),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(
                    'End Date: ${DateFormat('yyyy-MM-dd').format(endDate)}',
                    style: GoogleFonts.georama(
                      color: const Color(0xFFF88232),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
