import 'package:flutter/material.dart';

import 'package:jom_eat_project/Loginpage/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/common%20function/verification.dart';
import 'package:jom_eat_project/common%20function/user_services.dart';
import 'package:jom_eat_project/common%20function/notification.dart'; // Import the NotificationService

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  String? _selectedRole = 'foodie'; // Default role identifier

  final Map<String, String> roleMap = {
    'Foodie': 'foodie',
    'Content Creator': 'cc',
  };

  void _validateInputs() {
    setState(() {
      _isEmailValid = verifyEmail(_emailController.text);
      _isPasswordValid = verifyPassword(_passwordController.text);
    });

    if (_isEmailValid && _isPasswordValid) {
      _signUpUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Password must be at least 8 characters, include 1 uppercase, 1 number, and 1 special character (!@#\$%^&*)'),
        ),
      );
    }
  }

  Future<void> _signUpUser() async {
    try {
      await UserData.signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        username: _usernameController.text,
        role: _selectedRole!,
      );


      // Send notification to admin
      final NotificationService notificationService = NotificationService();
      await notificationService.sendNotification(
        'New User Signup',
        'A new user has signed up as ${_selectedRole == 'cc' ? 'Content Creator' : 'Foodie'}.',
        'system', // or any identifier for the system
        role: 'admin', // targeting admin role
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Sign up successful! Please check your email to verify your account.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Sign up failed: The email had already been used, If you can't remember the password, kindly reset the password"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up as a New User',
          style: GoogleFonts.georama(fontSize: 24.0, letterSpacing: 0.5),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 234, 207),
        ),
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            key: const Key('scrollable'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please fill in the details below',
                    style: GoogleFonts.georama(
                      color: const Color(0xFFF35000),
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText:
                        _isEmailValid ? null : 'Please enter a valid email',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: const TextStyle(
                      color: Color(0xFFF88232),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _isPasswordValid
                        ? null
                        : 'Please enter a valid password',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: const TextStyle(
                      color: Color(0xFFF88232),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      color: Color(0xFFF88232),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      color: Color(0xFFF88232),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: roleMap.entries
                            .firstWhere((entry) => entry.value == _selectedRole)
                            .key,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = roleMap[newValue];
                          });
                        },
                        items: roleMap.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        style: const TextStyle(
                          color: Color(0xFFF88232),
                        ),
                        dropdownColor: Colors.white,
                        icon: const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Color(0xFFF88232),
                          size: 30,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Select Role',
                          labelStyle: TextStyle(
                            color: Color(0xFFF88232),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _validateInputs,
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.georama(
                            color: const Color(0xFFF35000),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
