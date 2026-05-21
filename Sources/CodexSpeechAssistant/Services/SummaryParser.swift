import Foundation

struct SummaryParser {
    static let startMarker = "<<<CODEX_SPEAK>>>"
    static let endMarker = "<<<END_CODEX_SPEAK>>>"

    func summaries(fromSessionFileContent content: String) -> [String] {
        content
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { assistantText(fromJSONLine: String($0)) }
            .flatMap { summaries(fromAssistantText: $0) }
    }

    func summaries(fromAssistantText text: String) -> [String] {
        var results: [String] = []
        var searchStart = text.startIndex

        while let startRange = text.range(of: Self.startMarker, range: searchStart..<text.endIndex),
              let endRange = text.range(of: Self.endMarker, range: startRange.upperBound..<text.endIndex) {
            let rawSummary = text[startRange.upperBound..<endRange.lowerBound]
            let summary = clean(String(rawSummary))
            if !summary.isEmpty {
                results.append(summary)
            }
            searchStart = endRange.upperBound
        }

        return results
    }

    private func assistantText(fromJSONLine line: String) -> String? {
        guard let data = line.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        let type = object["type"] as? String
        guard let payload = object["payload"] as? [String: Any] else {
            return nil
        }

        if type == "response_item" {
            return textFromResponseItem(payload)
        }

        if type == "event_msg",
           payload["type"] as? String == "agent_message",
           let message = payload["message"] as? String {
            return message
        }

        return nil
    }

    private func textFromResponseItem(_ payload: [String: Any]) -> String? {
        guard payload["type"] as? String == "message",
              payload["role"] as? String == "assistant",
              let content = payload["content"] as? [[String: Any]] else {
            return nil
        }

        let parts = content.compactMap { item -> String? in
            if let text = item["text"] as? String {
                return text
            }
            if let text = item["output_text"] as? String {
                return text
            }
            return nil
        }

        return parts.isEmpty ? nil : parts.joined(separator: "\n")
    }

    private func clean(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
