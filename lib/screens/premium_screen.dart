import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/premium_state.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final premiumState = Provider.of<PremiumState>(context, listen: false);
    try {
      final packages = await premiumState.getOfferings();
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('商品情報の取得に失敗しました')),
        );
      }
    }
  }

  Future<void> _handlePurchase(Package package) async {
    final premiumState = Provider.of<PremiumState>(context, listen: false);
    try {
      setState(() => _isLoading = true);
      final success = await premiumState.purchasePackage(package);
      if (success && mounted) {
        Navigator.of(context).pop(); // 購入成功後に画面を閉じる
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入に失敗しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エラーが発生しました')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    final premiumState = Provider.of<PremiumState>(context, listen: false);
    try {
      setState(() => _isLoading = true);
      final success = await premiumState.restorePurchases();
      if (success && mounted) {
        Navigator.of(context).pop(); // 復元成功後に画面を閉じる
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入履歴が見つかりませんでした')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('復元に失敗しました')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアム機能'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleRestore,
            child: const Text('購入を復元'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.star, size: 48, color: Colors.amber),
                            SizedBox(height: 16),
                            Text(
                              'プレミアム機能',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _FeatureItem(
                              icon: Icons.palette,
                              title: 'カスタムテーマ',
                              description: 'アプリの見た目をカスタマイズ',
                            ),
                            _FeatureItem(
                              icon: Icons.history,
                              title: '学習記録',
                              description: '詳細な学習履歴を保存',
                            ),
                            _FeatureItem(
                              icon: Icons.sync,
                              title: 'データ同期',
                              description: '複数デバイス間でデータを同期',
                            ),
                            _FeatureItem(
                              icon: Icons.analytics,
                              title: '統計分析',
                              description: '学習データの詳細な分析',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_packages.isEmpty)
                      const Center(
                        child: Text('現在利用可能なプランはありません'),
                      )
                    else
                      ..._packages.map((package) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _handlePurchase(package),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: Text(
                                '${package.storeProduct.title} - ${package.storeProduct.priceString}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          )),
                  ],
                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'プレミアム',
        backgroundColor: Colors.amber,
        child: const Icon(Icons.star),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
