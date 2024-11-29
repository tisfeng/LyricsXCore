//
//  File.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/28.
//

import SwiftUI
import LyricsCore

public struct KaraokeLyricsView: View {
    public let lyricsLine: LyricsLine
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    private var timeTagDuration: Double {
        // 获取最后一个时间标签的时间
        if let lastTag = lyricsLine.attachments.timetag?.tags.last {
            return lastTag.time  // InlineTimeTag 已经处理了毫秒到秒的转换
        }
        return 0
    }

    public init(lyricsLine: LyricsLine) {
        self.lyricsLine = lyricsLine
    }

    public var body: some View {
        VStack {
            ZStack {
                Text(lyricsLine.content)
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.center)

                Text(lyricsLine.content)
                    .foregroundColor(.green)
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.center)
                    .mask(
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: geometry.size.width * progress)
                        }
                    )
            }

            Slider(value: $progress, in: 0...1)
                .padding()

            Button("播放动画") {
                progress = 0
                timer?.invalidate()
                
                guard let timeTags = lyricsLine.attachments.timetag?.tags, !timeTags.isEmpty else { return }
                
                let totalDuration = timeTagDuration
                guard totalDuration > 0 else { return }
                
                // 使用时间标签来更新进度
                let updateInterval = 0.03 // 30fps
                timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
                    let currentTime = progress * totalDuration
                    
                    // 找到当前时间对应的字符位置
                    var currentProgress = 0.0
                    for (index, tag) in timeTags.enumerated() {
                        if currentTime >= tag.time {
                            let nextTime = index < timeTags.count - 1 ? timeTags[index + 1].time : totalDuration
                            let tagProgress = Double(tag.index) / Double(lyricsLine.content.count)
                            let nextProgress = index < timeTags.count - 1 ? Double(timeTags[index + 1].index) / Double(lyricsLine.content.count) : 1.0
                            
                            // 计算当前字符内的插值进度
                            if currentTime < nextTime {
                                let percent = (currentTime - tag.time) / (nextTime - tag.time)
                                currentProgress = tagProgress + (nextProgress - tagProgress) * percent
                            }
                        }
                    }
                    
                    withAnimation(.linear(duration: updateInterval)) {
                        progress = min(progress + updateInterval / totalDuration, 1.0)
                    }
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            progress = 0.0
        }
        .onDisappear {
            timer?.invalidate()
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
