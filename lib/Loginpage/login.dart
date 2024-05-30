import 'package:flutter/material.dart';
import 'package:jom_eat_project/Loginpage/forgetpassword.dart';
import 'package:jom_eat_project/Loginpage/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            // Username TextField
            const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                labelStyle: TextStyle(
                  color: Colors.orange,
                ),
                fillColor: Color.fromARGB(255, 255, 255, 255),
                filled: true,
              ),
            ),
            const SizedBox(height: 16.0),
            // Password TextField
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                labelStyle: TextStyle(
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
                    // Implement forget password functionality
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
