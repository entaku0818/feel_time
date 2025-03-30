import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/premium_state.dart';
import '../models/study_record.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumState>(
      builder: (context, premiumState, child) {
        if (!premiumState.isPremium) {
          return const Center(
            child: Text('この機能はプレミアム会員専用です'),
          );
        }

        final records = premiumState.studyRecords;
        if (records.isEmpty) {
          return const Center(
            child: Text('学習記録がありません'),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('学習統計'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: '日別'),
                  Tab(text: '週別'),
                  Tab(text: 'カテゴリ別'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _DailyStatistics(records: records),
                _WeeklyStatistics(records: records),
                _CategoryStatistics(records: records),
              ],
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
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/timer');
                    },
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
                    color: Theme.of(context).colorScheme.primary, // 現在のページを強調表示
                    onPressed: null, // 現在のページなのでボタンを無効化
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
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/records'),
              tooltip: '学習記録を追加',
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
        );
      },
    );
  }
}

class _DailyStatistics extends StatelessWidget {
  final List<StudyRecord> records;

  const _DailyStatistics({required this.records});

  @override
  Widget build(BuildContext context) {
    final dailyData = _getDailyData();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('直近7日間の学習時間'),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxDailyMinutes(),
                barGroups: dailyData.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key.day,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}分');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, int> _getDailyData() {
    final now = DateTime.now();
    final dailyData = <DateTime, int>{};
    
    // 過去7日間のデータを初期化
    for (var i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      dailyData[date] = 0;
    }

    // 記録を集計
    for (var record in records) {
      if (record.isInDateRange(
        DateTime(now.year, now.month, now.day - 6),
        DateTime(now.year, now.month, now.day + 1),
      )) {
        final date = DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        );
        dailyData[date] = (dailyData[date] ?? 0) + record.durationMinutes;
      }
    }

    return dailyData;
  }

  double _getMaxDailyMinutes() {
    final minutes = _getDailyData().values;
    if (minutes.isEmpty) return 60;
    return (minutes.reduce((max, value) => max > value ? max : value) + 30)
        .toDouble();
  }
}

class _WeeklyStatistics extends StatelessWidget {
  final List<StudyRecord> records;

  const _WeeklyStatistics({required this.records});

  @override
  Widget build(BuildContext context) {
    final weeklyData = _getWeeklyData();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('週別学習時間'),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyData.entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('Week ${value.toInt()}');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}分');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, int> _getWeeklyData() {
    final now = DateTime.now();
    final weeklyData = <int, int>{};
    
    // 過去4週間のデータを初期化
    for (var i = 4; i >= 0; i--) {
      weeklyData[i] = 0;
    }

    // 記録を集計
    for (var record in records) {
      final weekDifference = now.difference(record.startTime).inDays ~/ 7;
      if (weekDifference < 5) {
        weeklyData[weekDifference] =
            (weeklyData[weekDifference] ?? 0) + record.durationMinutes;
      }
    }

    return weeklyData;
  }
}

class _CategoryStatistics extends StatelessWidget {
  final List<StudyRecord> records;

  const _CategoryStatistics({required this.records});

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('カテゴリ別学習時間'),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: categoryData.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.key}\n${entry.value}分',
                    color: _getCategoryColor(entry.key),
                    radius: 100,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: categoryData.entries.map((entry) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(entry.key),
                  ),
                  title: Text(entry.key),
                  trailing: Text('${entry.value}分'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getCategoryData() {
    final categoryData = <String, int>{};
    
    for (var record in records) {
      final category = record.category ?? '未分類';
      categoryData[category] = (categoryData[category] ?? 0) + record.durationMinutes;
    }

    return categoryData;
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final index = category.hashCode % colors.length;
    return colors[index];
  }
}
