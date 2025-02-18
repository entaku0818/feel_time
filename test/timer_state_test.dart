import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/timer_state.dart';
import 'package:audioplayers/audioplayers.dart';

class MockAudioPlayer extends AudioPlayer {
  MockAudioPlayer() : super();

  @override
  Future<void> _create() async {
    // モックの実装では何もしない
  }

  @override
  Future<void> play(Source source, {
    double? balance,
    AudioContext? ctx,
    PlayerMode? mode,
    Duration? position,
    double? volume,
  }) async {
    // モックの実装では何もしない
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TimerState timerState;
  late MockAudioPlayer mockAudioPlayer;

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();
    timerState = TimerState(audioPlayer: mockAudioPlayer);
  });

  tearDown(() {
    timerState.dispose();
  });

  test('initial state should be correct', () {
    expect(timerState.currentDuration, equals(25 * 60)); // 25 minutes in seconds
    expect(timerState.isRunning, equals(false));
    expect(timerState.displayTime, equals('25:00'));
  });

  test('start should change isRunning to true', () {
    timerState.start();
    expect(timerState.isRunning, equals(true));
  });

  test('stop should change isRunning to false', () {
    timerState.start();
    timerState.stop();
    expect(timerState.isRunning, equals(false));
  });

  test('reset should restore initial duration', () {
    timerState.start();
    // Wait for 2 seconds to let the timer decrease
    Future.delayed(const Duration(seconds: 2), () {
      timerState.reset();
      expect(timerState.currentDuration, equals(25 * 60));
      expect(timerState.isRunning, equals(false));
      expect(timerState.displayTime, equals('25:00'));
    });
  });

  test('displayTime should format time correctly', () {
    // Test different time scenarios
    final testCases = [
      {'seconds': 25 * 60, 'expected': '25:00'},
      {'seconds': 10 * 60, 'expected': '10:00'},
      {'seconds': 5 * 60 + 30, 'expected': '05:30'},
      {'seconds': 59, 'expected': '00:59'},
      {'seconds': 0, 'expected': '00:00'},
    ];

    for (final testCase in testCases) {
      timerState.stop();
      timerState = TimerState(audioPlayer: mockAudioPlayer);
      timerState.setDurationForTesting(testCase['seconds'] as int);
      expect(timerState.displayTime, equals(testCase['expected']));
    }
  });

  test('timer should stop at 0', () {
    timerState = TimerState(audioPlayer: mockAudioPlayer);
    // Set duration to 1 second
    timerState.setDurationForTesting(1);
    timerState.start();

    // Wait for 2 seconds to ensure timer goes to 0
    Future.delayed(const Duration(seconds: 2), () {
      expect(timerState.currentDuration, equals(0));
      expect(timerState.isRunning, equals(false));
      expect(timerState.displayTime, equals('00:00'));
    });
  });
}
