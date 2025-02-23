import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// TODO: Firebase Authentication設定
// 1. Firebase Console (https://console.firebase.google.com/)
//    - Authentication > Sign-in method
//      - メール/パスワード認証を有効化
//      - メールテンプレートをカスタマイズ（確認メール、パスワードリセット）
// 2. iOS設定
//    - GoogleService-Info.plistの追加
//    - Info.plistにURLスキームを追加
// 3. Android設定
//    - google-services.jsonの追加
//    - build.gradleの設定

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get userId => _user?.uid ?? '';

  // メールアドレスでサインアップ
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'パスワードが弱すぎます';
          break;
        case 'email-already-in-use':
          message = 'このメールアドレスは既に使用されています';
          break;
        case 'invalid-email':
          message = '無効なメールアドレスです';
          break;
        default:
          message = 'エラーが発生しました: ${e.message}';
      }
      throw AuthException(message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // メールアドレスでログイン
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'ユーザーが見つかりません';
          break;
        case 'wrong-password':
          message = 'パスワードが間違っています';
          break;
        case 'invalid-email':
          message = '無効なメールアドレスです';
          break;
        case 'user-disabled':
          message = 'このアカウントは無効化されています';
          break;
        default:
          message = 'エラーが発生しました: ${e.message}';
      }
      throw AuthException(message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // パスワードリセットメールの送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = '無効なメールアドレスです';
          break;
        case 'user-not-found':
          message = 'ユーザーが見つかりません';
          break;
        default:
          message = 'エラーが発生しました: ${e.message}';
      }
      throw AuthException(message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // サインアウト
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // メールアドレスの確認メールを送信
  Future<void> sendEmailVerification() async {
    try {
      await _user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException('確認メールの送信に失敗しました: ${e.message}');
    }
  }

  // メールアドレスが確認済みかどうか
  bool get isEmailVerified => _user?.emailVerified ?? false;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
