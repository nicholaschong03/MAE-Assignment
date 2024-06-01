import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_eat_project/Loginpage/forgetpassword.dart';
import 'package:jom_eat_project/Loginpage/signup.dart';
import '../adminpage/adminpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  void _validateInputs() {
    setState(() {
      _isEmailValid = _emailController.text.isNotEmpty;
      _isPasswordValid = _passwordController.text.isNotEmpty;
    });

    if (_isEmailValid && _isPasswordValid) {
      _loginUser();
    }
  }

  Future<void> _loginUser() async {
    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if email is verified
      if (userCredential.user?.emailVerified ?? false) {
        _redirectToPageBasedOnRole(userCredential.user?.uid);
      } else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please verify your email to log in.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Login failed: Your email or password is not correct'),
      ));
    }
  }

  Future<void> _redirectToPageBasedOnRole(String? userId) async {
    if (userId == null) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String userRole = userDoc.get('role');

    if (userRole == 'foodie') {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => FoodiePage()),
      // );
    } else if (userRole == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else if (userRole == 'cc') {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => ContentCreatorPage()),
      // );
    } else {
      // Handle unknown user role
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unknown User'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 234, 207),
        ),
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16.0),
            // Email TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _isEmailValid ? null : 'Please enter a valid email',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                labelStyle: const TextStyle(
                  color: Colors.orange,
                ),
                fillColor: Color.fromARGB(255, 255, 255, 255),
                filled: true,
              ),
            ),
            const SizedBox(height: 16.0),
            // Password TextField
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText:
                    _isPasswordValid ? null : 'Please enter a valid password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                labelStyle: const TextStyle(
                  color: Colors.orange,
                ),
                fillColor: Color.fromARGB(255, 255, 255, 255),
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            // Row containing Forget Password and Login buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Forget Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgetPasswordPage()),
                    );
                  },
                  child: const Text('Forget Password'),
                ),
                // Login Button
                ElevatedButton(
                  onPressed: _validateInputs,
                  child: const Text('Login'),
                ),
              ],
            ),
            // Row containing Sign Up button aligned to the left
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: const Text('First time here? Sign up now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
