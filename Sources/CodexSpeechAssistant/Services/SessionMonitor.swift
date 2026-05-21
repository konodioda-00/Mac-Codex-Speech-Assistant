import Foundation

@MainActor
final class SessionMonitor: ObservableObject {
    @Published private(set) var latestSessionPath: String?
    @Published private(set) var lastError: String?

    private let parser = SummaryParser()
    private var timer: Timer?
    private var spokenFingerprints = Set<String>()
    private var lastKnownFileSize: UInt64 = 0

    var onSummary: ((SpeechSummary) -> Void)?

    func start(sessionRootPath: String) {
        stop()
        lastError = nil
        scan(sessionRootPath: sessionRootPath)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scan(sessionRootPath: sessionRootPath)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func resetDeduplication() {
        spokenFingerprints.removeAll()
        lastKnownFileSize = 0
    }

    private func scan(sessionRootPath: String) {
        guard let latestURL = latestSessionFile(in: sessionRootPath) else {
            latestSessionPath = nil
            lastError = "没有找到 Codex 会话文件"
            return
        }

        if latestSessionPath != latestURL.path {
            latestSessionPath = latestURL.path
            lastKnownFileSize = 0
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: latestURL.path)
            let fileSize = attributes[.size] as? UInt64 ?? 0
            guard fileSize != lastKnownFileSize || lastKnownFileSize == 0 else {
                return
            }

            lastKnownFileSize = fileSize
            let content = try String(contentsOf: latestURL, encoding: .utf8)
            let summaries = parser.summaries(fromSessionFileContent: content)
            for summary in summaries {
                let fingerprint = "\(latestURL.path)::\(summary)"
                guard !spokenFingerprints.contains(fingerprint) else {
                    continue
                }
                spokenFingerprints.insert(fingerprint)
                onSummary?(SpeechSummary(text: summary, sourcePath: latestURL.path))
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func latestSessionFile(in rootPath: String) -> URL? {
        let rootURL = URL(fileURLWithPath: NSString(string: rootPath).expandingTildeInPath)
        guard let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        var latest: (url: URL, date: Date)?
        for case let url as URL in enumerator where url.pathExtension == "jsonl" {
            guard let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey]),
                  values.isRegularFile == true,
                  let date = values.contentModificationDate else {
                continue
            }

            if latest == nil || date > latest!.date {
                latest = (url, date)
            }
        }

        return latest?.url
    }
}
