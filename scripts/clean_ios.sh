#!/bin/bash

# iOSビルドをクリーンするスクリプト

echo "iOSビルドをクリーンしています..."

# Podfileのロックファイルを削除
if [ -f "ios/Podfile.lock" ]; then
  rm ios/Podfile.lock
  echo "Podfile.lockを削除しました"
fi

# Podsディレクトリを削除
if [ -d "ios/Pods" ]; then
  rm -rf ios/Pods
  echo "Podsディレクトリを削除しました"
fi

# Flutter関連のキャッシュをクリーン
flutter clean
echo "Flutterキャッシュをクリーンしました"

# 依存関係を再取得
flutter pub get
echo "依存関係を再取得しました"

echo "iOSビルドのクリーンが完了しました"
