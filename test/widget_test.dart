// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:analog_timer/main.dart';
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
  testWidgets('Timer UI test', (WidgetTester tester) async {
    final mockAudioPlayer = MockAudioPlayer();
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => TimerState(audioPlayer: mockAudioPlayer),
        child: const MyApp(),
      ),
    );

    // Verify initial state
    expect(find.text('25:00'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Test start button
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Test pause button
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Test reset button
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.text('25:00'), findsOneWidget);
  });
}
