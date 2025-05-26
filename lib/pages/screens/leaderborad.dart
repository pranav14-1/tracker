import 'package:flutter/material.dart';

class Leaderborad extends StatelessWidget {
  const Leaderborad({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Text('leaderboard page'),
          ),
        )),
    );
  }
}