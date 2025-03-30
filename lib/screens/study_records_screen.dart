import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/premium_state.dart';
import '../models/study_record.dart';
import 'package:uuid/uuid.dart';

class StudyRecordsScreen extends StatelessWidget {
  const StudyRecordsScreen({super.key});

  // 開発モードかどうかのチェック
  bool get _isDevMode => dotenv.get('DEV_MODE', fallback: 'true') == 'true';

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumState>(
      builder: (context, premiumState, child) {
        final records = premiumState.studyRecords;
        
        // デバッグ情報
        debugPrint('StudyRecordsScreen: ${records.length}件の記録があります');

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('学習記録'),
            elevation: 4.0, // 影をつけて目立たせる
            actions: [
              // 開発環境の場合のみサンプルデータ再生成ボタンを表示
              if (_isDevMode)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'サンプルデータを再生成',
                  onPressed: () => _recreateSampleData(context),
                ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddEditDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // 上部に説明バナーを追加
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  '学習記録：${records.length}件',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // 実際のリスト
              Expanded(
                child: records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('学習記録がありません'),
                          if (_isDevMode)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                onPressed: () => _recreateSampleData(context),
                                child: const Text('サンプルデータを生成'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _StudyRecordTile(record: record);
                      },
                    ),
              ),
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
                  color: Theme.of(context).colorScheme.primary, // 現在のページを強調表示
                  onPressed: null, // 現在のページなのでボタンを無効化
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
            onPressed: () => _showAddEditDialog(context),
            tooltip: '記録を追加',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  void _showAddEditDialog(BuildContext context, [StudyRecord? record]) {
    showDialog(
      context: context,
      builder: (context) => _StudyRecordDialog(record: record),
    );
  }

  // サンプルデータを再生成する
  void _recreateSampleData(BuildContext context) {
    final premiumState = context.read<PremiumState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('サンプルデータの再生成'),
        content: const Text('現在の学習記録をすべて削除して、新しいサンプルデータを生成しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              premiumState.recreateSampleData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('サンプルデータを再生成しました')),
              );
            },
            child: const Text('再生成'),
          ),
        ],
      ),
    );
  }
}

class _StudyRecordTile extends StatelessWidget {
  final StudyRecord record;

  const _StudyRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          record.category ?? '未分類',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatDate(record.startTime)} - ${_formatTime(record.startTime)} 〜 ${_formatTime(record.endTime)}',
            ),
            if (record.note != null && record.note!.isNotEmpty)
              Text(
                record.note!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            Text(
              '学習時間: ${record.durationMinutes}分',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('編集'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('削除'),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              showDialog(
                context: context,
                builder: (context) => _StudyRecordDialog(record: record),
              );
            } else if (value == 'delete') {
              _showDeleteConfirmation(context);
            }
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録の削除'),
        content: const Text('この学習記録を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<PremiumState>().removeStudyRecord(record.id);
              Navigator.pop(context);
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyRecordDialog extends StatefulWidget {
  final StudyRecord? record;

  const _StudyRecordDialog({this.record});

  @override
  State<_StudyRecordDialog> createState() => _StudyRecordDialogState();
}

class _StudyRecordDialogState extends State<_StudyRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime;
  late DateTime _endTime;
  late TextEditingController _categoryController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _startTime = widget.record?.startTime ?? DateTime.now();
    _endTime = widget.record?.endTime ?? _startTime.add(const Duration(hours: 1));
    _categoryController = TextEditingController(text: widget.record?.category ?? '');
    _noteController = TextEditingController(text: widget.record?.note ?? '');
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.record == null ? '学習記録の追加' : '学習記録の編集'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'カテゴリ',
                  hintText: '例: プログラミング',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('開始時間'),
                subtitle: Text(_formatDateTime(_startTime)),
                onTap: () => _selectDateTime(context, true),
              ),
              ListTile(
                title: const Text('終了時間'),
                subtitle: Text(_formatDateTime(_endTime)),
                onTap: () => _selectDateTime(context, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  hintText: '学習内容などを記録',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: _saveRecord,
          child: const Text('保存'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    if (!mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
    );

    if (time == null) return;

    setState(() {
      if (isStart) {
        _startTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      } else {
        _endTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    });
  }

  void _saveRecord() {
    if (_endTime.isBefore(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('終了時間は開始時間より後にしてください')),
      );
      return;
    }

    final durationMinutes = _endTime.difference(_startTime).inMinutes;
    
    if (durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('学習時間は1分以上必要です')),
      );
      return;
    }

    final record = StudyRecord(
      id: widget.record?.id ?? const Uuid().v4(),
      startTime: _startTime,
      endTime: _endTime,
      durationMinutes: durationMinutes,
      category: _categoryController.text.trim(),
      note: _noteController.text.trim(),
    );

    if (widget.record == null) {
      context.read<PremiumState>().addStudyRecord(record);
    } else {
      context.read<PremiumState>().updateStudyRecord(record);
    }

    Navigator.pop(context);
  }
}
