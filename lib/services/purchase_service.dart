import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PurchaseService {
  // TODO: RevenueCat設定
  // 1. RevenueCat Dashboard (https://app.revenuecat.com/)
  //    - プロジェクトを作成
  //    - アプリを登録（iOS/Android）
  //    - エンタイトルメント「premium」を作成
  //    - 商品を設定（月額・年額プラン）
  // 2. App Store Connect
  //    - アプリ内課金の設定
  //    - サブスクリプション商品の登録
  // 3. Google Play Console
  //    - サブスクリプション商品の設定
  //    - アプリ内課金の有効化
  
  // SubscriptionID
  static const String _monthlySubscriptionId = 'premium_monthly';
  static const String _yearlySubscriptionId = 'premium_yearly';
  
  // 環境変数から開発モードを読み込む (デフォルトはtrue)
  bool get _devModeEnabled => dotenv.get('DEV_MODE', fallback: 'true') == 'true';
  
  // プラットフォームに応じたAPIキーを環境変数から取得
  String get _apiKey {
    // デバッグモードでAPIキーを取得できない場合のダミー値
    const String fallbackKey = 'dummy_api_key';
    
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        return dotenv.get('REVENUECAT_API_KEY_IOS', fallback: fallbackKey);
      } else if (Platform.isAndroid) {
        return dotenv.get('REVENUECAT_API_KEY_ANDROID', fallback: fallbackKey);
      }
      // その他のプラットフォームはデフォルト値を返す
      return fallbackKey;
    } catch (e) {
      debugPrint('Error getting API key: $e');
      return fallbackKey;
    }
  }

  // RevenueCatの初期化
  Future<void> initialize() async {
    if (!_devModeEnabled) {
      try {
        await Purchases.setLogLevel(LogLevel.debug);
        await Purchases.configure(PurchasesConfiguration(_apiKey));
      } catch (e) {
        debugPrint('Error initializing RevenueCat: $e');
      }
    } else {
      debugPrint('DevMode: RevenueCat initialization skipped');
    }
  }

  // 利用可能な商品を取得
  Future<List<Package>> getOfferings() async {
    if (_devModeEnabled) {
      debugPrint('DevMode: Returning empty offerings list');
      return []; // 開発モードではパッケージを返さない
    }
    
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      
      return current?.availablePackages ?? [];
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return [];
    }
  }

  // サブスクリプションの購入
  Future<bool> purchasePackage(Package package) async {
    if (_devModeEnabled) {
      debugPrint('DevMode: Purchase successful');
      return true; // 開発モードでは常に成功を返す
    }
    
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isPremium = customerInfo.entitlements.active.isNotEmpty;
      return isPremium;
    } catch (e) {
      debugPrint('Error making purchase: $e');
      return false;
    }
  }

  // 現在のサブスクリプション状態を確認
  Future<bool> checkPremiumStatus() async {
    if (_devModeEnabled) {
      debugPrint('DevMode: Premium status is active');
      return true; // 開発モードでは常にプレミアム有効を返す
    }
    
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  // ユーザーIDの設定（Firebase認証と連携）
  Future<void> setUserId(String userId) async {
    if (_devModeEnabled) {
      debugPrint('DevMode: User ID setting skipped');
      return; // 開発モードでは何もしない
    }
    
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }

  // 購入の復元
  Future<bool> restorePurchases() async {
    if (_devModeEnabled) {
      debugPrint('DevMode: Purchases restored successfully');
      return true; // 開発モードでは常に成功を返す
    }
    
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
}
