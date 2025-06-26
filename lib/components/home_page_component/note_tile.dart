import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  Timer? _timer;
  int passedSeconds = 0;
  bool isRunning = false;
  bool isPaused = false;

  Duration _elapsed = Duration.zero;
  Duration _pausedDuration = Duration.zero;
  Stopwatch stopwatch = Stopwatch();

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    stopwatch
      ..reset()
      ..start();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = _pausedDuration + stopwatch.elapsed;

        //Countdown mode: check if time is up
        if (widget.totalDuration != null &&
            _elapsed.inSeconds >= widget.totalDuration!) {
          _stopTimer();

          //auto-complete if timer finished
          if (widget.onChanged != null && widget.isCompleted == false) {
            widget.onChanged!(true);
          }
        }

        //Counter-update passedSeconds
        if (widget.totalDuration == null) {
          passedSeconds = _elapsed.inSeconds;
        }
      });
    });

    setState(() {
      isRunning = true;
      isPaused = false;
      widget.anyTimerRunningNotifier?.value = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    stopwatch.stop();
    setState(() {
      _pausedDuration += stopwatch.elapsed;
      isRunning = false;
      isPaused = true;
      widget.anyTimerRunningNotifier?.value = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    stopwatch
      ..stop()
      ..reset();
    setState(() {
      _pausedDuration = Duration.zero;
      _elapsed = Duration.zero;
      isPaused = false;
      isRunning = false;
      widget.anyTimerRunningNotifier?.value = false;
    });
    //mark the task as completed if counter stopped
    if (widget.totalDuration == null &&
        widget.onChanged != null &&
        widget.isCompleted == false) {
      widget.onChanged!(true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCountDown = widget.totalDuration != null;
    final remaining = (widget.totalDuration ?? 0) - _elapsed.inSeconds;

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
        child: GestureDetector(
          onTap: () {
            if (widget.onChanged != null &&
                isRunning == false &&
                isPaused == false) {
              widget.onChanged!(!widget.isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  widget.isCompleted
                      ? Colors.blue
                      : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    style: TextStyle(
                      color:
                          widget.isCompleted
                              ? Colors.white
                              : Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (widget.totalDuration != null)
                    Text(
                      "${(widget.totalDuration! / 60).round()} min timer",
                      style: TextStyle(
                        color:
                            widget.isCompleted
                                ? Colors.white70
                                : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  //condition to check if runnig or pasued or completed
                  //also check if the counter was started or not
                  if (isRunning ||
                      isPaused ||
                      (widget.totalDuration == null &&
                          widget.isCompleted &&
                          passedSeconds > 0))
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child:
                          isCountDown
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Time left: ${_formatTime(remaining > 0 ? remaining : 0)}",
                                    style: TextStyle(
                                      color:
                                          widget.isCompleted
                                              ? Colors.white70
                                              : Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value:
                                        remaining > 0
                                            ? 1 -
                                                (remaining /
                                                    widget.totalDuration!)
                                            : 1,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.blue,
                                  ),
                                ],
                              )
                              : Text(
                                widget.isCompleted
                                    ? "Work done for ${(passedSeconds / 60).ceil()} minutes"
                                    : "Active for: ${_formatTime(passedSeconds)}",
                                style: TextStyle(
                                  color:
                                      widget.isCompleted
                                          ? Colors.white70
                                          : Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                    ),
                ],
              ),
              leading: Checkbox(
                activeColor: Colors.blue,
                value: widget.isCompleted,
                onChanged: widget.onChanged,
              ),
              trailing: IconButton(
                onPressed: widget.toggleFavorite,
                icon: Icon(Icons.autorenew),
                color: 
                    widget.isRenewable ? Colors.blueGrey : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
