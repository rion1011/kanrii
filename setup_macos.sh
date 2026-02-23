#!/bin/bash
# Xcode インストール後に一度だけ実行するセットアップスクリプト
set -e

echo "=== macOS 開発環境セットアップ ==="

# Xcode developer ディレクトリを設定
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# CocoaPods インストール
echo "CocoaPods をインストール中..."
sudo gem install cocoapods

# Flutter doctor 確認
echo ""
echo "=== Flutter Doctor ==="
flutter doctor

# macOS ビルド
echo ""
echo "=== macOS ビルド開始 ==="
cd "$(dirname "$0")"
flutter build macos --release

echo ""
echo "✓ ビルド完了"
echo "アプリ場所: build/macos/Build/Products/Release/checklist.app"
echo ""
echo "Dock への追加方法:"
echo "  cp -r build/macos/Build/Products/Release/checklist.app /Applications/"
echo "  open /Applications/checklist.app"
