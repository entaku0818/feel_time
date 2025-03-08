#!/bin/bash

# スクリーンショットをFastlaneディレクトリにコピーするスクリプト

# 引数チェック
if [ "$#" -ne 1 ]; then
    echo "使用方法: $0 <スクリーンショットのパス>"
    echo "例: $0 /path/to/screenshots"
    exit 1
fi

SCREENSHOTS_PATH=$1
FASTLANE_SCREENSHOTS_PATH="fastlane/screenshots"

# ディレクトリが存在するか確認
if [ ! -d "$SCREENSHOTS_PATH" ]; then
    echo "エラー: 指定されたディレクトリが存在しません: $SCREENSHOTS_PATH"
    exit 1
fi

# Fastlaneスクリーンショットディレクトリが存在するか確認
if [ ! -d "$FASTLANE_SCREENSHOTS_PATH" ]; then
    echo "Fastlaneスクリーンショットディレクトリを作成します..."
    mkdir -p "$FASTLANE_SCREENSHOTS_PATH"
fi

# スクリーンショットをコピー
echo "スクリーンショットをFastlaneディレクトリにコピーしています..."
cp -R "$SCREENSHOTS_PATH"/*.png "$FASTLANE_SCREENSHOTS_PATH"/

# 結果を表示
echo "コピー完了"
echo "スクリーンショットは $FASTLANE_SCREENSHOTS_PATH に保存されました"
ls -la "$FASTLANE_SCREENSHOTS_PATH"
