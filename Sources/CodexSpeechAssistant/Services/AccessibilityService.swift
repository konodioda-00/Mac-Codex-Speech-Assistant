import ApplicationServices
import AppKit
import Carbon
import Foundation

@MainActor
final class AccessibilityService: ObservableObject {
    @Published private(set) var isTrusted = AXIsProcessTrusted()

    func refreshTrustStatus() {
        isTrusted = AXIsProcessTrusted()
    }

    func requestTrust() {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        refreshTrustStatus()
    }

    func focusCodex() {
        let candidates = NSWorkspace.shared.runningApplications.filter { app in
            let name = app.localizedName?.lowercased() ?? ""
            let bundleID = app.bundleIdentifier?.lowercased() ?? ""
            return name.contains("codex") || bundleID.contains("codex")
        }

        candidates.first?.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
    }

    func focusCodexAndStartDictation() {
        focusCodex()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.sendFunctionFunctionDictationShortcut()
        }
    }

    private func sendFunctionFunctionDictationShortcut() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Function), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Function), keyDown: false)
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            let secondDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Function), keyDown: true)
            let secondUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Function), keyDown: false)
            secondDown?.post(tap: .cghidEventTap)
            secondUp?.post(tap: .cghidEventTap)
        }
    }
}
