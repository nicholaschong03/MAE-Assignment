import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jom_eat_project/adminfunction/event_manage.dart';
import 'package:jom_eat_project/adminfunction/user_manage.dart';
import '../common function/notification.dart';
import 'home.dart';
import 'profile.dart';
import 'feedbackpage.dart';
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

  void _navigateToUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserManagementPage()),
    );
  }

  void _navigateToEventManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventManagePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 234, 211),
        actions: [
          IconButton(
            icon: Icon(
              _hasUnreadNotifications
                  ? Iconsax.notification_bing5
                  : Iconsax.notification5,
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
          IconButton(
            icon: const Icon(Iconsax.user_edit4),
            onPressed: _navigateToUserManagement,
            color: const Color(0xFFF88232),
          ),
          IconButton(
            icon: const Icon(Iconsax.menu_board5),
            onPressed: _navigateToEventManagement,
            color: const Color(0xFFF88232),
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
        children: <Widget>[
          HomePanel(),
          const FeedbackPanel(),
          const ReportsPanel(),
          ProfilePanel(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
        icon: Icon(Iconsax.home),
        label: 'Home',
          ),
          BottomNavigationBarItem(
        icon: Icon(Iconsax.notification_status),
        label: 'Feedbacks',
          ),
          BottomNavigationBarItem(
        icon: Icon(Iconsax.health),
        label: 'Reports',
          ),
          BottomNavigationBarItem(
        icon: Icon(Iconsax.user),
        label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFF88232),
        unselectedItemColor: Color.fromARGB(190, 49, 49, 49),
        selectedLabelStyle: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.lato(fontSize: 12),
        onTap: _onItemTapped,
        backgroundColor: Color.fromARGB(255, 255, 234, 211),
      ),
    );
  }
}
