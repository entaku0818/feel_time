#!/bin/bash

# スクリーンショットテストを実行するスクリプト

# 必要なパッケージをインストール
echo "Flutter パッケージをインストール中..."
flutter pub get

# 統合テストを実行
echo "スクリーンショットテストを実行中..."
# デバイスを指定して実行
# 注意: 接続されているデバイスがない場合は、デバイス選択プロンプトが表示されます
flutter test integration_test/screenshot_test.dart

# 結果を表示
echo "テスト完了"
echo "スクリーンショットは各デバイスのDocumentsディレクトリ内のscreenshotsフォルダに保存されています"
echo "iOS: /Documents/screenshots/"
echo "Android: /data/user/0/com.entaku.timer_app/app_flutter/screenshots/"
# Webデバイスは統合テストではサポートされていません
