import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jom Eat'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange,
              Colors.white54,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16.0),
            // Username TextField
            const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            // Password TextField
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
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
                    // TODO: Implement forget password functionality
                  },
                  child: const Text('Forget Password'),
                ),
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement login functionality
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
            // Row containing Sign Up button aligned to the left
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Implement sign up functionality
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
