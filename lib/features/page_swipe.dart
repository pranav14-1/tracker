import 'package:flutter/material.dart';
import 'package:tracker/pages/screens/community.dart';
import 'package:tracker/pages/screens/home_activity.dart';
import 'package:tracker/pages/screens/profile.dart';

class MyPageSwipe extends StatefulWidget {
  const MyPageSwipe({super.key});

  @override
  State<MyPageSwipe> createState() => _MyPageSwipeState();
}

class _MyPageSwipeState extends State<MyPageSwipe> {
  final PageController _controller = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        
        children: [CommunityPage(), HomeAtivity(), ProfilePage()],
      ),
    );
  }
}
