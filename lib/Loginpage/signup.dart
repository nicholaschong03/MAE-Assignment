import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void _validateInputs() {
    setState(() {
      _isEmailValid = _emailController.text.isNotEmpty;
      _isPasswordValid = _passwordController.text.isNotEmpty;
    });

    if (_isEmailValid && _isPasswordValid) {
      _signUpUser();
    }
  }

  Future<void> _signUpUser() async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'email': _emailController.text,
        'role': 'foodie', // Default role, you can change it based on your logic
        'name': _nameController.text,
        'username': _usernameController.text,
      });

      // Redirect to specific page based on role
      _redirectToPageBasedOnRole(userCredential.user?.uid);
    } catch (e) {
      print('Failed to sign up: $e');
      // Handle error (e.g., show a Snackbar)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign up failed: $e'),
      ));
    }
  }

  Future<void> _redirectToPageBasedOnRole(String? userId) async {
    if (userId == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String userRole = userDoc.get('role');

    if (userRole == 'admin') {
      Navigator.pushReplacementNamed(context, '/adminPage');
    } else {
      Navigator.pushReplacementNamed(context, '/userPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 234, 207),
        ),
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sign up as a new user',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 28.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 133, 133, 133),
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _isEmailValid ? null : 'Please enter a valid email',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                filled: true,
                fillColor: Colors.white,
                labelStyle: const TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _isPasswordValid ? null : 'Please enter a valid password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                filled: true,
                fillColor: Colors.white,
                labelStyle: const TextStyle(
                  color: Colors.orange,
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
                  color: Colors.orange,
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
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _validateInputs,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
