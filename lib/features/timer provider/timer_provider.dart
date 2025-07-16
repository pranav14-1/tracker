import 'dart:async';
import 'package:flutter/material.dart';

enum TimerMode { countdown, counter }

class TimerProvider extends ChangeNotifier {
  final TimerMode mode;
  final Duration initialDuration;

  Duration _remaining;
  int _elapsed = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;

  TimerProvider({required this.mode, required this.initialDuration})
    : _remaining = initialDuration;

  bool get isRunning => _isRunning && !_isPaused;
  bool get isPaused => _isPaused;
  bool get isStopped => !_isRunning && !_isPaused;
  Duration get remaining => _remaining;
  int get elapsed => _elapsed;

  double get progress {
    if (mode == TimerMode.countdown) {
      final total = initialDuration.inSeconds;
      return total == 0 ? 0.0 : (total - remaining.inSeconds) / total;
    } else {
      const cycle = 50 * 60;
      return (elapsed % cycle) / cycle;
    }
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _isPaused = false;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mode == TimerMode.countdown) {
        if (_remaining.inSeconds > 0) {
          _remaining -= Duration(seconds: 1);
        } else {
          _timer?.cancel();
          _isRunning = false;
        }
      } else {
        _elapsed += 1;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remaining = initialDuration;
    _elapsed = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }
}
