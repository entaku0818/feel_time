import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'theme_settings.dart';
import 'study_record.dart';
import '../services/purchase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class PremiumState extends ChangeNotifier {
  bool _isPremium = false;
  ThemeSettings _currentTheme;
  List<StudyRecord> _studyRecords = [];
  bool _isSyncing = false;
  final PurchaseService _purchaseService = PurchaseService();
  bool _isInitialized = false;
  
  // 開発環境では常にプレミアム機能にアクセスできるようにする
  bool get _devModeEnabled => dotenv.get('DEV_MODE', fallback: 'true') == 'true';

  PremiumState()
      : _currentTheme = ThemeSettings(
          name: 'Default',
          primaryColor: '#FF2196F3', // Blue
          secondaryColor: '#FF4CAF50', // Green
          backgroundColor: '#FFFFFFFF', // White
        );

  // Getters
  bool get isPremium => _devModeEnabled || _isPremium;  // 開発モードの場合は常にtrue
  ThemeSettings get currentTheme => _currentTheme;
  List<StudyRecord> get studyRecords => List.unmodifiable(_studyRecords);
  bool get isSyncing => _isSyncing;

  // 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // まず保存されたデータをロード
    await _loadSavedData();
    
    // 無料ユーザーの場合は1週間分の記録に制限
    if (!_devModeEnabled && !_isPremium) {
      _limitRecordsToOneWeek();
    }
    
    // 開発モードかつ記録がない場合はサンプルデータを作成
    if (_devModeEnabled && _studyRecords.isEmpty) {
      _createSampleData();
    }
    
    // その後RevenueCatの初期化
    await _purchaseService.initialize();
    if (!_devModeEnabled) {
      await _loadPremiumStatus();
    }
    _isInitialized = true;
  }

  // 無料ユーザーの記録を1週間分だけに制限するメソッド
  void _limitRecordsToOneWeek() {
    // 現在の日時から1週間前の日時を計算
    final DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    // 1週間より古い記録を削除
    _studyRecords.removeWhere((record) => record.startTime.isBefore(oneWeekAgo));
    
    debugPrint('Limited records to last 7 days. ${_studyRecords.length} records remaining.');
  }

  // 開発用サンプルデータの作成
  void _createSampleData() {
    debugPrint('Creating sample study records for development');
    
    // カテゴリのリスト
    final categories = [
      'プログラミング',
      '英語学習',
      '数学',
      'デザイン',
      'Flutterアプリ開発'
    ];
    
    // メモのリスト
    final notes = [
      'とても集中できた',
      '難しい内容だったが理解できた',
      'もう少し時間が必要',
      '良い進捗があった',
      'オンライン講座を受講'
    ];
    
    // 過去30日間のランダムなデータを作成
    final now = DateTime.now();
    final random = Random();
    
    // 30件のサンプルデータを作成
    for (int i = 0; i < 30; i++) {
      // ランダムな日付（過去30日以内）
      final daysAgo = random.nextInt(30);
      final date = now.subtract(Duration(days: daysAgo));
      
      // ランダムな開始時間（9時〜20時）
      final hour = 9 + random.nextInt(12);
      final minute = random.nextInt(60);
      final startTime = DateTime(
        date.year, date.month, date.day, hour, minute
      );
      
      // ランダムな学習時間（15分〜120分）
      final duration = 15 + random.nextInt(106);
      final endTime = startTime.add(Duration(minutes: duration));
      
      // ランダムなカテゴリとメモ
      final category = categories[random.nextInt(categories.length)];
      final note = random.nextBool() 
          ? notes[random.nextInt(notes.length)] 
          : null;
      
      // 記録の作成
      final record = StudyRecord(
        id: const Uuid().v4(),
        startTime: startTime,
        endTime: endTime,
        durationMinutes: duration,
        category: category,
        note: note,
      );
      
      _studyRecords.add(record);
    }
    
    // 日付順にソート（新しい順）
    _studyRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    // データを保存
    _saveData();
    
    debugPrint('Created ${_studyRecords.length} sample records');
  }

  // 保存されたデータをロード
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 学習記録を取得
      final recordsJson = prefs.getStringList('study_records') ?? [];
      _studyRecords = recordsJson.map((json) => 
        StudyRecord.fromJson(jsonDecode(json) as Map<String, dynamic>)
      ).toList();
      
      // テーマ設定を取得
      final themeJson = prefs.getString('current_theme');
      if (themeJson != null) {
        _currentTheme = ThemeSettings.fromJson(
          jsonDecode(themeJson) as Map<String, dynamic>
        );
      }
      
      debugPrint('Loaded ${_studyRecords.length} study records from storage');
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }
  
  // データを保存
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 学習記録を保存
      final recordsJson = _studyRecords.map((record) => 
        jsonEncode(record.toJson())
      ).toList();
      await prefs.setStringList('study_records', recordsJson);
      
      // テーマ設定を保存
      await prefs.setString('current_theme', jsonEncode(_currentTheme.toJson()));
      
      debugPrint('Saved ${_studyRecords.length} study records to storage');
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // テスト/開発用: サンプルデータを再作成
  Future<void> recreateSampleData() async {
    _studyRecords.clear();
    _createSampleData();
    notifyListeners();
  }

  // Premium status
  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    notifyListeners();
  }

  Future<void> _loadPremiumStatus() async {
    final status = await _purchaseService.checkPremiumStatus();
    await setPremiumStatus(status);
  }

  // 購入処理
  Future<bool> purchasePackage(Package package) async {
    if (_devModeEnabled) return true;
    
    final success = await _purchaseService.purchasePackage(package);
    if (success) {
      await setPremiumStatus(true);
    }
    return success;
  }

  // 購入の復元
  Future<bool> restorePurchases() async {
    if (_devModeEnabled) return true;
    
    final success = await _purchaseService.restorePurchases();
    if (success) {
      await setPremiumStatus(true);
    }
    return success;
  }

  // 商品情報の取得
  Future<List<Package>> getOfferings() async {
    return _purchaseService.getOfferings();
  }

  // ユーザーIDの設定
  Future<void> setUserId(String userId) async {
    if (_devModeEnabled) return;
    
    await _purchaseService.setUserId(userId);
    await _loadPremiumStatus();
  }

  // Theme management
  void updateTheme(ThemeSettings newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
    _saveData(); // テーマを変更したら保存
  }

  // Study records management
  void addStudyRecord(StudyRecord record) {
    debugPrint('Adding study record: ${record.durationMinutes} minutes');
    _studyRecords.add(record);
    
    // 無料ユーザーの場合は1週間分の記録だけに制限
    if (!isPremium) {
      _limitRecordsToOneWeek();
    }
    
    _saveData(); // 記録を追加したら保存
    notifyListeners();
  }

  void removeStudyRecord(String id) {
    _studyRecords.removeWhere((record) => record.id == id);
    _saveData(); // 記録を削除したら保存
    notifyListeners();
  }

  void updateStudyRecord(StudyRecord updatedRecord) {
    final index = _studyRecords.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      _studyRecords[index] = updatedRecord;
      _saveData(); // 記録を更新したら保存
      notifyListeners();
    }
  }

  // テスト用: すべての記録をクリア
  Future<void> clearAllRecords() async {
    _studyRecords.clear();
    await _saveData();
    notifyListeners();
  }

  // Statistics helpers
  int getTotalStudyMinutes() {
    return _studyRecords.fold(0, (sum, record) => sum + record.durationMinutes);
  }

  Map<String, int> getStudyMinutesByCategory() {
    final Map<String, int> categoryMinutes = {};
    for (var record in _studyRecords) {
      final category = record.category ?? 'Uncategorized';
      categoryMinutes[category] = (categoryMinutes[category] ?? 0) + record.durationMinutes;
    }
    return categoryMinutes;
  }

  List<StudyRecord> getRecordsInDateRange(DateTime start, DateTime end) {
    return _studyRecords.where((record) => record.isInDateRange(start, end)).toList();
  }

  // Sync status
  void setSyncStatus(bool status) {
    _isSyncing = status;
    notifyListeners();
  }

  // Data persistence
  Map<String, dynamic> toJson() {
    return {
      'isPremium': _isPremium,
      'currentTheme': _currentTheme.toJson(),
      'studyRecords': _studyRecords.map((r) => r.toJson()).toList(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _isPremium = json['isPremium'] as bool;
    _currentTheme = ThemeSettings.fromJson(json['currentTheme'] as Map<String, dynamic>);
    _studyRecords = (json['studyRecords'] as List)
        .map((r) => StudyRecord.fromJson(r as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }
}
