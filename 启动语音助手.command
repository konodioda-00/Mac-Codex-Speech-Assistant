#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "正在启动 Codex 语音摘要朗读助手..."
echo

./script/build_and_run.sh

echo
echo "已启动。请在 Mac 顶部菜单栏寻找耳朵或喇叭图标。"
echo "这个窗口可以关闭。"
read -r -p "按回车关闭窗口..." _
