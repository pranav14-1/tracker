import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tracker/components/dialog_box.dart';
import 'package:tracker/log_sign/forgot.dart';
import 'package:tracker/theme/stchBtn.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FocusNode _passwordNode = FocusNode();

  bool _obscurePassword = true;
  bool _isPasswordFocused = false;

  Future<void> googleLogin() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // user cancelled login
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    // Navigate after successful login
    Get.offAllNamed('/home');
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => DialogBox(
        message: "Google Sign-In failed: ${e.toString()}",
      ),
    );
  }
}


  @override
  void initState() {
    super.initState();
    _passwordNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  String getFireBasedErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'invalid-authentication':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password. Please try again.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }


  Future<void> Goto() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      String errorMessage = 'An unknown error occurred';
      if (e is FirebaseAuthException) {
        errorMessage = getFireBasedErrorMessage(e.code);
      } else {
        errorMessage = e.toString();
      }
      if (password.text == '') errorMessage = "Please enter the password";
      showDialog(
        context: context,
        builder: (context) => DialogBox(message: errorMessage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(top: 10, right: 10, child: ThemeSwitchButton()),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Greeting
                      Text(
                        'Hello!!',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Welcome Back...',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: password,
                        focusNode: _passwordNode,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon:
                              _isPasswordFocused
                                  ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  )
                                  : null,
                        ),
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.to(ForgotPassword()),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                            ),
                          ),
                        ),
                      ),

                      // Log-In Button
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: Goto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text(
                            'Log-In',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),

                      const Divider(thickness: 2, height: 80),
                      const SizedBox(height: 10),

                      // Google Login Button
                      ElevatedButton(
                        onPressed: (()=>googleLogin()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/g_logo.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Instagram Login Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/ig_logo.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Continue with Instagram',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),

                      // Sign-Up Navigation
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'No Account?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/signup',
                                );
                              },
                              child: const Text(
                                'Sign-Up',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
