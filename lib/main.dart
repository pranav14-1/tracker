import 'package:flutter/material.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/pages/home.dart';
import 'package:tracker/pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LogIn(),
        '/signup': (context) => SignUp(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
