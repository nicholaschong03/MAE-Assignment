import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jom_eat_project/Loginpage/login.dart';
import 'package:jom_eat_project/foodie/screens/foodie_home_screen.dart';
import 'package:jom_eat_project/foodie/screens/foodie_profile_screen.dart';
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
    return const MaterialApp(
      home: LoginPage(), // Display Login Page
    );
  }
}