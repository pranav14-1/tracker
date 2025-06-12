import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/firebase/log_sign/auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
            decorationThickness: 2,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current User:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              user?.phoneNumber?? user?.email?? 'No user info found',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                Get.offAllNamed('/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
