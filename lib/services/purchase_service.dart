import 'package:purchases_flutter/purchases_flutter.dart';

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
  static const String _apiKey = 'YOUR_REVENUECAT_API_KEY';
  static const String _monthlySubscriptionId = 'premium_monthly';
  static const String _yearlySubscriptionId = 'premium_yearly';

  // RevenueCatの初期化
  Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  // 利用可能な商品を取得
  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      
      return current?.availablePackages ?? [];
    } catch (e) {
      print('Error fetching offerings: $e');
      return [];
    }
  }

  // サブスクリプションの購入
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isPremium = customerInfo.entitlements.active.isNotEmpty;
      return isPremium;
    } catch (e) {
      print('Error making purchase: $e');
      return false;
    }
  }

  // 現在のサブスクリプション状態を確認
  Future<bool> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  // ユーザーIDの設定（Firebase認証と連携）
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  // 購入の復元
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
}
