import 'package:flutter/material.dart';
import 'package:tracker/pages/screens/community.dart';
import 'package:tracker/pages/screens/home_ativity.dart';
import 'package:tracker/pages/screens/leaderborad.dart';
import 'package:tracker/pages/screens/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    HomeAtivity(),
    Leaderborad(),
    CommunityPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   title: Text(
        //     'TRACKER',
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontSize: 25,
        //       decoration: TextDecoration.underline,
        //       decorationColor: Colors.blue,
        //       decorationThickness: 2,
        //     ),
        //   ),
        //   elevation: 1,
        //   shadowColor: Colors.grey[400],
        //   centerTitle: true,
        //   // backgroundColor: Colors.white,
        // ),
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: (index) async {
            await Future.delayed(Duration(milliseconds: 250));
            setState(() {
              selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              label: 'leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'profile',
            ),
          ],
          // backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.blueGrey,
        ),
      ),
    );
  }
}
