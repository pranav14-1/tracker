import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/features/timer%20provider/timer_provider.dart';

class MyTimer extends StatefulWidget {
  final VoidCallback? onPause, onStop;
  final void Function(bool?)? onChanged;
  final bool isCompleted;
  const MyTimer({
    super.key,
    required this.isCompleted,
    required this.onChanged,
    required this.onPause,
    required this.onStop,
  });

  @override
  State<MyTimer> createState() => MyTimerState();
}

class MyTimerState extends State<MyTimer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  TimerState _state = TimerState.stopped;

  void _startAnimation(TimerProvider timer) {
    final remaining = timer.initialDuration * (1 - timer.progress);
    _animationController.duration =
        remaining > Duration.zero ? remaining : Duration(seconds: 1);
    _animationController.forward(from: _animationController.value);
  }

  void _pauseAnimation() => _animationController.stop();

  void _resetAnimation() => _animationController.value = 0.0;

  @override
  void initState() {
    super.initState();
    final timer = Provider.of<TimerProvider>(context, listen: false);
    _animationController =
        AnimationController(
            vsync: this,
            value: timer.progress,
            duration: timer.initialDuration,
          )
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onChanged!(!widget.isCompleted);
            }
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final timer = Provider.of<TimerProvider>(context, listen: false);
    if (!timer.isRunning) {
      _animationController.value = timer.progress;
    }
  }

  @override
  void didUpdateWidget(MyTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final timer = Provider.of<TimerProvider>(context, listen: false);
    if (!timer.isRunning) {
      _animationController.value =
          timer.progress; // Always restore position on widget update
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double height_value = 80;

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerProvider>(context);

    final timeText =
        timer.mode == TimerMode.countdown
            ? _formatTime(timer.remaining)
            : _formatTime(Duration(seconds: timer.elapsed));

    if (timer.isRunning && !_animationController.isAnimating) {
      _startAnimation(timer);
      _state = TimerState.running;
    } else if (timer.isPaused && _animationController.isAnimating) {
      _pauseAnimation();
      _state = TimerState.paused;
    } else if (timer.isStopped && _animationController.value != 0) {
      _resetAnimation();
      _state = TimerState.stopped;
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
                  widthFactor: _animationController.value,
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
