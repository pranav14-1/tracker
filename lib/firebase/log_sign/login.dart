import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/firebase/log_sign/auth.dart';
import 'package:tracker/components/dialog_box.dart';
import 'package:tracker/firebase/log_sign/forgot.dart';
import 'package:tracker/theme/switchButton.dart';

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

  Future<void> Goto() async {
    try {
      await AuthService.loginWithEmail(email.text, password.text);
      Get.offAllNamed('/home', arguments: FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      String errorMessage = 'Authentication failed';
      if (e is FirebaseAuthException) {
        errorMessage = getFireBasedErrorMessage(e.code);
      }
      if (password.text == '') errorMessage = "Please enter the password";
      showDialog(
        context: context,
        builder: (context) => DialogBox(message: errorMessage),
      );
    }
  }

  Future<void> googleLogin() async {
    try {
      final credential = await AuthService.loginWithGoogle();
      if (credential == null) return;
      Get.offAllNamed('/home', arguments: credential.user!.uid);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => DialogBox(message: "Google Sign-In failed: ${e.toString()}"),
      );
    }
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
                      Text('Hello!!', style: TextStyle(color: Colors.blue, fontSize: 25, fontWeight: FontWeight.bold)),
                      Text('Welcome Back...', style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: password,
                        focusNode: _passwordNode,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          suffixIcon: _isPasswordFocused
                              ? IconButton(
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                )
                              : null,
                        ),
                      ),
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
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: Goto,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Log-In', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const Divider(thickness: 2, height: 80),
                      ElevatedButton(
                        onPressed: googleLogin,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/g_logo.png', height: 20, width: 20),
                            const SizedBox(width: 10),
                            const Text('Continue with Google', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/phone.png', height: 20, width: 20),
                            const SizedBox(width: 10),
                            const Text('Continue with Phone Number', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No Account?', style: TextStyle(color: Colors.blue, fontSize: 15)),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                              child: const Text('Sign-Up',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                  )),
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
