import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_content_screen.dart';
import 'manage_content_screen.dart';
import 'schedule_content_screen.dart';
import 'content_analysis_screen.dart';
import 'cc_profile_screen.dart';

class ContentCreatorPage extends StatefulWidget {
  const ContentCreatorPage({Key? key}) : super(key: key);

  @override
  _ContentCreatorPageState createState() => _ContentCreatorPageState();
}

class _ContentCreatorPageState extends State<ContentCreatorPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    CreateContentScreen(),
    ManageContentScreen(),
    ScheduleContentScreen(),
    ContentAnalysisScreen(),
    CCProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Content Creator',
          style: GoogleFonts.bungeeSpice(fontSize: 24.0, letterSpacing: 1.0),
        ),
        leading: Image.asset('assets/images/logo.png'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.create_rounded),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_rounded),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_rounded),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFF88232),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.lato(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }
}
