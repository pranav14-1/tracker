import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/firebase/log_sign/redirect.dart';
import 'package:tracker/firebase/log_sign/login.dart';
import 'package:tracker/pages/navbarsetup.dart';
import 'package:tracker/firebase/log_sign/signup.dart';
// import 'package:tracker/theme/darkMode.dart';
// import 'package:tracker/theme/lightMode.dart';
import 'package:tracker/theme/themeSwitch.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeSwitch()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeSwitch>(context).themeData,
      home: Redirect(),
      routes: {
        '/login': (context) => LogIn(),
        '/signup': (context) => SignUp(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
