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
    public let lyricsLine: LyricsLine
    private let isPlayingLine: Bool
    private let isPlaying: Bool
    @State private var elapsedTime: Double
    @State private var progress: Double = 0
    @State private var dispatchTimer: DispatchSourceTimer?

    /// The total duration of the lyrics line animation, calculated from the last time tag
    private var timeTagDuration: Double {
        guard let lastTag = lyricsLine.attachments.timetag?.tags.last else { return 0 }
        return lastTag.time
    }

    /// Creates a new karaoke lyrics view
    /// - Parameters:
    ///   - lyricsLine: The lyrics line to display and animate
    ///   - isPlayingLine: Whether this line is the currently playing line
    ///   - isPlaying: Whether the view should start playing immediately
    ///   - elapsedTime: The elapsed time for the current line
    public init(
        lyricsLine: LyricsLine,
        isPlayingLine: Bool = false,
        isPlaying: Bool = true,
        elapsedTime: Double = 0
    ) {
        self.lyricsLine = lyricsLine
        self.isPlayingLine = isPlayingLine
        self.isPlaying = isPlaying
        self._elapsedTime = State(initialValue: elapsedTime)
    }

    /// Starts the karaoke animation
    public func startAnimation() {
        // Clean up existing timer
        dispatchTimer?.cancel()
        dispatchTimer = nil

        guard let timeTags = lyricsLine.attachments.timetag?.tags,
            !timeTags.isEmpty,
            timeTagDuration > 0
        else { return }

        // Update initial progress based on elapsed time
        let currentProgress = calculateProgress(at: elapsedTime, with: timeTags)
        progress = currentProgress

        let updateInterval = 0.1  // Animation update interval in seconds

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(Int(updateInterval * 1000)))
        timer.setEventHandler {
            self.elapsedTime += updateInterval
            let currentProgress = calculateProgress(at: self.elapsedTime, with: timeTags)

            withAnimation(.linear(duration: updateInterval)) {
                progress = currentProgress
            }

            if let nextLine = self.lyricsLine.nextLine() {
                let currentStartTime = self.lyricsLine.position
                let nextLineStartTime = nextLine.position
                if self.lyricsLine.position + self.elapsedTime > nextLineStartTime {
                    self.stopAnimation()
                }
            }
        }
        dispatchTimer = timer
        timer.resume()
    }

    /// Calculates the progress value for the current elapsed time
    /// - Parameters:
    ///   - elapsedTime: Current elapsed time in seconds
    ///   - timeTags: Array of time tags for the lyrics line
    /// - Returns: Progress value between 0 and 1
    private func calculateProgress(
        at elapsedTime: Double, with timeTags: [LyricsLine.Attachments.InlineTimeTag.Tag]
    ) -> Double {
        // Before first tag
        if elapsedTime < timeTags[0].time {
            return 0.0
        }

        // After last tag
        if elapsedTime >= timeTags.last!.time {
            return 1.0
        }

        // Find the current time segment
        for (index, tag) in timeTags.enumerated() {
            guard index < timeTags.count - 1 else { break }
            let nextTag = timeTags[index + 1]

            if elapsedTime >= tag.time && elapsedTime < nextTag.time {
                let segmentProgress = (elapsedTime - tag.time) / (nextTag.time - tag.time)
                let startProgress = Double(tag.index) / Double(lyricsLine.content.count)
                let endProgress = Double(nextTag.index) / Double(lyricsLine.content.count)
                return startProgress + (endProgress - startProgress) * segmentProgress
            }
        }

        return progress  // Maintain current progress if no matching segment found
    }

    /// Stops the karaoke animation and resets progress
    public func stopAnimation() {
        dispatchTimer?.suspend()
        progress = 0
    }

    /// Pauses the karaoke animation
    public func pauseAnimation() {
        dispatchTimer?.suspend()
    }

    /// Resumes the karaoke animation
    public func resumeAnimation() {
        dispatchTimer?.resume()
    }

    /// Update animation state based on playing status
    public func updateAnimationState(isPlayingLine: Bool, isPlaying: Bool) {
        if !isPlayingLine {
            stopAnimation()
            return
        }

        if isPlaying {
            startAnimation()
        } else {
            pauseAnimation()
        }
    }

    /// Creates the base text view with common styling
    private var lyricstText: some View {
        Text(lyricsLine.content)
            .font(Font.title2.weight(.medium))
            .fixedSize(horizontal: true, vertical: false)
    }

    public var body: some View {
        lyricstText
            .overlay(
                lyricstText
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mask(
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: geometry.size.width * progress, alignment: .leading)
                        }
                    )
            )
            .onAppear {
                updateAnimationState(isPlayingLine: isPlayingLine, isPlaying: isPlaying)
            }
            .onChange(of: isPlayingLine) { newValue in
                updateAnimationState(isPlayingLine: newValue, isPlaying: isPlaying)
            }
            .onChange(of: isPlaying) { newValue in
                updateAnimationState(isPlayingLine: isPlayingLine, isPlaying: newValue)
            }
    }
}

#Preview {
    var lyricsLine = LyricsLine(content: "一幽风飞散发披肩", position: 29.874)
    let timeTagStr = "[00:29.874][tt]<0,0><182,1><566,2><814,3><1126,4><1377,5><3003,6><3248,7><6504,8><6504>"
    lyricsLine.attachments.timetag = .init(timeTagStr)
    return KaraokeLyricsView(lyricsLine: lyricsLine, isPlaying: true)
}
