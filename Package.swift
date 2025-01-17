// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LyricsXCore",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "LyricsXCore",
            targets: ["LyricsXCore", "LyricsUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tisfeng/LyricsKit", .branchItem("dev")),
        .package(url: "https://github.com/tisfeng/MusicPlayer", .branchItem("dev")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMinor(from: "0.40.0")),
    ],
    targets: [
        .target(
            name: "LyricsXCore",
            dependencies: [
                "LyricsKit",
                "MusicPlayer",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "LyricsUI",
            dependencies: [
                "LyricsXCore",
                .target(name: "LyricsUIPreviewSupport" /* , condition: .when(configuration: [.debug]) */ )
            ]),
        .target(
            name: "LyricsUIPreviewSupport",
            dependencies: [
                "LyricsXCore",
            ] /* ,
            resources: [
                .copy("Resources")
            ] */ ),
    ]
)

/*

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }
}

extension ProcessInfo {

    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
}

import Foundation

if ProcessInfo.processInfo.combineImplementation == .combine {
    package.platforms = [.macOS(.v10_15), .iOS(.v13)]
}
 
 */
