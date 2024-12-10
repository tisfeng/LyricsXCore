//
//  LyricsLineView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import LyricsCore

public struct LyricsLineView: View {
    
    public let line: LyricsLine
    public let showTranslation: Bool
    public let isPlayingLine: Bool
    public let isPlaying: Bool
    public let position: TimeInterval

    public init(
        line: LyricsLine,
        showTranslation: Bool = true,
        isPlayingLine: Bool = false,
        isPlaying: Bool = false,
        position: TimeInterval
    ) {
        self.line = line
        self.showTranslation = showTranslation
        self.isPlayingLine = isPlayingLine
        self.isPlaying = isPlaying
        self.position = position
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            KaraokeLyricsView(
                lyricsLine: line,
                isPlayingLine: isPlayingLine,
                isPlaying: isPlaying,
                position: position
            )

            if showTranslation,
               let trans = line.attachments.translation() {
                Text(trans)
                    .font(Font.title2.weight(.medium))
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}

import LyricsUIPreviewSupport

struct LyricsLineView_Previews: PreviewProvider {
    
    static var previews: some View {
        return Group {
            LyricsLineView(
                line: PreviewResources.lyricsLine,
                showTranslation: true,
                isPlaying: true,
                position: 0
            )
                    .previewLayout(.sizeThatFits)
            
            LyricsLineView(
                line: PreviewResources.lyricsLine,
                showTranslation: false,
                isPlaying: false,
                position: 0
            )
                    .previewLayout(.sizeThatFits)
        }
    }
}
