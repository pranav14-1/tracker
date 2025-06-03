import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/components/password_login.dart';
import 'package:tracker/features/redirect.dart';
import 'package:tracker/pages/navbarsetup.dart';
import 'package:tracker/theme/stchBtn.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/dialog_box.dart';

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


  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _passwordNode.dispose();
    super.dispose();
  }
  


  Future<void> Goto() async {
    if(passwordConfirmed()){
      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
        );
        Get.toNamed('/home');
      }
      catch (e) {
        String errorMessage = 'An unknown error occurred';
        if (e is FirebaseAuthException) {
          errorMessage = e.message ?? 'An unknown error occurred';
        } else {
          errorMessage = e.toString();
        }
        showDialog(
          context: context,
          builder: (context) => DialogBox(message: errorMessage),
        );
      }
    }
    else{
      showDialog(context:  context
      , builder: (context) {
        return DialogBox(message: 'Passwords do no match in both fields');
      });
    }
    // Get.offAll(Redirect());
  }

  bool passwordConfirmed(){
    if(password.text.trim() == retypePassword.text.trim()){
      return true;
    }
    else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 10,
              right: 10,
              child: ThemeSwitchButton(),
            ),
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
                          fontSize: 25,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
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
