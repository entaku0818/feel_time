#!/bin/bash

# デバイスIDを取得するスクリプト

echo "===== 利用可能なデバイスIDを取得しています ====="

# Androidエミュレータの一覧を取得
echo ""
echo "===== Androidエミュレータ ====="
flutter emulators

# iOSシミュレータの一覧を取得
echo ""
echo "===== iOSシミュレータ ====="
xcrun simctl list devices | grep -v "unavailable"

echo ""
echo "===== 使用方法 ====="
echo "1. scripts/take_screenshots.sh ファイル内の android_devices と ios_devices 変数を更新してください"
echo "2. Androidエミュレータの場合は「flutter emulators」の出力から ID を取得してください"
echo "3. iOSシミュレータの場合は「xcrun simctl list devices」の出力から UDID を取得してください"
echo ""
echo "例："
echo "android_devices=["
echo "  {"
echo "    \"id\": \"Pixel_4_API_30\","
echo "    \"name\": \"Pixel_4_6.3\""
echo "  }"
echo "]"
echo ""
echo "ios_devices=["
echo "  {"
echo "    \"id\": \"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX\","
echo "    \"name\": \"iPhone_13_6.1\""
echo "  }"
echo "]"
