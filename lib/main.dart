import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'timer_state.dart';
import 'clock_painters.dart';
import 'models/premium_state.dart';
import 'screens/statistics_screen.dart';
import 'screens/study_records_screen.dart';
import 'screens/theme_settings_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 環境変数の読み込み
  await dotenv.load(fileName: '.env');
  
  // テスト実行時のみFlutter Driver拡張を有効化
  bool isRunningTest = const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
  if (isRunningTest) {
    enableFlutterDriverExtension(handler: (request) async {
      return const String.fromEnvironment('DEVICE');
    });
  }
  
  await Firebase.initializeApp();
  
  final premiumState = PremiumState();
  await premiumState.initialize();
  
  final authService = AuthService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerState()),
        ChangeNotifierProvider.value(value: premiumState),
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const MyApp(),
    ),
  );
}

Color _parseColor(String hexColor) {
  return Color(int.parse(hexColor.replaceFirst('#', ''), radix: 16));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerState, PremiumState>(
      builder: (context, timerState, premiumState, child) {
        final themeColor = premiumState.isPremium
            ? _parseColor(premiumState.currentTheme.primaryColor)
            : Color.lerp(
                timerState.currentColor,
                timerState.nextColor,
                1.0 - timerState.colorTransition,
              ) ?? timerState.currentColor;

        return MaterialApp(
          title: 'Feel Timer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeColor,
              brightness: premiumState.isPremium && premiumState.currentTheme.isDark
                  ? Brightness.dark
                  : Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: ColorScheme.fromSeed(
                seedColor: themeColor,
                brightness: premiumState.isPremium && premiumState.currentTheme.isDark
                    ? Brightness.dark
                    : Brightness.light,
              ).inversePrimary,
              elevation: 4.0,
            ),
            useMaterial3: true,
          ),
          // 初期画面をタイマー画面に変更
          home: const MyHomePage(title: 'Feel Timer'),
          routes: {
            '/timer': (context) => const MyHomePage(title: 'Feel Timer'),
            '/records': (context) => const StudyRecordsScreen(),
            '/statistics': (context) => const StatisticsScreen(),
            '/themes': (context) => const ThemeSettingsScreen(),
            '/premium': (context) => const PremiumScreen(),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  void _handleMenuSelection(BuildContext context, String value) {
    // 選択されたルートに直接遷移
    Navigator.pushReplacementNamed(context, '/$value');
  }

  @override
  Widget build(BuildContext context) {
    // TimerStateにcontextを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerState>().setContext(context);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'themes',
                child: ListTile(
                  leading: Icon(Icons.palette),
                  title: Text('テーマ設定'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'records',
                child: ListTile(
                  leading: Icon(Icons.book),
                  title: Text('学習記録'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'statistics',
                child: ListTile(
                  leading: Icon(Icons.bar_chart),
                  title: Text('統計'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'premium',
                child: ListTile(
                  leading: Icon(Icons.star),
                  title: Text('プレミアム'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Clock face
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4,
                        ),
                      ),
                      child: CustomPaint(
                        painter: ClockFacePainter(context),
                      ),
                    ),
                    // Clock hands
                    Consumer<TimerState>(
                      builder: (context, timerState, child) {
                        return CustomPaint(
                          painter: ClockHandsPainter(
                            context,
                            timerState.currentDuration,
                          ),
                          size: const Size(300, 300),
                        );
                      },
                    ),
                    // Digital time display
                    Consumer<TimerState>(
                      builder: (context, timerState, child) {
                        return Text(
                          timerState.displayTime,
                          style: Theme.of(context).textTheme.headlineMedium,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Duration slider
                  Consumer<TimerState>(
                    builder: (context, timerState, child) {
                      return Slider(
                        value: timerState.currentDuration / 60,
                        max: 60,
                        divisions: 60,
                        label: '${(timerState.currentDuration / 60).round()} min',
                        onChanged: (value) => timerState.setDuration(value.round()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<TimerState>(
                        builder: (context, timerState, child) {
                          return ElevatedButton(
                            onPressed: timerState.isRunning ? timerState.stop : timerState.start,
                            child: Icon(
                              timerState.isRunning ? Icons.pause : Icons.play_arrow,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Consumer<TimerState>(
                        builder: (context, timerState, child) {
                          return ElevatedButton(
                            onPressed: timerState.reset,
                            child: const Icon(Icons.refresh),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Consumer<TimerState>(
                        builder: (context, timerState, child) {
                          return ElevatedButton(
                            onPressed: timerState.toggleAlarm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: timerState.isAlarmEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            child: const Icon(Icons.alarm),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        elevation: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.timer),
              tooltip: 'タイマー',
              color: Theme.of(context).colorScheme.primary, // 現在のページを強調表示
              onPressed: null, // 現在のページなのでボタンを無効化
            ),
            IconButton(
              icon: const Icon(Icons.book),
              tooltip: '学習記録',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/records');
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: '統計',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/statistics');
              },
            ),
            IconButton(
              icon: const Icon(Icons.palette),
              tooltip: 'テーマ設定',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/themes');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<TimerState>(
        builder: (context, timerState, child) {
          return FloatingActionButton(
            onPressed: timerState.isRunning ? timerState.stop : timerState.start,
            tooltip: timerState.isRunning ? '停止' : '開始',
            child: Icon(
              timerState.isRunning ? Icons.pause : Icons.play_arrow,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
