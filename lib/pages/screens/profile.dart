import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/components/my_app_bar.dart';
import 'package:tracker/firebase/log_sign/auth.dart';
import 'package:tracker/components/home_page_component/note_with_timer.dart';
import 'package:tracker/testing_services/test_timer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;



    return Scaffold(
      appBar: MyAppBar(text: "Profile"),
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
              user?.phoneNumber ?? user?.email ?? 'No user info found',
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
            const SizedBox(height: 20),
            Container(child: Text("Select Theme Colour")),
            RectangularTimer(duration: Duration(seconds: 15),),
          ],
        ),
      ),
    );
  }
}
