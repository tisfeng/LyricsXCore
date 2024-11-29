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
    
    public let isCurrentLine: Bool
    
    @State private var karaokeView: KaraokeLyricsView?
    
    public init(line: LyricsLine, showTranslation: Bool = true, isCurrentLine: Bool = false) {
        self.line = line
        self.showTranslation = showTranslation
        self.isCurrentLine = isCurrentLine
    }
    
    public func startKaraokeAnimation() {
        karaokeView?.startAnimation()
    }
    
    public func stopKaraokeAnimation() {
        karaokeView?.stopAnimation()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            KaraokeLyricsView(lyricsLine: line)
                .onAppear {
                    karaokeView = KaraokeLyricsView(lyricsLine: line)

                    if isCurrentLine {
                        karaokeView?.startAnimation()
                    }
                }
                .onChange(of: isCurrentLine) { isCurrent in
                    if isCurrent {
                        karaokeView?.startAnimation()
                    } else {
                        karaokeView?.stopAnimation()
                    }
                }

//            Text(line.content)
//                .font(Font.title2.weight(.medium))

            if showTranslation,
               // TODO: language code candidate
               let trans = line.attachments.translation() {
                Text(trans)
                    .font(Font.title3.weight(.medium))
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
                isCurrentLine: true)
                    .previewLayout(.sizeThatFits)
            
            LyricsLineView(
                line: PreviewResources.lyricsLine,
                showTranslation: false,
                isCurrentLine: false)
                    .previewLayout(.sizeThatFits)
        }
    }
}
