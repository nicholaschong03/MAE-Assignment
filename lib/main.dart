import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jom_eat_project/Loginpage/login.dart';
import 'package:jom_eat_project/foodie/screens/create_outing_screen.dart';
import 'package:jom_eat_project/foodie/screens/feed_post_screen.dart';
import 'package:jom_eat_project/foodie/screens/foodie_home_screen.dart';
import 'package:jom_eat_project/foodie/screens/foodie_profile_screen.dart';
import 'package:jom_eat_project/foodie/screens/main_screen.dart';
import 'package:jom_eat_project/foodie/screens/outing_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      // home: FeedPostScreen(), // Display Login Page
      // home: FoodieHomeScreen(userId: 'AZwrBrL0xBcNKOkdqdDBvBMWRyJ3',), // Display Login Page
      // home: OutingProfileScreen(outingId: 'UYjyFsOxnhbucHWSmRU7', userId: 'rZrqSqsQBccEoMWKmLjf',), // Display Login Page
      //  home: CreateOutingScreen(), // Display Login Page
      // home: MainScreen(userId: 'AZwrBrL0xBcNKOkdqdDBvBMWRyJ3',),
      home: LoginPage(),
      // home: FoodieProfileScreen(userId: "AZwrBrL0xBcNKOkdqdDBvBMWRyJ3",)
    );
  }
}