import Foundation

struct SpeechSummary: Identifiable, Equatable {
    let id: UUID
    let text: String
    let sourcePath: String
    let createdAt: Date

    init(text: String, sourcePath: String, createdAt: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.sourcePath = sourcePath
        self.createdAt = createdAt
    }
}

enum AssistantStatus {
    case monitoring
    case speaking
    case paused
    case stopped
    case needsAccessibility
    case error

    var systemImage: String {
        switch self {
        case .monitoring:
            "ear"
        case .speaking:
            "speaker.wave.2.fill"
        case .paused:
            "pause.circle"
        case .stopped:
            "speaker.slash"
        case .needsAccessibility:
            "exclamationmark.triangle"
        case .error:
            "xmark.octagon"
        }
    }

    var label: String {
        switch self {
        case .monitoring:
            "监听中"
        case .speaking:
            "朗读中"
        case .paused:
            "已暂停"
        case .stopped:
            "已停止"
        case .needsAccessibility:
            "需要辅助功能权限"
        case .error:
            "出现错误"
        }
    }
}
