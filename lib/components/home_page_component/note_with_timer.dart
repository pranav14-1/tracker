import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MyTimer extends StatefulWidget {
  final Duration? duration; // null means counter mode
  final void Function(bool?)? onChanged;
  final bool isCompleted;
  final void Function()? timerStoppingScene;
  const MyTimer({
    super.key,
    this.duration,
    required this.isCompleted,
    required this.onChanged,
    required this.timerStoppingScene,
  });

  @override
  State<MyTimer> createState() => MyTimerState();
}

class MyTimerState extends State<MyTimer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TimerState _state = TimerState.stopped;
  Duration _remainingDuration = Duration.zero;

  // For counter mode
  int elapsedSeconds = 0;
  final int cycleDurationSeconds = 50 * 60; // 50 minutes
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.duration != null) {
      // Countdown mode
      _remainingDuration = widget.duration!;
      _controller =
          AnimationController(vsync: this, duration: widget.duration)
            ..addListener(() {
              setState(() {
                _remainingDuration = widget.duration! * (1 - _controller.value);
              });
            })
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                widget.onChanged!(!widget.isCompleted);
                widget.timerStoppingScene!();
              }
            });
    } else {
      // Counter mode
      _ticker = createTicker((elapsed) {
        setState(() {
          elapsedSeconds = elapsed.inSeconds;
        });
      });
    }
  }

  @override
  void dispose() {
    if (widget.duration != null) {
      _controller.dispose();
    } else {
      _ticker.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    if (widget.duration != null) {
      // Countdown mode
      if (_state == TimerState.stopped) {
        _controller.forward(from: 0);
      } else if (_state == TimerState.paused) {
        _controller.forward();
      }
    } else {
      // Counter mode
      _ticker.start();
    }
    setState(() => _state = TimerState.running);
  }

  void pauseTimer() {
    if (widget.duration != null) {
      _controller.stop();
    } else {
      _ticker.stop();
    }
    setState(() => _state = TimerState.paused);
  }

  void stopTimer() {
    if (widget.duration != null) {
      _controller.reset();
      _remainingDuration = widget.duration!;
    } else {
      _ticker.stop();
      elapsedSeconds = 0;
    }
    setState(() => _state = TimerState.stopped);
  }

  double height_value = 80;

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
      // Countdown mode
      progress = _controller.value;
      timeText = _formatTime(_remainingDuration);
    } else {
      // Counter mode with 50-minute cycles
      progress = (elapsedSeconds % cycleDurationSeconds) / cycleDurationSeconds;
      timeText = _formatTime(Duration(seconds: elapsedSeconds));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height_value,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Stack(
            children: [
              // Progress bar fill (cycles every 50 minutes in counter mode)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: Colors.blue, height: height_value),
                ),
              ),
              // Timer text
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
      ],
    );
  }
}

enum TimerState { stopped, running, paused }
