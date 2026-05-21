import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var settings = SettingsStore()
    @Published var history: [SpeechSummary] = []

    let monitor = SessionMonitor()
    let speech = SpeechService()
    let accessibility = AccessibilityService()

    private let hotkeys = HotkeyService()

    var status: AssistantStatus {
        if speech.isPaused {
            return .paused
        }
        if speech.isSpeaking {
            return .speaking
        }
        if !settings.monitoringEnabled {
            return .stopped
        }
        return .monitoring
    }

    init() {
        normalizeSpeechSettings()

        monitor.onSummary = { [weak self] summary in
            self?.handle(summary: summary)
        }

        if settings.monitoringEnabled {
            monitor.start(sessionRootPath: settings.sessionRootPath)
        }

        if settings.hotkeysEnabled {
            registerHotkeys()
        }
    }

    func setMonitoring(_ enabled: Bool) {
        settings.monitoringEnabled = enabled
        if enabled {
            monitor.start(sessionRootPath: settings.sessionRootPath)
        } else {
            monitor.stop()
        }
        objectWillChange.send()
    }

    func restartMonitoring() {
        monitor.resetDeduplication()
        if settings.monitoringEnabled {
            monitor.start(sessionRootPath: settings.sessionRootPath)
        }
    }

    func updateHotkeys(enabled: Bool) {
        settings.hotkeysEnabled = enabled
        if enabled {
            registerHotkeys()
        } else {
            hotkeys.unregister()
        }
    }

    func repeatLast() {
        speech.repeatLast(
            voiceIdentifier: settings.selectedVoiceIdentifier,
            rate: settings.speechRate,
            volume: settings.speechVolume
        )
        objectWillChange.send()
    }

    func stopSpeaking() {
        speech.stop()
        objectWillChange.send()
    }

    func togglePause() {
        speech.togglePause()
        objectWillChange.send()
    }

    func focusCodex() {
        accessibility.focusCodex()
    }

    func focusCodexAndStartDictation() {
        accessibility.focusCodexAndStartDictation()
    }

    private func handle(summary: SpeechSummary) {
        history.insert(summary, at: 0)
        if history.count > settings.historyLimit {
            history.removeLast(history.count - settings.historyLimit)
        }

        speech.speak(
            summary.text,
            voiceIdentifier: settings.selectedVoiceIdentifier,
            rate: settings.speechRate,
            volume: settings.speechVolume
        )
        objectWillChange.send()
    }

    private func registerHotkeys() {
        hotkeys.register { [weak self] action in
            switch action {
            case .pauseResume:
                self?.togglePause()
            case .repeatLast:
                self?.repeatLast()
            case .focusCodex:
                self?.focusCodex()
            case .dictate:
                self?.focusCodexAndStartDictation()
            }
        }
    }

    private func normalizeSpeechSettings() {
        if settings.speechRate > 1.0 {
            settings.speechRate = 0.46
        }
    }
}
