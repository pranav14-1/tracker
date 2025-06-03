import 'package:flutter/material.dart';
import 'package:tracker/components/my_button.dart';

class DialogBox extends StatelessWidget {
  final String message;
  const DialogBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: Container(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(message,),
            
            MyButton(text: 'OK'
            ,onPressed: () => Navigator.of(context).pop())
          ],
        ),
        
      )
    );
  }
}