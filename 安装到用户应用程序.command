#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="CodexSpeechAssistant"
SOURCE_APP="$PWD/dist/$APP_NAME.app"
TARGET_DIR="$HOME/Applications"
TARGET_APP="$TARGET_DIR/$APP_NAME.app"

echo "正在构建 Codex 语音摘要朗读助手..."
echo

./script/build_and_run.sh --verify || true

mkdir -p "$TARGET_DIR"
rm -rf "$TARGET_APP"
cp -R "$SOURCE_APP" "$TARGET_APP"

echo
echo "已安装到：$TARGET_APP"
echo "以后可以在访达的“应用程序”或 Spotlight 里搜索 CodexSpeechAssistant 打开。"
echo

/usr/bin/open "$TARGET_APP" || true

read -r -p "按回车关闭窗口..." _
