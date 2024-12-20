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

    // We need lyricsLine.nextLine to determine if the line is playing, and lyricsLine.lyrics is weak, so we need to keep a strong reference for it.
    private let lyrics: Lyrics

    @Binding private var elapsedTime: TimeInterval

    @State private var progress: Double = 0
    @State private var lastMatchIndex: Int = 0
    @State private var isPlayingLine: Bool = false

    /// Creates a new karaoke lyrics view
    /// - Parameters:
    ///   - lyricsLine: The lyrics line to display and animate
    ///   - lyrics: The lyrics that contains this line
    ///   - elapsedTime: The current playback position relative to the line start
    public init(
        lyricsLine: LyricsLine,
        lyrics: Lyrics,
        elapsedTime: Binding<TimeInterval>
    ) {
        self.lyricsLine = lyricsLine
        self.lyrics = lyrics
        self._elapsedTime = elapsedTime
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
            .opacity((progress > 0) ? 1 : 0.6)
            .onChange(of: elapsedTime) { newValue in
                updateProgress(position: newValue)
            }
            .onAppear {
                updateProgress(position: elapsedTime)
            }
    }

    /// Creates the base text view with common styling
    private var lyricstText: some View {
        Text(lyricsLine.content)
            .font(lyricsTextFont)
            .fixedSize(horizontal: true, vertical: false)
    }

    /// Update the progress based on current position
    private func updateProgress(position: TimeInterval) {
        // If has beyond the last tag, return
        if let lastLine = lyricsLine.lastLine,
            position >= lastLine.maxPosition + updateTimerInterval
        {
            return
        }

        // Calculate the progress based on the current position
        progress = calculateProgress(at: position, with: lyricsLine.timeTags)
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

        isPlayingLine = isPlaying(line: lyricsLine, elapsedTime: position)

        // If lyrics line is not playing, return 0
        if !isPlayingLine {
            return 0
        }

        // If the playing line has no time tags, return 1
        if timeTags.isEmpty {
            return 1.0
        }

        // Calculate the progress based on the time tags

        // Find the current time tag index
        var currentIndex = min(lastMatchIndex, timeTags.count - 1)

        if timeTags[currentIndex].time > relativePosition {
            while currentIndex > 0 && timeTags[currentIndex].time > relativePosition {
                currentIndex -= 1
            }
        } else {
            while currentIndex < timeTags.count - 1
                && timeTags[currentIndex + 1].time <= relativePosition
            {
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
                ? 1.0 : Double(previousTagIndex) / Double(lyricsLine.lastTagIndex)
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
        return interpolationIndex / Double(lyricsLine.lastTagIndex)
    }

    /// Check if the lyrics line is playing
    private func isPlaying(line: LyricsLine, elapsedTime: TimeInterval) -> Bool {
        // If the elapsedTime is before the line start, return 0
        if elapsedTime - line.position < 0 {
            return false
        }

        // If the elapsedTime is at or after the next line start, return 0
        if let nextLine = line.nextLine(), elapsedTime >= nextLine.position {
            return false
        }

        return true
    }

}

// MARK: - Previews

let previewLineWithoutTags = LyricsLine(content: "一幽风飞散发披肩", position: 29.874)

let previewLine = {
    var line = previewLineWithoutTags
    let timeTagStr =
        "[00:29.874][tt]<0,0><182,1><566,2><814,3><1126,4><1377,5><3003,6><3248,7><6504,8><6504>"
    line.attachments.timetag = .init(timeTagStr)
    return line
}()

let lyrics = Lyrics(lines: [previewLine], idTags: [:])


// Preview helper view to simulate playback
struct KaraokeLyricsPreview: View {
    let lyricsLine: LyricsLine
    @State private var playingPosition: TimeInterval

    init(lyricsLine: LyricsLine, startPosition: TimeInterval) {
        self.lyricsLine = lyricsLine
        self._playingPosition = State(initialValue: startPosition)
    }

    var body: some View {
        KaraokeLyricsView(lyricsLine: lyricsLine, lyrics: lyrics, elapsedTime: $playingPosition)
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
    let line = previewLine
    return KaraokeLyricsView(
        lyricsLine: line, lyrics: lyrics, elapsedTime: .constant(line.position)
    )
    .padding()
}

#Preview("Progress States") {
    let line = previewLine
    return VStack(spacing: 20) {
        KaraokeLyricsView(lyricsLine: line, lyrics: lyrics, elapsedTime: .constant(line.position))

        KaraokeLyricsView(
            lyricsLine: line, lyrics: lyrics, elapsedTime: .constant(line.position + 1.0))

        KaraokeLyricsView(
            lyricsLine: line, lyrics: lyrics, elapsedTime: .constant(line.position + 3.0))

        KaraokeLyricsView(
            lyricsLine: line, lyrics: lyrics, elapsedTime: .constant(line.position + 7.0))
    }
    .padding()
}

#Preview("Animation") {
    let line = previewLine
    return KaraokeLyricsPreview(lyricsLine: line, startPosition: line.position)
}

#Preview("No Time Tags") {
    let line = previewLineWithoutTags
    return KaraokeLyricsView(
        lyricsLine: line, lyrics: lyrics, elapsedTime: .constant(line.position)
    )
    .padding()
}
