// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodexSpeechAssistant",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CodexSpeechAssistant", targets: ["CodexSpeechAssistant"])
    ],
    targets: [
        .executableTarget(
            name: "CodexSpeechAssistant",
            path: "Sources/CodexSpeechAssistant"
        )
    ]
)
