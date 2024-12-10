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
    private let playingPosition: TimeInterval

    @State private var progress = 0.0

    /// The total duration of the lyrics line animation, calculated from the last time tag
    private var timeTagDuration: TimeInterval {
        guard let lastTag = lyricsLine.attachments.timetag?.tags.last else { return 0 }
        return lastTag.time
    }

    /// Creates a new karaoke lyrics view
    /// - Parameters:
    ///   - lyricsLine: The lyrics line to display and animate
    ///   - position: The current playback position relative to the line start
    public init(
        lyricsLine: LyricsLine,
        playingPosition: TimeInterval
    ) {
        self.lyricsLine = lyricsLine
        self.playingPosition = playingPosition
    }

    /// Update the progress based on current position
    private func updateProgress(position: TimeInterval) {
        guard let timeTags = lyricsLine.attachments.timetag?.tags,
            !timeTags.isEmpty,
            timeTagDuration > 0
        else { return }
        
        let newProgress = calculateProgress(at: position, with: timeTags)
        
        // Don't animate when:
        // 1. Progress is resetting from 1 to 0 (line finished)
        // 2. Progress is jumping backwards (seeking)
        // 3. Progress is jumping forwards significantly (seeking)
        let shouldAnimate = !(progress == 1 && newProgress == 0) && // Not resetting
            !(newProgress < progress) && // Not seeking backwards
            !(newProgress - progress > 0.1) // Not seeking forwards significantly
        
        if shouldAnimate {
            withAnimation(.linear(duration: 0.1)) {
                progress = newProgress
            }
        } else {
            progress = newProgress
        }
    }

    /// Calculates the progress value for the current position
    private func calculateProgress(
        at position: Double, with timeTags: [LyricsLine.Attachments.InlineTimeTag.Tag]
    ) -> Double {
        // Convert position to relative time within the line
        let relativePosition = position - lyricsLine.position
        
        // If we're before the line start, return 0
        if relativePosition < 0 {
            return 0
        }
        
        // If we're at the next line, return 0
        if let nextLine = lyricsLine.nextLine() {
            if position >= nextLine.position {
                return 0
            }
        }
        
        // Find the last time tag that's before or at the current position
        var lastMatchIndex = 0
        for (index, tag) in timeTags.enumerated() {
            if tag.time > relativePosition {
                break
            }
            lastMatchIndex = index
        }
        
        // Calculate progress based on the last matching tag
        let lastTag = timeTags[lastMatchIndex]
        let lastTagTime = lastTag.time
        
        // If we're exactly at a tag, use its index directly
        if lastTagTime == relativePosition {
            return Double(lastMatchIndex + 1) / Double(timeTags.count)
        }
        
        // If we're between tags, interpolate between them
        if lastMatchIndex < timeTags.count - 1 {
            let nextTag = timeTags[lastMatchIndex + 1]
            let nextTagTime = nextTag.time
            
            // Calculate progress between the two tags
            let segmentProgress = (relativePosition - lastTagTime) / (nextTagTime - lastTagTime)
            let startProgress = Double(lastMatchIndex + 1) / Double(timeTags.count)
            let endProgress = Double(lastMatchIndex + 2) / Double(timeTags.count)

            return startProgress + (endProgress - startProgress) * segmentProgress
        }
        
        // If we're past the last tag, return 1
        return 1.0
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
                updateProgress(position: newValue)
            }
            .onAppear {
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
        KaraokeLyricsView(lyricsLine: lyricsLine, playingPosition: playingPosition)
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
    return KaraokeLyricsView(lyricsLine: line, playingPosition: line.position)
        .padding()
}

#Preview("Progress States") {
    let line = LyricsLine.previewLine()
    return VStack(spacing: 20) {
        KaraokeLyricsView(lyricsLine: line, playingPosition: line.position)

        KaraokeLyricsView(lyricsLine: line, playingPosition: line.position + 1.0)

        KaraokeLyricsView(lyricsLine: line, playingPosition: line.position + 3.0)

        KaraokeLyricsView(lyricsLine: line, playingPosition: line.position + 7.0)
    }
    .padding()
}

#Preview("Animation") {
    let line = LyricsLine.previewLine()
    return KaraokeLyricsPreview(lyricsLine: line, startPosition: line.position)
}
