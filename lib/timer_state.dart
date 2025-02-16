import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerState extends ChangeNotifier {
  static const int _defaultDuration = 25 * 60; // 25 minutes in seconds
  
  Timer? _timer;
  int _currentDuration = _defaultDuration;
  bool _isRunning = false;

  // Getters
  int get currentDuration => _currentDuration;
  bool get isRunning => _isRunning;
  
  String get displayTime {
    final minutes = (_currentDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Start the timer
  void start() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
      notifyListeners();
    }
  }

  // Stop the timer
  void stop() {
    if (_isRunning) {
      _isRunning = false;
      _timer?.cancel();
      _timer = null;
      notifyListeners();
    }
  }

  // Reset the timer
  void reset() {
    stop();
    _currentDuration = _defaultDuration;
    notifyListeners();
  }

  // Timer callback
  void _timerCallback(Timer timer) {
    if (_currentDuration > 0) {
      _currentDuration--;
      notifyListeners();
    } else {
      stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Test-only method to set duration
  @visibleForTesting
  void setDurationForTesting(int seconds) {
    _currentDuration = seconds;
    notifyListeners();
  }
}
