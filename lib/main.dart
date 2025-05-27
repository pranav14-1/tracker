import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/pages/login.dart';
import 'package:tracker/pages/navbarsetup.dart';
import 'package:tracker/pages/signup.dart';
import 'package:tracker/theme/darkMode.dart';
import 'package:tracker/theme/lightMode.dart';
import 'package:tracker/theme/themeSwitch.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeSwitch(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeSwitch>(context).themeData,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LogIn(),
        '/signup': (context) => SignUp(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
