import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/components/login_component/password_login.dart';
import 'package:tracker/theme/switchButton.dart';
import 'package:tracker/firebase/log_sign/auth.dart';
import '../../components/dialog_box.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FocusNode _passwordNode = FocusNode();
  final TextEditingController retypePassword = TextEditingController();
  final FocusNode _retypePasswordNode = FocusNode();
  final TextEditingController username = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _passwordNode.dispose();
    retypePassword.dispose();
    username.dispose();
    _retypePasswordNode.dispose();
    super.dispose();
  }

  bool passwordConfirmed() {
    return password.text.trim() == retypePassword.text.trim();
  }

  Future<void> Goto() async {
    if (passwordConfirmed()) {
      try {
        await AuthService.signUpWithEmail(email.text.trim(), password.text.trim(), username.text.trim());
        Get.toNamed('/home');
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => DialogBox(message: e.toString()),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return DialogBox(message: 'Passwords do not match in both fields');
        },
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
                      const Text(
                        'Hello!!',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Get Started...',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextField(
                        controller: username,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'Email ID',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      PasswordLogin(
                        password: password,
                        passwordNode: _passwordNode,
                        labelledText: 'Password',
                      ),
                      const SizedBox(height: 20),

                      // Re-type Password Field
                      PasswordLogin(
                        password: retypePassword,
                        passwordNode: _retypePasswordNode,
                        labelledText: 'Re-type Password',
                      ),
                      const SizedBox(height: 10),

                      // Navigation to Login
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Have Account?',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: const Text(
                                'Log-In',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sign-Up Button
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: Goto,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Sign-Up'),
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
