import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'theme_settings.dart';
import 'study_record.dart';
import '../services/purchase_service.dart';

class PremiumState extends ChangeNotifier {
  bool _isPremium = false;
  ThemeSettings _currentTheme;
  List<StudyRecord> _studyRecords = [];
  bool _isSyncing = false;
  final PurchaseService _purchaseService = PurchaseService();
  bool _isInitialized = false;

  PremiumState()
      : _currentTheme = ThemeSettings(
          name: 'Default',
          primaryColor: '#FF2196F3', // Blue
          secondaryColor: '#FF4CAF50', // Green
          backgroundColor: '#FFFFFFFF', // White
        );

  // Getters
  bool get isPremium => _isPremium;
  ThemeSettings get currentTheme => _currentTheme;
  List<StudyRecord> get studyRecords => List.unmodifiable(_studyRecords);
  bool get isSyncing => _isSyncing;

  // 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _purchaseService.initialize();
    await _loadPremiumStatus();
    _isInitialized = true;
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
    final success = await _purchaseService.purchasePackage(package);
    if (success) {
      await setPremiumStatus(true);
    }
    return success;
  }

  // 購入の復元
  Future<bool> restorePurchases() async {
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
    await _purchaseService.setUserId(userId);
    await _loadPremiumStatus();
  }

  // Theme management
  void updateTheme(ThemeSettings newTheme) {
    if (!_isPremium) return;
    _currentTheme = newTheme;
    notifyListeners();
  }

  // Study records management
  void addStudyRecord(StudyRecord record) {
    if (!_isPremium) return;
    _studyRecords.add(record);
    notifyListeners();
  }

  void removeStudyRecord(String id) {
    if (!_isPremium) return;
    _studyRecords.removeWhere((record) => record.id == id);
    notifyListeners();
  }

  void updateStudyRecord(StudyRecord updatedRecord) {
    if (!_isPremium) return;
    final index = _studyRecords.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      _studyRecords[index] = updatedRecord;
      notifyListeners();
    }
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
