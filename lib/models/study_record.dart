class StudyRecord {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String? note;
  final String? category;
  final DateTime createdAt;

  StudyRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.note,
    this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'note': note,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyRecord.fromJson(Map<String, dynamic> json) {
    return StudyRecord(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      note: json['note'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  StudyRecord copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? note,
    String? category,
    DateTime? createdAt,
  }) {
    return StudyRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      note: note ?? this.note,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 学習時間の統計用のヘルパーメソッド
  bool isInDateRange(DateTime start, DateTime end) {
    return startTime.isAfter(start) && endTime.isBefore(end);
  }

  bool isInSameDay(DateTime date) {
    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }
}
