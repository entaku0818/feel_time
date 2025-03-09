#!/bin/bash

# スクリーンショットのプレースホルダーを生成するスクリプト

# ディレクトリの作成
mkdir -p fastlane/screenshots

# デバイス名の配列
DEVICES=("iphone_14_pro" "iphone_14" "iphone_8_plus" "ipad_pro_12_9" "pixel_6")

# スクリーンショット名の配列
SCREENSHOTS=("home_screen" "timer_30min" "timer_running" "alarm_enabled")

# 各デバイスとスクリーンショットの組み合わせでプレースホルダーを生成
for device in "${DEVICES[@]}"; do
  for screenshot in "${SCREENSHOTS[@]}"; do
    # プレースホルダー画像の生成（白い背景に黒いテキスト）
    convert -size 1080x1920 xc:white -gravity center -pointsize 40 \
      -annotate 0 "Analog Timer\n\n$device\n$screenshot" \
      "fastlane/screenshots/${device}_${screenshot}.png"
    
    echo "Generated: fastlane/screenshots/${device}_${screenshot}.png"
  done
done

echo "All placeholder screenshots generated successfully!"
