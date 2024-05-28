import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jom Eat'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
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
            // Forget Password
            TextButton(
              onPressed: () {
                // TODO: Implement forget password functionality
              },
              child: Text('Forget Password'),
            ),
            const SizedBox(height: 16.0),
            // Sign Up
            TextButton(
              onPressed: () {
                // TODO: Implement sign up functionality
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
