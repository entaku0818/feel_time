import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer_state.dart';
import 'clock_painters.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final timerState = Provider.of<TimerState>(context);
    return MaterialApp(
      title: 'Timer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.lerp(
            timerState.currentColor,
            timerState.nextColor,
            1.0 - timerState.colorTransition,
          ) ?? timerState.currentColor,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Timer App'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
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
