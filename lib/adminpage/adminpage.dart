import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification.dart';
import 'home.dart';
import 'profile.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  // Creates the state for the AdminPage widget.
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
        .where('to',
            isEqualTo: 'admin') // Check if the notification is for admin
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
              color: _hasUnreadNotifications ? Colors.orange : Colors.grey,
            ),
            onPressed: () {
              // show notifications page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              ).then((value) =>
                  _checkForUnreadNotifications()); // Recheck for unread notifications when returning
            },
          ),
        ],
        title: const Text('JomEat'),
        leading: Image.asset('assets/images/logo.png'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children:  <Widget>[
          HomePanel(),
          SettingPanel(),
          ReportsPanel(),
          ProfilePanel(),
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
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
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
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}



class SettingPanel extends StatelessWidget {
  const SettingPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Panel'),
    );
  }
}

class ReportsPanel extends StatelessWidget {
  const ReportsPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports Panel'),
    );
  }
}