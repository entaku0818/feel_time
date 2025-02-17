# Analog Timer

美しいアナログ時計インターフェースを持つシンプルなタイマーアプリ。

## 機能

- 最大60分までのタイマー設定
- アナログ時計風のインターフェース
- アラーム機能
- シンプルで直感的な操作

## 開発環境のセットアップ

1. 必要な依存関係をインストール:
```bash
flutter pub get
bundle install
```

2. iOSシミュレータで実行:
```bash
flutter run
```

## アプリストアへのデプロイ

### 前提条件

- Apple Developer Program アカウント
- Google Play Developer アカウント
- Fastlaneのインストール
- 必要な証明書とプロビジョニングプロファイル

### デプロイ手順

#### iOS

1. TestFlightへのベータ配布:
```bash
fastlane ios beta
```

2. App Storeへのリリース:
```bash
fastlane ios release
```

#### Android

1. Play Storeベータトラックへの配布:
```bash
fastlane android beta
```

2. Play Store本番トラックへのリリース:
```bash
fastlane android release
```

## プライバシーポリシー

プライバシーポリシーは[こちら](privacy_policy.md)をご覧ください。

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
