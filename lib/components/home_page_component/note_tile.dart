import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tracker/components/home_page_component/note_without_timer.dart';
import 'package:tracker/components/home_page_component/note_with_timer.dart';
import 'package:tracker/features/timer%20provider/timer_provider.dart';

class NoteTile extends StatefulWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  final int? totalDuration; // in seconds
  final void Function(BuildContext)? toggleTimer;
  final ValueNotifier<bool>? anyTimerRunningNotifier;
  final void Function()? toggleFavorite;
  final bool isRenewable;

  const NoteTile({
    super.key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
    this.totalDuration,
    this.toggleTimer,
    this.anyTimerRunningNotifier,
    required this.toggleFavorite,
    required this.isRenewable,
  });

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {

  Duration remainingDuration = Duration.zero;
  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        startActionPane:
            widget.isCompleted == false
                ? ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    if (!timer.isRunning)
                      SlidableAction(
                        onPressed: (_) => timer.start(),
                        icon: Icons.play_circle_fill,
                        backgroundColor: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    if (timer.isRunning)
                      SlidableAction(
                        onPressed: (_) => timer.pause(),
                        icon: Icons.pause_circle_filled,
                        backgroundColor: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    if (timer.isRunning || timer.isPaused)
                      SlidableAction(
                        onPressed: (_) => timer.stop(),
                        icon: Icons.stop_circle,
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                  ],
                )
                : null,
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              //edit task
              onPressed: (_) {
                if (timer.isRunning || timer.isPaused) {
                  //show toast while running
                  Fluttertoast.showToast(
                    msg: "Cannot edit a task while the timer is running",
                    gravity: ToastGravity.BOTTOM,
                  );
                } else if (widget.isCompleted) {
                  //show toast for completed task
                  Fluttertoast.showToast(
                    msg: "You cannot edit a completed task",
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  widget.editHabit?.call(context);
                }
              },
              backgroundColor: Colors.grey.shade800,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(8),
            ),
            SlidableAction(
              //delete task
              onPressed: (_) {
                if (timer.isRunning || timer.isPaused) {
                  //show toast while running
                  Fluttertoast.showToast(
                    msg: "Cannot delete a task while the timer is running",
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  widget.deleteHabit?.call(context);
                }
              },
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: 
                // if it is timer function then run the timer
                timer.isPaused || timer.isRunning
                ? MyTimer(
                  onPause : timer.pause,
                  onStop : timer.stop,
                  isCompleted: widget.isCompleted,
                  onChanged: widget.onChanged,
                )
                // Normal
                : NoteWithoutTimer(
                  totalDuration: widget.totalDuration,
                  isPaused: timer.isPaused,
                  isRunning: timer.isRunning,
                  onChanged: widget.onChanged,
                  isCompleted: widget.isCompleted,
                  text: widget.text,
                  toggleFavorite: widget.toggleFavorite,
                  isRenewable: widget.isRenewable,
                ),
      ),
    );
  }
}
