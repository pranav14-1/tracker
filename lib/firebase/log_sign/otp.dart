import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // ✅ Ensure this is imported
import 'package:pinput/pinput.dart';
import 'package:tracker/firebase/log_sign/login.dart';

class OtpScreen extends StatefulWidget {
  final String vid;
  final String phonenum;
  const OtpScreen({super.key, required this.vid, required this.phonenum});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String code = ''; 

  Future<void> signIn() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.vid,
      smsCode: code,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
        Get.offAll(() => LogIn()); 
      });
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Unknown error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              'Enter OTP',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'OTP sent to ${widget.phonenum}',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Center(
            child: Pinput(
              length: 6,
              onChanged: (value) {
                setState(() {
                  code = value;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                signIn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Verify Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
