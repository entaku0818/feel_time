import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/premium_state.dart';
import '../models/theme_settings.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  late TextEditingController _nameController;
  Color _primaryColor = const Color(0xFF2196F3);
  Color _secondaryColor = const Color(0xFF4CAF50);
  Color _backgroundColor = Colors.white;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'カスタムテーマ');
    
    // 現在のテーマ設定を読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentTheme = context.read<PremiumState>().currentTheme;
      _nameController.text = currentTheme.name;
      _primaryColor = _parseColor(currentTheme.primaryColor);
      _secondaryColor = _parseColor(currentTheme.secondaryColor);
      _backgroundColor = _parseColor(currentTheme.backgroundColor);
      _isDark = currentTheme.isDark;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', ''), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  void _saveTheme() {
    if (!context.read<PremiumState>().isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('この機能はプレミアム会員専用です')),
      );
      return;
    }

    final newTheme = ThemeSettings(
      name: _nameController.text,
      primaryColor: _colorToHex(_primaryColor),
      secondaryColor: _colorToHex(_secondaryColor),
      backgroundColor: _colorToHex(_backgroundColor),
      isDark: _isDark,
    );

    context.read<PremiumState>().updateTheme(newTheme);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('テーマを保存しました')),
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color initialColor) async {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = initialColor;
        return AlertDialog(
          title: const Text('色を選択'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('選択'),
              onPressed: () {
                Navigator.of(context).pop(selectedColor);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テーマ設定'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTheme,
          ),
        ],
      ),
      body: Consumer<PremiumState>(
        builder: (context, premiumState, child) {
          if (!premiumState.isPremium) {
            return const Center(
              child: Text('この機能はプレミアム会員専用です'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'テーマ名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('メインカラー'),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onTap: () async {
                  final color = await _showColorPicker(context, _primaryColor);
                  if (color != null) {
                    setState(() => _primaryColor = color);
                  }
                },
              ),
              ListTile(
                title: const Text('アクセントカラー'),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _secondaryColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onTap: () async {
                  final color = await _showColorPicker(context, _secondaryColor);
                  if (color != null) {
                    setState(() => _secondaryColor = color);
                  }
                },
              ),
              ListTile(
                title: const Text('背景色'),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onTap: () async {
                  final color = await _showColorPicker(context, _backgroundColor);
                  if (color != null) {
                    setState(() => _backgroundColor = color);
                  }
                },
              ),
              SwitchListTile(
                title: const Text('ダークモード'),
                value: _isDark,
                onChanged: (value) {
                  setState(() => _isDark = value);
                },
              ),
              const SizedBox(height: 20),
              Card(
                color: _backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'プレビュー',
                        style: TextStyle(
                          color: _isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                        ),
                        onPressed: () {},
                        child: const Text('メインボタン'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _secondaryColor,
                        ),
                        onPressed: () {},
                        child: const Text('サブボタン'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
              color: Theme.of(context).colorScheme.primary, // 現在のページを強調表示
              onPressed: null, // 現在のページなのでボタンを無効化
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTheme,
        tooltip: 'テーマを保存',
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// シンプルなカラーピッカーウィジェット
class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final colorGroup in _colorGroups)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colorGroup.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() => currentColor = color);
                    widget.onColorChanged(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: currentColor == color
                            ? Colors.white
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  static const _colorGroups = [
    [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
    ],
    [
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
    ],
    [
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
    ],
    [
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ],
    [
      Colors.white,
      Color(0xFFFAFAFA),
      Color(0xFFF5F5F5),
      Color(0xFFEEEEEE),
      Color(0xFFE0E0E0),
    ],
  ];
}
