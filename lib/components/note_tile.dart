import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoteTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  final int? totalDuration;
  const NoteTile({
    super.key,
    required this.isCompleted,
    required this.text,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
    this.totalDuration,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            // edit option
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(8),
            ),
            // delete option
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            ),
            //counter
            // SlidableAction(
            //   onPressed:setCounter,
            //   backgroundColor: Colors.grey.shade800,
            //   icon:Icons.timelapse,
            //   borderRadius: BorderRadius.circular(8),
            // )
          ],
        ),
        startActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: editHabit,
              icon: Icons.plus_one,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        // habit tile
        child: GestureDetector(
          onTap: () {
            if (onChanged != null) {
              // toggle completion status
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? Colors.blue
                      : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              // text
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color:
                          isCompleted
                              ? Colors.white
                              : Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 16,
                    ),
                  ),

                  //Show timer if it's set
                  if (totalDuration != null)
                    Text(
                      "${totalDuration! ~/ 60} min timer",
                      style: TextStyle(
                        color: isCompleted ? Colors.white70 : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),

              // checkbox
              leading: Checkbox(
                activeColor: Colors.blue,
                value: isCompleted,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
