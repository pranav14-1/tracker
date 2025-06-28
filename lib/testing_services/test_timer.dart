import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RectangularTimer extends StatefulWidget {
  final Duration? duration; // null means counter mode
  const RectangularTimer({super.key, this.duration});

  @override
  State<RectangularTimer> createState() => _RectangularTimerState();
}

class _RectangularTimerState extends State<RectangularTimer>
    with SingleTickerProviderStateMixin {
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
      _controller = AnimationController(vsync: this, duration: widget.duration)
        ..addListener(() {
          setState(() {
            _remainingDuration = widget.duration! * (1 - _controller.value);
          });
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

  void _startTimer() {
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

  void _pauseTimer() {
    if (widget.duration != null) {
      _controller.stop();
    } else {
      _ticker.stop();
    }
    setState(() => _state = TimerState.paused);
  }

  void _stopTimer() {
    if (widget.duration != null) {
      _controller.reset();
      _remainingDuration = widget.duration!;
    } else {
      _ticker.stop();
      elapsedSeconds = 0;
    }
    setState(() => _state = TimerState.stopped);
  }

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
          height: 60,
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
                borderRadius: BorderRadius.circular(12),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: Colors.blue, height: 60),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_state != TimerState.running)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                onPressed: _startTimer,
              ),
            if (_state == TimerState.running) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
                onPressed: _pauseTimer,
              ),
              const SizedBox(width: 16),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              onPressed: _stopTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum TimerState { stopped, running, paused }
