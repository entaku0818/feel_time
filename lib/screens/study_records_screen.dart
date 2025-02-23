import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/premium_state.dart';
import '../models/study_record.dart';
import 'package:uuid/uuid.dart';

class StudyRecordsScreen extends StatelessWidget {
  const StudyRecordsScreen({super.key});

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
        return Scaffold(
          appBar: AppBar(
            title: const Text('学習記録'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddEditDialog(context),
              ),
            ],
          ),
          body: records.isEmpty
              ? const Center(child: Text('学習記録がありません'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _StudyRecordTile(record: record);
                  },
                ),
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
              '${_formatDateTime(record.startTime)} - ${_formatDateTime(record.endTime)}',
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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

    final record = StudyRecord(
      id: widget.record?.id ?? const Uuid().v4(),
      startTime: _startTime,
      endTime: _endTime,
      durationMinutes: _endTime.difference(_startTime).inMinutes,
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
