import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:analog_timer/main.dart';
import 'package:analog_timer/timer_state.dart';
import 'package:audioplayers/audioplayers.dart';

// モックオーディオプレーヤー
class MockAudioPlayer extends AudioPlayer {
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
  // 統合テスト用のバインディングを初期化
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Generate app screenshots', (WidgetTester tester) async {
    final mockAudioPlayer = MockAudioPlayer();
    
    // スクリーンショットコントローラーの初期化
    final screenshotController = ScreenshotController();
    
    // スクリーンショット保存ディレクトリの設定
    final directory = await getApplicationDocumentsDirectory();
    final screenshotsDir = Directory('${directory.path}/screenshots');
    if (!await screenshotsDir.exists()) {
      await screenshotsDir.create(recursive: true);
    }
    
    // takeScreenshotメソッドの実装
    Future<void> takeScreenshot(String name) async {
      await tester.pumpAndSettle();
      
      // 現在のウィジェットツリーからスクリーンショットを撮影
      final image = await screenshotController.captureFromWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1080, 1920)),
            child: Builder(
              builder: (context) => Directionality(
                textDirection: TextDirection.ltr,
                child: tester.firstWidget(find.byType(MaterialApp)),
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
      );
      
      // ファイルに保存
      final file = File('${screenshotsDir.path}/$name.png');
      await file.writeAsBytes(image);
      print('Screenshot saved: ${file.path}');
    }
    
    // アプリをビルドして初期化
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => TimerState(audioPlayer: mockAudioPlayer),
        child: const MyApp(),
      ),
    );

    // アニメーションが完了するまで待機
    await tester.pumpAndSettle();

    // 初期状態のスクリーンショット
    await takeScreenshot('home_screen');

    // タイマーを30分に設定
    final TimerState timerState = tester.element(find.byType(MyHomePage))
        .read<TimerState>();
    timerState.setDuration(30);
    await tester.pumpAndSettle();

    // 30分タイマーのスクリーンショット
    await takeScreenshot('timer_30min');

    // タイマーを開始
    timerState.start();
    await tester.pumpAndSettle();

    // 実行中タイマーのスクリーンショット
    await takeScreenshot('timer_running');

    // アラームを有効化
    timerState.toggleAlarm();
    await tester.pumpAndSettle();

    // アラーム有効時のスクリーンショット
    await takeScreenshot('alarm_enabled');
  });
}
