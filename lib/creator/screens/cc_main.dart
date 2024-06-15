import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'create_content_screen.dart';
import 'manage_content_screen.dart';
import 'schedule_content_screen.dart';
import 'content_analysis_screen.dart';
import 'cc_profile_screen.dart';
import 'package:jom_eat_project/common function/notification.dart';

class ContentCreatorPage extends StatefulWidget {
  final String userId;
  final String role;
  const ContentCreatorPage({Key? key, required this.userId, required this.role}) : super(key: key);

  @override
  _ContentCreatorPageState createState() => _ContentCreatorPageState();
}

class _ContentCreatorPageState extends State<ContentCreatorPage> {
  int _selectedIndex = 3; // Default to Content Analysis Screen
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _checkForUnreadNotifications();
  }

  Future<void> _checkForUnreadNotifications() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore
        .collection('notifications')
        .where('read_status', isEqualTo: false)
        .where('toRole', isEqualTo: widget.role) // Check if the notification is for content creator
        .get();

    setState(() {
      _hasUnreadNotifications = snapshot.docs.isNotEmpty;
    });
  }

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
        backgroundColor: const Color.fromARGB(255, 255, 234, 211),
        actions: [
          IconButton(
            icon: Icon(
              _hasUnreadNotifications
                  ? Icons.notification_important
                  : Icons.notifications_none,
              color: _hasUnreadNotifications
                  ? const Color(0xFFF88232)
                  : Colors.grey,
            ),
            onPressed: () {
              // Show notifications page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(userId: widget.userId, role: widget.role),
                ),
              ).then((value) => _checkForUnreadNotifications()); // Recheck for unread notifications when returning
            },
          ),
        ],
        title: TextButton(
          onPressed: () {
            setState(() {
              _checkForUnreadNotifications();
            });
          },
          child: Text(
            'Jom Eat',
            style: GoogleFonts.bungeeSpice(fontSize: 24.0, letterSpacing: 1.0),
          ),
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
        unselectedItemColor: Color.fromARGB(190, 49, 49, 49),
        selectedLabelStyle: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.lato(fontSize: 12),
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 255, 234, 211),
      ),
    );
  }
}
