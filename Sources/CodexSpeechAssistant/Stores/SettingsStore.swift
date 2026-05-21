import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @AppStorageCompat("monitoringEnabled", defaultValue: true)
    var monitoringEnabled: Bool

    @AppStorageCompat("sessionRootPath", defaultValue: NSString(string: "~/.codex/sessions").expandingTildeInPath)
    var sessionRootPath: String

    @AppStorageCompat("speechRate", defaultValue: 0.46)
    var speechRate: Double

    @AppStorageCompat("speechVolume", defaultValue: 0.9)
    var speechVolume: Double

    @AppStorageCompat("selectedVoiceIdentifier", defaultValue: "")
    var selectedVoiceIdentifier: String

    @AppStorageCompat("historyLimit", defaultValue: 20)
    var historyLimit: Int

    @AppStorageCompat("hotkeysEnabled", defaultValue: true)
    var hotkeysEnabled: Bool
}

@propertyWrapper
struct AppStorageCompat<Value> {
    private let key: String
    private let defaultValue: Value
    private let defaults: UserDefaults

    init(_ key: String, defaultValue: Value, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }

    var wrappedValue: Value {
        get {
            defaults.object(forKey: key) as? Value ?? defaultValue
        }
        nonmutating set {
            defaults.set(newValue, forKey: key)
        }
    }
}
