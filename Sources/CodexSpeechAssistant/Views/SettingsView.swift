import AVFoundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section("监听") {
                Toggle("启动后自动监听", isOn: Binding(
                    get: { appState.settings.monitoringEnabled },
                    set: { appState.setMonitoring($0) }
                ))

                TextField("Codex 会话目录", text: Binding(
                    get: { appState.settings.sessionRootPath },
                    set: {
                        appState.settings.sessionRootPath = $0
                        appState.restartMonitoring()
                    }
                ))

                Stepper("历史数量：\(appState.settings.historyLimit)", value: Binding(
                    get: { appState.settings.historyLimit },
                    set: { appState.settings.historyLimit = $0 }
                ), in: 5...50)
            }

            Section("朗读") {
                Picker("系统语音", selection: Binding(
                    get: { appState.settings.selectedVoiceIdentifier },
                    set: { appState.settings.selectedVoiceIdentifier = $0 }
                )) {
                    Text("自动选择中文语音").tag("")
                    ForEach(appState.speech.availableVoiceOptions) { voice in
                        Text(voiceLabel(voice)).tag(voice.id)
                    }
                }

                Slider(value: Binding(
                    get: { appState.settings.speechRate },
                    set: { appState.settings.speechRate = $0 }
                ), in: 0.3...0.62) {
                    Text("语速")
                }

                Slider(value: Binding(
                    get: { appState.settings.speechVolume },
                    set: { appState.settings.speechVolume = $0 }
                ), in: 0.1...1.0) {
                    Text("音量")
                }

                HStack {
                    Button("试听") {
                        appState.speech.speak(
                            "这是 Codex 语音摘要朗读助手的试听。",
                            voiceIdentifier: appState.settings.selectedVoiceIdentifier,
                            rate: appState.settings.speechRate,
                            volume: appState.settings.speechVolume
                        )
                    }
                    Button("停止") {
                        appState.stopSpeaking()
                    }
                }
            }

            Section("快捷键") {
                Toggle("启用全局快捷键", isOn: Binding(
                    get: { appState.settings.hotkeysEnabled },
                    set: { appState.updateHotkeys(enabled: $0) }
                ))
                Text("Option + Space 暂停/继续，Option + R 重读，Option + C 聚焦 Codex，Option + D 聚焦并开始听写。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Codex 输出标记") {
                Text(SummaryParser.startMarker)
                    .font(.system(.body, design: .monospaced))
                Text(SummaryParser.endMarker)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 520)
    }

    private func voiceLabel(_ voice: SpeechVoiceOption) -> String {
        "\(voice.name) (\(voice.language))"
    }
}
