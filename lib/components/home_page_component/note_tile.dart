import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tracker/components/home_page_component/note_without_timer.dart';
import 'package:tracker/components/home_page_component/note_with_timer.dart';

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
  // Creating key to use child functions of the timer
  final GlobalKey<MyTimerState> childKey = GlobalKey<MyTimerState>();

  Duration remainingDuration = Duration.zero;
  int passedSeconds = 0;
  bool isRunning = false;
  bool isPaused = false;
  Duration _elapsed = Duration.zero;

  void _startTimer() {
    setState(() {
      isRunning = true;
      isPaused = false;
    });
    // childKey.currentState?.startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      childKey.currentState?.startTimer();
    });
  }

  void _pauseTimer() {
    childKey.currentState?.pauseTimer();
    setState(() {
      isPaused = true;
      isRunning = false;
    });
  }

  void _stopTimer() {
    childKey.currentState?.stopTimer();
    setState(() {
      isRunning = false;
      isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        startActionPane:
            widget.isCompleted == false
                ? ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    if (!isRunning)
                      SlidableAction(
                        onPressed: (_) => _startTimer(),
                        icon: Icons.play_circle_fill,
                        backgroundColor: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    if (isRunning)
                      SlidableAction(
                        onPressed: (_) => _pauseTimer(),
                        icon: Icons.pause_circle_filled,
                        backgroundColor: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    if (isRunning || isPaused)
                      SlidableAction(
                        onPressed: (_) => _stopTimer(),
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
                if (isRunning || isPaused) {
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
                if (isRunning || isPaused) {
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
            isRunning || isPaused
                // if it is timer function then run the timer
                ? MyTimer(key: childKey)
                // Normal
                : NoteWithoutTimer(
                  totalDuration: widget.totalDuration,
                  isPaused: isPaused,
                  isRunning: isRunning,
                  onChanged: widget.onChanged,
                  isCompleted: widget.isCompleted,
                  text: widget.text,
                  passedSeconds: passedSeconds,
                  toggleFavorite: widget.toggleFavorite,
                  isRenewable: widget.isRenewable,
                  elapsed: _elapsed,
                ),
      ),
    );
  }
}
