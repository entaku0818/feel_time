import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerState extends ChangeNotifier {
  // Color configurations
  static const List<Color> _colors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];
  
  int _colorIndex = 0;
  double _colorTransition = 0.0; // 0.0 to 1.0 for smooth transition
  static const int _maxDuration = 60 * 60; // 60 minutes in seconds
  static const int _defaultDuration = 25 * 60; // 25 minutes in seconds
  
  Timer? _timer;
  int _currentDuration = _defaultDuration;
  bool _isRunning = false;
  bool _isAlarmEnabled = false;
  final audioPlayer = AudioPlayer();

  // Getters
  int get currentDuration => _currentDuration;
  bool get isRunning => _isRunning;
  bool get isAlarmEnabled => _isAlarmEnabled;
  Color get currentColor => _colors[_colorIndex];
  Color get nextColor => _colors[(_colorIndex + 1) % _colors.length];
  double get colorTransition => _colorTransition;
  
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
      
      // Update color transition every second
      if (_currentDuration % 60 < 5) { // Last 5 seconds of each 1-minute period
        _colorTransition = (_currentDuration % 60) / 5.0;
        if (_colorTransition == 0.0) {
          _colorIndex = (_colorIndex + 1) % _colors.length;
        }
      } else {
        _colorTransition = 0.0;
      }
      
      notifyListeners();
    } else {
      stop();
      if (_isAlarmEnabled) {
        _playAlarm();
      }
    }
  }

  // Set duration in minutes
  void setDuration(int minutes) {
    if (minutes > 0 && minutes <= 60) {
      stop();
      _currentDuration = minutes * 60;
      notifyListeners();
    }
  }

  // Toggle alarm
  void toggleAlarm() {
    _isAlarmEnabled = !_isAlarmEnabled;
    notifyListeners();
  }

  // Play alarm sound
  void _playAlarm() async {
    try {
      await audioPlayer.play(AssetSource('alarm.mp3'));
    } catch (e) {
      debugPrint('Error playing alarm: $e');
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
