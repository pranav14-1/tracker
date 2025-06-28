import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyTimer extends StatefulWidget {
  final Duration? duration; // Null = count up mode
  final bool isRunning;
  final bool isPaused;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  final bool isCompleted;
  final void Function()? startTimer;
  final void Function()? pauseTimer;
  final void Function()? stopTimer;
  final AnimationController animationController;
  Duration remainingDuration;
  MyTimer({
    super.key,
    required this.animationController,
    required this.duration,
    required this.remainingDuration,
    required this.isPaused,
    required this.isRunning,
    required this.isCompleted,
    required this.deleteHabit,
    required this.editHabit,
    required this.startTimer,
    required this.pauseTimer,
    required this.stopTimer,
  });

  @override
  State<MyTimer> createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> with SingleTickerProviderStateMixin {

  // for counter mode
  int elapsedSeconds = 0;
  final int CycleDurationSeconds = 50 * 60; // 50 minutes

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double progress;
    String timeText;

    if (widget.duration != null) {
      // Count down mode
      progress = widget.animationController.value;
      timeText = _formatTime(widget.remainingDuration);
    } else {
      // Counter mode with 50-minute cycle
      progress = (elapsedSeconds % CycleDurationSeconds) / CycleDurationSeconds;
      timeText = _formatTime(Duration(seconds: elapsedSeconds));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slidable(
          startActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              if (!widget.isRunning)
                SlidableAction(
                  onPressed: (_) => widget.startTimer!(),
                  icon: Icons.play_circle_fill,
                  backgroundColor: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
              if (widget.isRunning)
                SlidableAction(
                  onPressed: (_) => widget.pauseTimer!(),
                  icon: Icons.pause_circle_filled,
                  backgroundColor: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
              if (widget.isRunning || widget.isPaused)
                SlidableAction(
                  onPressed: (_) => widget.stopTimer!(),
                  icon: Icons.stop_circle,
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
            ],
          ),
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Stack(
              children: [
                //Progress bar fill (cycles every 50 minutes in counter mode)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: Colors.blue, height: 80),
                  ),
                ),
                // Timer Text
                Center(
                  child: Text(
                    timeText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
