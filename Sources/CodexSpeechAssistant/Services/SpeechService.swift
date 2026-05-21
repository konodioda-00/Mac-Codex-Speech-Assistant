import AVFoundation
import Foundation

struct SpeechVoiceOption: Identifiable, Hashable {
    let id: String
    let name: String
    let language: String
}

@MainActor
final class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking = false
    @Published private(set) var isPaused = false

    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenText: String?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .sorted { lhs, rhs in
                if lhs.language == rhs.language {
                    return lhs.name.localizedCompare(rhs.name) == .orderedAscending
                }
                return lhs.language.localizedCompare(rhs.language) == .orderedAscending
            }
    }

    var availableVoiceOptions: [SpeechVoiceOption] {
        availableVoices.map { voice in
            SpeechVoiceOption(id: voice.identifier, name: voice.name, language: voice.language)
        }
    }

    func speak(_ text: String, voiceIdentifier: String, rate: Double, volume: Double) {
        stop()
        lastSpokenText = text

        let utterance = AVSpeechUtterance(string: text)
        if !voiceIdentifier.isEmpty {
            utterance.voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
        } else if let chineseVoice = preferredChineseVoice() {
            utterance.voice = chineseVoice
        }

        utterance.rate = clampedRate(rate)
        utterance.volume = Float(min(max(volume, 0.1), 1.0))
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.08
        utterance.postUtteranceDelay = 0.05

        synthesizer.speak(utterance)
        isSpeaking = true
        isPaused = false
    }

    func repeatLast(voiceIdentifier: String, rate: Double, volume: Double) {
        guard let lastSpokenText else {
            return
        }
        speak(lastSpokenText, voiceIdentifier: voiceIdentifier, rate: rate, volume: volume)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        isPaused = false
    }

    func togglePause() {
        guard isSpeaking else {
            return
        }

        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
        } else {
            synthesizer.pauseSpeaking(at: .word)
            isPaused = true
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
        }
    }

    private func preferredChineseVoice() -> AVSpeechSynthesisVoice? {
        availableVoices.first { $0.language == "zh-CN" }
            ?? availableVoices.first { $0.language.hasPrefix("zh") }
    }

    private func clampedRate(_ rate: Double) -> Float {
        if rate > 1.0 {
            return 0.46
        }
        return Float(min(max(rate, 0.25), 0.65))
    }
}
