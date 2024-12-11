//
//  KaraokeLyricsView.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/28.
//

import LyricsCore
import SwiftUI

/// A view that displays karaoke-style animated lyrics with time-synchronized highlighting
public struct KaraokeLyricsView: View {
    private let lyricsLine: LyricsLine
    @Binding private var playingPosition: TimeInterval
    
    @State private var progress: Double = 0
    @State private var lastMatchIndex: Int = 0

    /// The total duration of the lyrics line animation, calculated from the last time tag
    private let timeTagDuration: TimeInterval
    private let timeTags: [LyricsLine.Attachments.InlineTimeTag.Tag]
    private let finalTagIndex: Int

    /// Creates a new karaoke lyrics view
    /// - Parameters:
    ///   - lyricsLine: The lyrics line to display and animate
    ///   - position: The current playback position relative to the line start
    public init(
        lyricsLine: LyricsLine,
        playingPosition: Binding<TimeInterval>
    ) {
        self.lyricsLine = lyricsLine
        self._playingPosition = playingPosition
        
        timeTags = lyricsLine.attachments.timetag?.tags ?? []
        timeTagDuration = timeTags.last?.time ?? 0
        finalTagIndex = timeTags.last?.index ?? lyricsLine.content.count
    }

    /// Update the progress based on current position
    private func updateProgress(position: TimeInterval) {
        progress = calculateProgress(at: position, with: timeTags)
    }

    /// Calculates the progress value for the current position in range 0...1
    /// - Parameters:
    ///   - position: The global playback position
    ///   - timeTags: Array of time tags containing timing and index information
    /// - Returns: Progress value between 0 and 1, representing the karaoke highlight progress
    private func calculateProgress(
        at position: Double,
        with timeTags: [LyricsLine.Attachments.InlineTimeTag.Tag]
    ) -> Double {
        // Convert position to relative time within the line
        let relativePosition = position - lyricsLine.position
        
        // If the position is before the line start, return 0
        if relativePosition < 0 {
            return 0
        }

        // If the position is at or after the next line start, return 0
        if let nextLine = lyricsLine.nextLine(), position >= nextLine.position {
            return 0
        }

        if timeTags.isEmpty { return 0 }

        var currentIndex = min(lastMatchIndex, timeTags.count - 1)
        
        if timeTags[currentIndex].time > relativePosition {
            while currentIndex > 0 && timeTags[currentIndex].time > relativePosition {
                currentIndex -= 1
            }
        } else {
            while currentIndex < timeTags.count - 1 && timeTags[currentIndex + 1].time <= relativePosition {
                currentIndex += 1
            }
        }
        
        lastMatchIndex = currentIndex
        
        let previousTag = timeTags[currentIndex]
        let previousTagTime = previousTag.time
        let previousTagIndex = previousTag.index
        
        // Handle the case when we're at or after the final tag
        if currentIndex == timeTags.count - 1 {
            // If we've passed the final tag time, show full progress
            // Otherwise, show progress up to the final tag's index
            return relativePosition >= previousTagTime
                ? 1.0 : Double(previousTagIndex) / Double(finalTagIndex)
        }

        // Get the next tag for interpolation
        let nextTag = timeTags[currentIndex + 1]
        let nextTagTime = nextTag.time
        let nextTagIndex = nextTag.index
        
        // Calculate progress by interpolating between the two tags:
        // 1. Calculate how far we are between the two tags (0...1)
        let segmentProgress = (relativePosition - previousTagTime) / (nextTagTime - previousTagTime)

        // 2. Interpolate between the two character indices
        let interpolationIndex =
            Double(previousTagIndex) + segmentProgress * Double(nextTagIndex - previousTagIndex)

        // 3. Normalize to 0...1 range using the final character index
        return interpolationIndex / Double(finalTagIndex)
    }

    /// Creates the base text view with common styling
    private var lyricstText: some View {
        Text(lyricsLine.content)
            .font(lyricsFont)
            .fixedSize(horizontal: true, vertical: false)
    }

    public var body: some View {
        lyricstText
            .overlay(
                GeometryReader { geometry in
                    lyricstText
                        .foregroundColor(.green)
                        .frame(
                            width: geometry.size.width * progress,
                            height: geometry.size.height,
                            alignment: .leading
                        )
                        .clipped()
                }
            )
            .opacity((progress > 0 && progress <= 1) ? 1 : 0.6)
            .onChange(of: playingPosition) { newValue in
//                print("onChange playingPosition: \(newValue)")
                updateProgress(position: newValue)
            }
            .onAppear {
//                print("onAppear playingPosition: \(playingPosition)")
                updateProgress(position: playingPosition)
            }
    }
}

// MARK: - Previews

extension LyricsLine {
    static func previewLine() -> LyricsLine {
        let position = 29.874
        var line = LyricsLine(content: "一幽风飞散发披肩", position: position)
        let timeTagStr =
            "[00:29.874][tt]<0,0><182,1><566,2><814,3><1126,4><1377,5><3003,6><3248,7><6504,8><6504>"
        line.attachments.timetag = .init(timeTagStr)
        return line
    }
}

// Preview helper view to simulate playback
struct KaraokeLyricsPreview: View {
    let lyricsLine: LyricsLine
    @State private var playingPosition: TimeInterval

    init(lyricsLine: LyricsLine, startPosition: TimeInterval) {
        self.lyricsLine = lyricsLine
        self._playingPosition = State(initialValue: startPosition)
    }

    var body: some View {
        KaraokeLyricsView(lyricsLine: lyricsLine, playingPosition: $playingPosition)
            .padding()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    playingPosition += 0.1
                    if let nextLine = lyricsLine.nextLine(), playingPosition >= nextLine.position {
                        playingPosition = lyricsLine.position
                    }
                }
            }
    }
}

#Preview("Static") {
    let line = LyricsLine.previewLine()
    return KaraokeLyricsView(lyricsLine: line, playingPosition: .constant(line.position))
        .padding()
}

#Preview("Progress States") {
    let line = LyricsLine.previewLine()
    return VStack(spacing: 20) {
        KaraokeLyricsView(lyricsLine: line, playingPosition: .constant(line.position))

        KaraokeLyricsView(lyricsLine: line, playingPosition: .constant(line.position + 1.0))

        KaraokeLyricsView(lyricsLine: line, playingPosition: .constant(line.position + 3.0))

        KaraokeLyricsView(lyricsLine: line, playingPosition: .constant(line.position + 7.0))
    }
    .padding()
}

#Preview("Animation") {
    let line = LyricsLine.previewLine()
    return KaraokeLyricsPreview(lyricsLine: line, startPosition: line.position)
}
