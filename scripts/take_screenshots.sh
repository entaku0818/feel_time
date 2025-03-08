#!/bin/bash

# 複数デバイスでスクリーンショットを自動取得するスクリプト

# jqコマンドの確認
if ! command -v jq &> /dev/null; then
    echo "jqコマンドが見つかりません。以下のコマンドでインストールしてください："
    echo "brew install jq"
    exit 1
fi

# Androidエミュレータの設定
# 実際のエミュレータIDは「flutter emulators」コマンドで確認してください
android_devices=$(cat << EOA
[
  {
    "id": "Pixel_6_API_33",
    "name": "Pixel_6_API_33"
  }
]
EOA
)

# iOSシミュレータの設定
# 実際のシミュレータIDは「xcrun simctl list devices」コマンドで確認してください
ios_devices=$(cat << EOI
[]
EOI
)

DEVICE_ID=""
DEVICE_NAME=""
SCREENSHOTS_DIR="fastlane/screenshots"

# スクリーンショット保存ディレクトリの作成
mkdir -p $SCREENSHOTS_DIR

echo "===== 複数デバイスでのスクリーンショット自動取得を開始します ====="

# Android
echo "===== Androidデバイスでのテスト開始 ====="
for android_device in $(echo $android_devices | jq -c '.[]'); do
  DEVICE_ID=$(echo $android_device | jq .id | sed -e 's/^"//' -e 's/"$//')
  DEVICE_NAME=$(echo $android_device | jq .name | sed -e 's/^"//' -e 's/"$//')

  echo "Androidデバイス $DEVICE_NAME ($DEVICE_ID) でテスト実行中..."
  
  # エミュレータを起動
  echo "エミュレータを起動しています..."
  flutter emulators --launch $DEVICE_ID
  sleep 15s
  
  # テスト実行
  echo "テストを実行しています..."
  flutter test integration_test/screenshot_test.dart --dart-define="DEVICE=$DEVICE_NAME"
  
  # スクリーンショットをコピー（必要に応じてパスを調整）
  echo "スクリーンショットをコピーしています..."
  # adb pull /data/user/0/com.entaku.timer_app/app_flutter/screenshots/ $SCREENSHOTS_DIR/$DEVICE_NAME/
  
  # エミュレータを終了
  echo "エミュレータを終了しています..."
  adb emu kill
  sleep 10s
done

# iOS
echo "===== iOSデバイスでのテスト開始 ====="
for ios_device in $(echo $ios_devices | jq -c '.[]'); do
  DEVICE_ID=$(echo $ios_device | jq .id | sed -e 's/^"//' -e 's/"$//')
  DEVICE_NAME=$(echo $ios_device | jq .name | sed -e 's/^"//' -e 's/"$//')

  echo "iOSデバイス $DEVICE_NAME ($DEVICE_ID) でテスト実行中..."
  
  # シミュレータを起動
  echo "シミュレータを起動しています..."
  open -a Simulator --args -CurrentDeviceUDID $DEVICE_ID
  sleep 15s
  
  # テスト実行
  echo "テストを実行しています..."
  flutter test integration_test/screenshot_test.dart --dart-define="DEVICE=$DEVICE_NAME"
  
  # スクリーンショットをコピー（必要に応じてパスを調整）
  echo "スクリーンショットをコピーしています..."
  # cp -R ~/Documents/screenshots/ $SCREENSHOTS_DIR/$DEVICE_NAME/
  
  # シミュレータを終了
  echo "シミュレータを終了しています..."
  killall "Simulator"
  sleep 10s
done

echo "===== 全てのスクリーンショット取得が完了しました ====="
echo "スクリーンショットは各デバイスのDocumentsディレクトリ内のscreenshotsフォルダに保存されています"
echo "必要に応じて ./scripts/copy_screenshots_to_fastlane.sh コマンドを使用してFastlaneディレクトリにコピーしてください"
  # シミュレータを終了
  echo "シミュレータを終了しています..."
  killall "Simulator"
  sleep 10s
done

echo "===== 全てのスクリーンショット取得が完了しました ====="
echo "スクリーンショットは各デバイスのDocumentsディレクトリ内のscreenshotsフォルダに保存されています"
echo "必要に応じて ./scripts/copy_screenshots_to_fastlane.sh コマンドを使用してFastlaneディレクトリにコピーしてください"
