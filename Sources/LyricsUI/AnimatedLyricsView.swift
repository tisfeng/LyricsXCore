//
//  File.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/28.
//

import SwiftUI

public struct AnimatedLyricsView: View {
    public let lyric: String
    public let duration: Double
    @State private var progress: Double = 0.0

    public init(lyric: String, duration: Double) {
        self.lyric = lyric
        self.duration = duration
    }

    public var body: some View {
        VStack {
            ZStack {
                // 背景歌词
                Text(lyric)
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.center)

                // 高亮歌词
                Text(lyric)
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
                withAnimation(.easeInOut(duration: 1)) {
                    progress = 1.0
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            progress = 0.0
        }
    }
}

#Preview {
    AnimatedLyricsView(lyric: "欲洁何曾洁，云空未必空。可怜金玉质，终陷淖泥中。", duration: 1)
}
