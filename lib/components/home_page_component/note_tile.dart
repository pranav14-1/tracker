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

class _NoteTileState extends State<NoteTile>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  TimerState timerState = TimerState.stopped;
  Duration remainingDuration = Duration.zero;
  int passedSeconds = 0;
  bool isRunning = false;
  bool isPaused = false;
  Duration _elapsed = Duration.zero;
  late Ticker _ticker; // Changed to nullable

  // This is to make sure that the controller gets the new value every time when the timer runs or gets over
  @override
  void didUpdateWidget(NoteTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.totalDuration != oldWidget.totalDuration &&
        widget.totalDuration != null) {
      // Update controller duration
      animationController.duration = Duration(seconds: widget.totalDuration!);

      // Reset timer state
      if (timerState != TimerState.stopped) {
        _stopTimer();
      }
      remainingDuration = Duration(seconds: widget.totalDuration!);
    }
  }


  @override
  void initState() {
    super.initState();

    if (widget.totalDuration != null) {
      // Initialize for countdown mode
      animationController =
          AnimationController(
              vsync: this,
              duration: Duration(seconds: widget.totalDuration!),
            )
            ..addListener(
              () => setState(() {
                remainingDuration =
                    Duration(seconds: widget.totalDuration!) *
                    (1 - animationController.value);
              }),
            )
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                _stopTimer();
                if (widget.onChanged != null && !widget.isCompleted) {
                  widget.onChanged!(true);
                }
              }
            });
    } else {
      // Initialize for counter mode
      _ticker = Ticker((elapsed) {
        setState(() {
          _elapsed = elapsed;
          passedSeconds = elapsed.inSeconds;
        });
      });
    }
  }

  void _startTimer() {
    if (widget.totalDuration != null) {
      // Countdown mode
      if (timerState == TimerState.stopped) {
        animationController.forward(from: 0);
      } else if (timerState == TimerState.paused) {
        animationController.forward();
      }
    } else {
      // Counter mode
      _ticker.start();
    }
    setState(() {
      timerState = TimerState.running;
      isRunning = true;
      isPaused = false;
    });
  }

  void _pauseTimer() {
    if (widget.totalDuration != null) {
      animationController.stop();
    } else {
      _ticker.stop();
    }
    setState(() {
      timerState = TimerState.paused;
      isRunning = false;
      isPaused = true;
    });
  }

  void _stopTimer() {
    if (widget.totalDuration != null) {
      animationController.reset();
      if (widget.totalDuration != null) {
        remainingDuration = Duration(seconds: widget.totalDuration!);
      }
    } else {
      _ticker.stop();
      _elapsed = Duration.zero;
      passedSeconds = 0;
    }
    setState(() {
      timerState = TimerState.stopped;
      isPaused = false;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    if (widget.totalDuration != null) {
      animationController.dispose();
    } else {
      _ticker.dispose();
    }
    super.dispose();
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
                ? MyTimer(
                  animationController: animationController,
                  editHabit: widget.editHabit,
                  deleteHabit: widget.deleteHabit,
                  isCompleted: widget.isCompleted,
                  duration: Duration(minutes: 15),
                  isPaused: isPaused,
                  isRunning: isRunning,
                  startTimer: _startTimer,
                  pauseTimer: _pauseTimer,
                  stopTimer: _stopTimer,
                  remainingDuration: remainingDuration,
                )
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

enum TimerState { stopped, running, paused }
