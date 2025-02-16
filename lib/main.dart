import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer_state.dart';

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
    return MaterialApp(
      title: 'Timer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<TimerState>(
              builder: (context, timerState, child) {
                return Text(
                  timerState.displayTime,
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
            const SizedBox(height: 30),
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
                const SizedBox(width: 20),
                Consumer<TimerState>(
                  builder: (context, timerState, child) {
                    return ElevatedButton(
                      onPressed: timerState.reset,
                      child: const Icon(Icons.refresh),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
