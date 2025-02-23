import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/study_record.dart';
import '../models/theme_settings.dart';

// TODO: Firestore設定
// 1. Firebase Console (https://console.firebase.google.com/)
//    - Firestore Databaseを作成
//    - セキュリティルールを適用（firestore.rules）
//    - インデックスの作成
//      - study_records: startTime（昇順）
//      - study_records: category（昇順）, durationMinutes（降順）
// 2. 本番環境の準備
//    - 適切なロケーションの選択
//    - スケーリング設定の確認
//    - バックアップ設定

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ユーザーのドキュメントへの参照を取得
  DocumentReference? get _userDoc {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  // テーマ設定の同期
  Future<void> syncThemeSettings(ThemeSettings settings) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('settings').doc('theme').set(settings.toJson());
  }

  Future<ThemeSettings?> getThemeSettings() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.collection('settings').doc('theme').get();
    if (!snapshot.exists) return null;

    return ThemeSettings.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  // 学習記録の同期
  Future<void> syncStudyRecord(StudyRecord record) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc
        .collection('study_records')
        .doc(record.id)
        .set(record.toJson());
  }

  Future<void> deleteStudyRecord(String recordId) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('study_records').doc(recordId).delete();
  }

  Future<List<StudyRecord>> getAllStudyRecords() async {
    final doc = _userDoc;
    if (doc == null) return [];

    final snapshot = await doc.collection('study_records').get();
    return snapshot.docs
        .map((doc) => StudyRecord.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // 特定の期間の学習記録を取得
  Future<List<StudyRecord>> getStudyRecordsInRange(
      DateTime start, DateTime end) async {
    final doc = _userDoc;
    if (doc == null) return [];

    final snapshot = await doc
        .collection('study_records')
        .where('startTime',
            isGreaterThanOrEqualTo: start.toIso8601String())
        .where('startTime', isLessThanOrEqualTo: end.toIso8601String())
        .get();

    return snapshot.docs
        .map((doc) => StudyRecord.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // プレミアムステータスの確認
  Future<bool> checkPremiumStatus() async {
    final doc = _userDoc;
    if (doc == null) return false;

    final snapshot = await doc.get();
    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['isPremium'] ?? false;
  }

  // プレミアムステータスの更新
  Future<void> updatePremiumStatus(bool isPremium) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.set({'isPremium': isPremium}, SetOptions(merge: true));
  }

  // ストリームを使用した学習記録のリアルタイム同期
  Stream<List<StudyRecord>> studyRecordsStream() {
    final doc = _userDoc;
    if (doc == null) return Stream.value([]);

    return doc.collection('study_records').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => StudyRecord.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
