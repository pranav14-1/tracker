import 'package:flutter/material.dart';

class TaskDialog extends StatelessWidget {
  final controller;
  VoidCallback onAdd;
  VoidCallback onCancel;

  TaskDialog({
    super.key,
    required this.controller,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue,
      content: Container(
        height: 120,
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'New Task',
                hintStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  // borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            Spacer(),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 15)),
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Add', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
