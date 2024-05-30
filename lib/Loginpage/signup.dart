import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
                'Sign up as a new user', // Changed title
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
            const SizedBox(height: 16.0), // Add space between text fields
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
            const SizedBox(height: 16.0), // Add space between text fields
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
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
            const SizedBox(height: 16.0), // Add space between text fields
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(
                  color: Colors.orange,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Perform sign up logic here
                  String name = _nameController.text;
                  String username = _usernameController.text;
                  String email = _emailController.text;
                  String password = _passwordController.text;

                  // Validate and process the user input
                  // ...

                  // Clear the text fields
                  _nameController.clear();
                  _usernameController.clear();
                  _emailController.clear();
                  _passwordController.clear();
                },
                child: const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
