//
//  LyricsView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import ComposableArchitecture
import LyricsCore
import LyricsUIPreviewSupport
import LyricsXCore
import SwiftUI
import Combine

let lyricsTextFont = Font.title2.weight(.medium)
let lyricsTextHighlightColor = Color.green

let updateTimerInterval = 0.1

@available(macOS 13.0, *)
public struct LyricsView: View {

    @EnvironmentObject public var coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>

    @Binding public var isAutoScrollEnabled: Bool
    public var showTranslation: Bool
    public let onLyricsTap: ((Int, ScrollViewProxy) -> Void)?

    @State private var elapsedTime = 0.0

    /// Timer for updating elapsed time
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    public init(
        isAutoScrollEnabled: Binding<Bool>,
        showTranslation: Bool = true,
        timer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil,
        onLyricsTap: ((Int, ScrollViewProxy) -> Void)? = nil
    ) {
        self._isAutoScrollEnabled = isAutoScrollEnabled
        self.showTranslation = showTranslation
        self.timer = timer ?? Timer.publish(every: updateTimerInterval, on: .main, in: .common).autoconnect()
        self.onLyricsTap = onLyricsTap
    }

    public var body: some View {
        if let progressing = coreStore.progressingState {
            let currentLineIndex = progressing.currentLineIndex
            let lyrics = progressing.lyrics
            let lyricsLines = lyrics.lines

            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    List {
                        halfHeightSpacer(geometry)

                        ForEach(lyricsLines.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 6) {
                                let line = lyricsLines[index]
                                KaraokeLyricsView(
                                    lyricsLine: line,
                                    lyrics: lyrics,
                                    elapsedTime: $elapsedTime)

                                if showTranslation,
                                   let trans = line.attachments.translation() {
                                    Text(trans)
                                        .font(lyricsTextFont)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .opacity(currentLineIndex == index ? 1 : 0.6)
                                }
                            }
                            .contentShape(Rectangle())  // Make the entire VStack tappable
                            .scaleEffect(
                                currentLineIndex == index ? 1 : 0.9,
                                anchor: .topLeading
                            )
                            .padding(.vertical, currentLineIndex == index ? 10 : 0)
                            .animation(.default, value: currentLineIndex == index)
                            .onTapGesture {
                                onLyricsTap?(index, scrollProxy)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                        halfHeightSpacer(geometry)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .scrollIndicators(.hidden)
                    .onChange(of: currentLineIndex) { index in
                        if let index, isAutoScrollEnabled {
                            scrollToIndex(index, proxy: scrollProxy)
                        }
                    }
                    .onChange(of: isAutoScrollEnabled) { enabled in
                        if enabled, let index = currentLineIndex {
                            scrollToIndex(index, proxy: scrollProxy)
                        }
                    }
                    .onChange(of: showTranslation) { _ in
                        if let index = currentLineIndex {
                            scrollToIndex(index, proxy: scrollProxy)
                        }
                    }
                    .onReceive(timer) { _ in
                        let playingTime = progressing.playbackState.time
                        let maxPosition = progressing.lyrics.maxPosition + timer.upstream.interval
                        if playingTime <= maxPosition {
                            elapsedTime = playingTime
                        }
                    }
                }
            }
        }
    }

    /// Half height spacer.
    private func halfHeightSpacer(_ geometry: GeometryProxy) -> some View {
        Spacer(minLength: geometry.size.height / 2)
    }

    /// Position at line index.
    private func position(at lineIndex: Int) -> TimeInterval? {
        if let progressing = coreStore.progressingState {
            let lyricsLines = progressing.lyrics.lines
            if lineIndex < lyricsLines.count {
                let position = lyricsLines[lineIndex].position
                return position
            }
        }
        return nil
    }

    /// Scroll to index with animation.
    private func scrollToIndex(_ index: Int, proxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            proxy.scrollTo(index, anchor: .center)
        }
    }
}

// MARK: - Preview

@available(macOS 13.0, *)
struct LyricsView_Previews: PreviewProvider {

    @State
    static var isAutoScrollEnabled = true

    static var previews: some View {
        let store = Store(
            initialState: PreviewResources.coreState,
            reducer: Reducer(LyricsProgressingState.reduce)
                .optional()
                .pullback(
                    state: \LyricsXCoreState.progressingState,
                    action: /LyricsXCoreAction.progressingAction,
                    environment: { $0 }),
            environment: .default)
        let viewStore = ViewStore(store)
        return Group {
            LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled, showTranslation: true)
                .environmentObject(viewStore)
                .padding()
                .background(Color.systemBackground)
                .environment(\.colorScheme, .dark)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
