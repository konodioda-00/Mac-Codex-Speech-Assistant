# Codex Speech Assistant

一个轻量级 macOS 菜单栏助手，用系统朗读功能读出 Codex 回答里的精炼摘要。

## Codex 输出约定

在 Codex 的项目规则或用户规则中加入：

```text
每次最终回答结尾添加一段 50-100 字中文精炼介绍，并用以下标记包裹：
<<<CODEX_SPEAK>>>
...
<<<END_CODEX_SPEAK>>>
```

应用只朗读这两个标记之间的文字。

## 运行

```bash
./script/build_and_run.sh
```

构建脚本会生成 `dist/CodexSpeechAssistant.app` 并启动菜单栏应用。
如果需要接入 Codex 的 Run 按钮，可以把 `codex-environment.example.toml` 的内容放到 `.codex/environments/environment.toml`。

更方便的方式：

- 双击 `启动语音助手.command`：自动构建并启动菜单栏助手。
- 双击 `安装到用户应用程序.command`：安装到 `~/Applications/CodexSpeechAssistant.app`，以后可以用 Spotlight 搜索打开。
- 启动后可以把菜单栏助手保持后台运行，不需要每次打开终端。

## 快捷键

- `Option + Space`：暂停或继续朗读
- `Option + R`：重读上一段摘要
- `Option + C`：聚焦 Codex
- `Option + D`：聚焦 Codex 并触发系统听写

聚焦和听写辅助需要在 macOS 系统设置中授予辅助功能权限。朗读和会话文件监听不需要麦克风权限，也不需要网络。
