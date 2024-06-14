import 'package:flutter/material.dart';
import 'foodie_home_screen.dart';
import 'create_outing_screen.dart';
import 'feed_post_screen.dart';
import 'foodie_profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String userId;

  const MainScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      FoodieHomeScreen(userId: widget.userId),
      CreateOutingScreen(userId: widget.userId),
      FeedPostScreen(),
      FoodieProfileScreen(userId: widget.userId,),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.orange, // Set the background color to orange
        selectedItemColor: Color.fromARGB(255, 255, 109, 24), // Set the selected item color to white
        unselectedItemColor: Colors.black54, // Set the unselected item color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
