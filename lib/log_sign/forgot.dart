import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker/components/dialog_box.dart';
import 'package:tracker/theme/stchBtn.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = TextEditingController();

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

  Reset() async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
      showDialog(context: context, builder: (context){
        return DialogBox(message: 'Email has been sent, please check your mail',);
      });
    } catch (e) {
      String errorMessage = "An unknown error has occured";
      if(e is FirebaseAuthException){
        errorMessage = getFireBasedErrorMessage(e.code);
      } else {
        errorMessage = e.toString();
      }
      showDialog(context: context, builder: (context){
        return DialogBox(message: errorMessage,);
      });
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
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
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
                      SizedBox(height: 20),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: (() => Reset()),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Send Link'),
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
