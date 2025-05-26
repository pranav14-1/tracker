import 'package:flutter/material.dart';

class Tasks extends StatelessWidget {
  final String taskname;
  final bool taskcompleted;
  Function(bool?)? onChanged;

  Tasks({
    super.key,
    required this.taskname,
    required this.onChanged,
    required this.taskcompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Checkbox(
              value: taskcompleted,
              onChanged: onChanged,
              activeColor: Colors.white,
              checkColor: Colors.black,
              side: BorderSide(color: Colors.black, width: 2),
            ),
            Text(
              taskname,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                decoration:
                    taskcompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                decorationColor: Colors.black,
                decorationThickness: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
