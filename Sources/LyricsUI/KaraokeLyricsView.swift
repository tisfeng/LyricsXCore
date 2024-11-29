//
//  File.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/28.
//

import LyricsCore
import SwiftUI

public struct KaraokeLyricsView: View {
    public let lyricsLine: LyricsLine
    @State private var progress: Double = 0.0
    @State private var timer: Timer?

    private var timeTagDuration: Double {
        // 获取最后一个时间标签的时间
        if let lastTag = lyricsLine.attachments.timetag?.tags.last {
            return lastTag.time
        }
        return 0
    }

    public init(lyricsLine: LyricsLine) {
        self.lyricsLine = lyricsLine
    }

    public func startAnimation() {
        progress = 0
        timer?.invalidate()

        guard let timeTags = lyricsLine.attachments.timetag?.tags, !timeTags.isEmpty else { return }
        print("Time tags: \(timeTags)")

        let totalDuration = timeTagDuration
        guard totalDuration > 0 else { return }
        print("Total duration: \(totalDuration)")

        var elapsedTime: Double = 0

        // 使用时间标签来更新进度
        let updateInterval = 0.03  // 30fps
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            elapsedTime += updateInterval
            print("Elapsed time: \(elapsedTime)")

            // 找到当前时间对应的字符位置
            var currentProgress = 0.0

            // 如果时间还没到第一个标签，使用线性插值
            if elapsedTime < timeTags[0].time {
                currentProgress = 0.0
            }
            // 如果时间超过最后一个标签，设为最大进度
            else if elapsedTime >= timeTags.last!.time {
                currentProgress = 1.0
            }
            // 否则找到对应的时间区间
            else {
                for (index, tag) in timeTags.enumerated() {
                    guard index < timeTags.count - 1 else { break }
                    let nextTag = timeTags[index + 1]

                    if elapsedTime >= tag.time && elapsedTime < nextTag.time {
                        let segmentProgress = (elapsedTime - tag.time) / (nextTag.time - tag.time)
                        let startProgress = Double(tag.index) / Double(lyricsLine.content.count)
                        let endProgress = Double(nextTag.index) / Double(lyricsLine.content.count)
                        currentProgress =
                            startProgress + (endProgress - startProgress) * segmentProgress
                        break
                    }
                }
            }

            print("Current progress: \(currentProgress)")
            withAnimation(.linear(duration: updateInterval)) {
                progress = currentProgress
            }

            if elapsedTime >= totalDuration {
                timer.invalidate()
            }
        }
    }

    public func stopAnimation() {
        timer?.invalidate()
        timer = nil
        progress = 0
    }

    public var body: some View {
        ZStack {
            Text(lyricsLine.content)
                .foregroundColor(.gray.opacity(0.5))
                .font(Font.title2.weight(.medium))

            Text(lyricsLine.content)
                .foregroundColor(.green)
                .font(Font.title2.weight(.medium))
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                            .frame(width: geometry.size.width * progress)
                    }
                )
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onAppear {
            startAnimation()
        }
    }
}

#Preview {
    var lyricsLine = LyricsLine(content: "一幽风飞散发披肩", position: 29.874)
    // 添加时间标签
    let timeTagStr = "<0,0><182,1><566,2><814,3><1126,4><1377,5><3003,6><3248,7><6504,8><6504>"
    lyricsLine.attachments.timetag = LyricsLine.Attachments.InlineTimeTag(timeTagStr)
    return KaraokeLyricsView(lyricsLine: lyricsLine)
}
