import 'package:flutter/material.dart';
import 'package:tracker/pages/screens/community.dart';
import 'package:tracker/pages/screens/home_activity.dart';
import 'package:tracker/pages/screens/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;
  final List<Widget> pages = [CommunityPage(), HomeActivity(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: (index) async {
            await Future.delayed(Duration(milliseconds: 200));
            setState(() {
              selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'home',
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
