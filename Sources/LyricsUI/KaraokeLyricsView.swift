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
    @State private var progress: Double = 0
    @State private var timer: Timer?
    private let isAnimating: Bool
    
    /// The total duration of the lyrics line animation, calculated from the last time tag
    private var timeTagDuration: Double {
        guard let lastTag = lyricsLine.attachments.timetag?.tags.last else { return 0 }
        return lastTag.time
    }
    
    /// Creates a new karaoke lyrics view
    /// - Parameters:
    ///   - lyricsLine: The lyrics line to display and animate
    ///   - isAnimating: Whether the view should start animating immediately
    public init(lyricsLine: LyricsLine, isAnimating: Bool = true) {
        self.lyricsLine = lyricsLine
        self.isAnimating = isAnimating
    }
    
    /// Starts the karaoke animation
    public func startAnimation() {
        progress = 0
        timer?.invalidate()
        
        guard let timeTags = lyricsLine.attachments.timetag?.tags,
              !timeTags.isEmpty,
              timeTagDuration > 0 else { return }
        
        var elapsedTime: Double = 0
        let updateInterval = 0.1 // Animation update interval in seconds
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            elapsedTime += updateInterval
            let currentProgress = calculateProgress(at: elapsedTime, with: timeTags)
            
            withAnimation(.linear(duration: updateInterval)) {
                progress = currentProgress
            }
            
            if elapsedTime >= timeTagDuration {
                timer.invalidate()
            }
        }
    }
    
    /// Calculates the progress value for the current elapsed time
    /// - Parameters:
    ///   - elapsedTime: Current elapsed time in seconds
    ///   - timeTags: Array of time tags for the lyrics line
    /// - Returns: Progress value between 0 and 1
    private func calculateProgress(at elapsedTime: Double, with timeTags: [LyricsLine.Attachments.InlineTimeTag.Tag]) -> Double {
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
        
        return progress // Maintain current progress if no matching segment found
    }
    
    /// Stops the karaoke animation and resets progress
    public func stopAnimation() {
        timer?.invalidate()
        timer = nil
        progress = 0
    }
    
    /// Creates the base text view with common styling
    private var lyricstText: some View {
        Text(lyricsLine.content)
            .font(Font.title2.weight(.medium))
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
            .onDisappear {
                stopAnimation()
            }
            .onAppear {
                if isAnimating {
                    startAnimation()
                }
            }
            .onChange(of: isAnimating) { shouldAnimate in
                if shouldAnimate {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
    }
}

#Preview {
    var lyricsLine = LyricsLine(content: "一幽风飞散发披肩", position: 29.874)
    let timeTagStr = "<0,0><182,1><566,2><814,3><1126,4><1377,5><3003,6><3248,7><6504,8><6504>"
    lyricsLine.attachments.timetag = .init(timeTagStr)
    return KaraokeLyricsView(lyricsLine: lyricsLine, isAnimating: true)
}
