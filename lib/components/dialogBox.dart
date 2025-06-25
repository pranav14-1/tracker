import 'package:flutter/material.dart';

class TaskDialog extends StatelessWidget {
  final noteController;
  final durationController;
  VoidCallback onAdd;
  VoidCallback onCancel;
  final String onAddText;

  TaskDialog({
    super.key,
    required this.noteController,
    required this.durationController,
    required this.onAdd,
    required this.onCancel,
    required this.onAddText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue,
      content: SizedBox(
        height: 200,
        child: Column(
          children: [
            TextField(
              controller: noteController,
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
            SizedBox(height: 15),
            // Duration input
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Duration (in minutes)',
                hintStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                    child: Text(onAddText, style: TextStyle(fontSize: 15)),
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
