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

  TimerProvider({required this.mode, required this.initialDuration})
    : _remaining = initialDuration;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
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
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
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
