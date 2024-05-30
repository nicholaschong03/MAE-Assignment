import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ForgetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
      ),
      backgroundColor: const Color.fromARGB(
          255, 255, 234, 207), // Sets the background color to blue
      body: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter your email to reset your password',
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.orange), // Set the font color to orange
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement password reset logic
                },
                child: const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
