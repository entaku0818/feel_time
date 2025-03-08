# スクリーンショットテストの使用方法

このドキュメントでは、アプリのスクリーンショットを自動的に生成するためのテスト機能の使用方法について説明します。

## 概要

スクリーンショットテストは、アプリの様々な状態のスクリーンショットを自動的に生成するための機能です。これにより、App StoreやGoogle Playに掲載するためのスクリーンショットを簡単に作成できます。

## 複数デバイスでの自動スクリーンショット取得

このプロジェクトでは、複数のエミュレータ/シミュレータで自動的にスクリーンショットを取得する機能も実装しています。これにより、様々な画面サイズでのアプリの表示を効率的にチェックできます。

### 使用方法

1. デバイスIDの取得
   ```bash
   ./scripts/get_device_ids.sh
   ```
   このコマンドを実行すると、利用可能なAndroidエミュレータとiOSシミュレータの一覧が表示されます。

2. スクリプトの設定
   `scripts/take_screenshots.sh` ファイルを開き、`android_devices` と `ios_devices` 変数を、使用したいデバイスのIDと名前で更新します。

3. スクリーンショットの取得
   ```bash
   ./scripts/take_screenshots.sh
   ```
   このコマンドを実行すると、設定したすべてのデバイスで順番にアプリが起動し、スクリーンショットが自動的に取得されます。

## 必要なパッケージ

以下のパッケージが必要です（すでにpubspec.yamlに追加されています）：

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  screenshot: ^2.1.0
  path_provider: ^2.1.1
```

## スクリーンショットテストの実行方法

### 方法1: スクリプトを使用する

提供されているスクリプトを使用して、スクリーンショットテストを実行できます：

```bash
./scripts/run_screenshot_tests.sh
```

このスクリプトは接続されているデバイスでテストを実行します。デバイスが接続されていない場合は、デバイス選択プロンプトが表示されます。

### 方法2: コマンドを直接実行する

```bash
# デバイスを自動選択（接続されているデバイスがない場合は選択プロンプトが表示されます）
flutter test integration_test/screenshot_test.dart

# または特定のデバイスを指定
flutter test -d [デバイスID] integration_test/screenshot_test.dart
```

### 方法3: Fastlaneを使用する

Fastlaneを使用してスクリーンショットを生成することもできます：

```bash
# iOSのスクリーンショットを生成
fastlane ios flutter_screenshots

# Androidのスクリーンショットを生成
fastlane android flutter_screenshots
```

## スクリーンショットの保存場所

スクリーンショットは各デバイスのDocumentsディレクトリ内の`screenshots`フォルダに保存されます：

- iOS: `/Documents/screenshots/`
- Android: `/data/user/0/com.entaku.timer_app/app_flutter/screenshots/`

注意: Webデバイス（Chrome）は統合テストではサポートされていません。

### Fastlaneディレクトリへのコピー

スクリーンショットをFastlaneディレクトリにコピーするには、以下のスクリプトを使用します：

```bash
./scripts/copy_screenshots_to_fastlane.sh /path/to/screenshots
```

例：
```bash
# iOSの場合
./scripts/copy_screenshots_to_fastlane.sh ~/Documents/screenshots

# Androidの場合（エミュレータからファイルを取得した後）
./scripts/copy_screenshots_to_fastlane.sh ~/Downloads/screenshots
```

これにより、スクリーンショットが`fastlane/screenshots`ディレクトリにコピーされ、Fastlaneを使用してApp StoreやGoogle Playにアップロードできるようになります。

## 生成されるスクリーンショット

現在のテストでは、以下の4つのスクリーンショットが生成されます：

1. `home_screen.png` - アプリの初期状態
2. `timer_30min.png` - 30分タイマーが設定された状態
3. `timer_running.png` - タイマーが実行中の状態
4. `alarm_enabled.png` - アラームが有効化された状態

## カスタマイズ

スクリーンショットテストをカスタマイズするには、`integration_test/screenshot_test.dart`ファイルを編集します。以下のような変更が可能です：

- 異なるアプリの状態のスクリーンショットを追加
- 異なるデバイスサイズでのスクリーンショットを生成
- 異なる言語でのスクリーンショットを生成

## トラブルシューティング

### スクリーンショットが生成されない場合

- デバイスやエミュレータが正しく接続されていることを確認してください
- アプリがデバイス上で正常に動作することを確認してください
- ログを確認して、エラーメッセージがないか確認してください
- デバイス選択プロンプトが表示される場合は、特定のデバイスIDを指定してください（例: `-d emulator-5554`）

### スクリーンショットの品質が低い場合

- `MediaQueryData`の`size`パラメータを調整して、より高解像度のスクリーンショットを生成できます
- デバイスの画面解像度に合わせて調整してください
