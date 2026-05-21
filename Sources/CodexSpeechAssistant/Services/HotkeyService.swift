import Carbon
import Foundation

@MainActor
final class HotkeyService {
    enum Action: UInt32 {
        case pauseResume = 1
        case repeatLast = 2
        case focusCodex = 3
        case dictate = 4
    }

    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?
    private var handler: ((Action) -> Void)?

    func register(handler: @escaping (Action) -> Void) {
        unregister()
        self.handler = handler

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )

            guard let userData,
                  let action = Action(rawValue: hotKeyID.id) else {
                return noErr
            }

            let service = Unmanaged<HotkeyService>.fromOpaque(userData).takeUnretainedValue()
            Task { @MainActor in
                service.handler?(action)
            }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)

        registerHotkey(action: .pauseResume, keyCode: UInt32(kVK_Space))
        registerHotkey(action: .repeatLast, keyCode: UInt32(kVK_ANSI_R))
        registerHotkey(action: .focusCodex, keyCode: UInt32(kVK_ANSI_C))
        registerHotkey(action: .dictate, keyCode: UInt32(kVK_ANSI_D))
    }

    func unregister() {
        for ref in hotKeyRefs {
            if let ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotKeyRefs.removeAll()

        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    private func registerHotkey(action: Action, keyCode: UInt32) {
        var hotKeyRef: EventHotKeyRef?
        var hotKeyID = EventHotKeyID(signature: OSType(0x43535841), id: action.rawValue)
        RegisterEventHotKey(keyCode, UInt32(optionKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        hotKeyRefs.append(hotKeyRef)
    }
}
