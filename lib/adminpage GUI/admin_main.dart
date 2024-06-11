import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notification.dart';
import 'home.dart';
import 'profile.dart';
import 'feedback.dart';
import 'reports.dart';

class AdminPage extends StatefulWidget {
  final String userId;
  final String role;

  const AdminPage({Key? key, required this.userId, required this.role}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
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
        .where('toRole', isEqualTo: widget.role) // Check if the notification is for admin
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              _hasUnreadNotifications
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_rounded,
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
        title: Text(
          'Jom Eat',
          style: GoogleFonts.bungeeSpice(fontSize: 24.0, letterSpacing: 1.0),
        ),
        leading: Image.asset('assets/images/logo.png'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          HomePanel(userId: widget.userId),
          FeedbackPanel(),
          ReportsPanel(),
          ProfilePanel(userId: widget.userId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_rounded),
            label: 'Feedbacks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
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
