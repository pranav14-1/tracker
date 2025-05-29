import 'package:flutter/material.dart';

class Leaderborad extends StatelessWidget {
  const Leaderborad({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Leaderboard')],
            ),
          ),
        ),
      ),
    );
  }
}
