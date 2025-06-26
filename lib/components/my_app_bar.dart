import 'package:flutter/material.dart';
import 'package:tracker/theme/switchButton.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  const MyAppBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        text,
        style: TextStyle(
          color: Colors.blue,
          fontSize: 25,
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue,
          decorationThickness: 2,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      actions: [ThemeSwitchButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
