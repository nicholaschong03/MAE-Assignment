import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/Loginpage/forgetpassword.dart';
import 'package:jom_eat_project/Loginpage/signup.dart';
import '../adminpage GUI/admin_main.dart';
import '../common function/user_services.dart'; // Import UserService

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

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
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

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

    try {
      Map<String, dynamic> userData = await UserData(userId: userId).getUserData();
      String userRole = userData['role'];
      bool isSuspended = userData['isSuspended'];

      if (userRole == 'foodie' && !isSuspended) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => FoodiePage(userId: userId, role: userRole)),
        // );
      } else if (userRole == 'admin' && !isSuspended) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AdminPage(userId: userId, role: userRole)),
        );
      } else if (userRole == 'cc' && !isSuspended) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => ContentCreatorPage(userId: userId, role: userRole)),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unknown User or Suspended User'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to retrieve user data.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color:Color.fromARGB(255, 255, 234, 211),
        ),
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            key: const Key('scrollable'),
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
                    errorText:
                        _isEmailValid ? null : 'Please enter a valid email',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16.0),
                // Password TextField
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
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
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
                      child: Text(
                        'Forget Password',
                        style: GoogleFonts.georama(
                            color: const Color(0xFFF35000),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Login Button
                    ElevatedButton(
                      onPressed: _validateInputs,
                      child: Text(
                        'Login',
                        style: GoogleFonts.georama(
                          color: const Color(0xFFF35000),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        'First time here? Sign up now',
                        style: GoogleFonts.georama(
                            color: const Color(0xFFF35000),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500),
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
