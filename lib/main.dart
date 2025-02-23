import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'timer_state.dart';
import 'clock_painters.dart';
import 'models/premium_state.dart';
import 'screens/statistics_screen.dart';
import 'screens/study_records_screen.dart';
import 'screens/theme_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerState()),
        ChangeNotifierProvider(create: (context) => PremiumState()),
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
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Feel Timer'),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
            onSelected: (value) {
              switch (value) {
                case 'theme':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeSettingsScreen(),
                    ),
                  );
                  break;
                case 'records':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudyRecordsScreen(),
                    ),
                  );
                  break;
                case 'statistics':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'theme',
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
    );
  }
}
