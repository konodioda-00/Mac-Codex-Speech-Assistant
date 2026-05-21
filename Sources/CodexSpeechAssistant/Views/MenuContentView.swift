import AppKit
import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(appState.status.label, systemImage: appState.status.systemImage)

            if let path = appState.monitor.latestSessionPath {
                Text(shortPath(path))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = appState.monitor.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button(appState.settings.monitoringEnabled ? "关闭监听" : "开启监听") {
                appState.setMonitoring(!appState.settings.monitoringEnabled)
            }

            Button("重读上一段") {
                appState.repeatLast()
            }
            .disabled(appState.history.isEmpty)

            Button(appState.speech.isPaused ? "继续朗读" : "暂停朗读") {
                appState.togglePause()
            }
            .disabled(!appState.speech.isSpeaking)

            Button("停止朗读") {
                appState.stopSpeaking()
            }

            Divider()

            Button("聚焦 Codex") {
                appState.focusCodex()
            }

            Button("聚焦并开始听写") {
                appState.focusCodexAndStartDictation()
            }

            Button("检查辅助功能权限") {
                appState.accessibility.requestTrust()
            }

            Divider()

            Menu("最近摘要") {
                if appState.history.isEmpty {
                    Text("暂无摘要")
                } else {
                    ForEach(appState.history.prefix(20)) { item in
                        Button(item.text) {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(item.text, forType: .string)
                        }
                    }
                }
            }

            Button("设置...") {
                openSettings()
            }

            Button("退出") {
                NSApp.terminate(nil)
            }
        }
        .padding(.vertical, 4)
    }

    private func shortPath(_ path: String) -> String {
        let home = NSHomeDirectory()
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}
