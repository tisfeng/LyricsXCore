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
import MusicPlayer
import SwiftUI

@available(macOS 13.0, *)
public struct LyricsView: View {

    @EnvironmentObject
    public var coreStore: ViewStore<LyricsXCoreState, LyricsXCoreAction>

    @Binding
    public var isAutoScrollEnabled: Bool
    public var showTranslation: Bool
    public let onLyricsTap: ((TimeInterval) -> Void)?
    private let showLockButton: Bool

    @State var isPlaying = true

    public init(
        isAutoScrollEnabled: Binding<Bool>,
        showLockButton: Bool = true,
        showTranslation: Bool = true,
        onLyricsTap: ((TimeInterval) -> Void)? = nil
    ) {
        self._isAutoScrollEnabled = isAutoScrollEnabled
        self.showLockButton = showLockButton
        self.showTranslation = showTranslation
        self.onLyricsTap = onLyricsTap
    }

//    var lyricsLine: LyricsLine {
//        var lyricsLine = lyricsLines[index]
//        lyricsLine.lyrics = progressing.lyrics
//        return lyricsLine
//
//    }

    func lyricsLine(at index: Int) -> LyricsLine? {
        if let progressing = coreStore.progressingState {
            var lyricsLine = progressing.lyrics[index]
            lyricsLine.lyrics = progressing.lyrics
            return lyricsLine
        }
        return nil
    }

    public var body: some View {
        if let progressing = coreStore.progressingState {
            let currentLineIndex = progressing.currentLineIndex
            let lyricsLines = progressing.lyrics.lines

            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ZStack(alignment: .topTrailing) {
                        List {
                            addHalfHeightSpacer(geometry)

                            ForEach(lyricsLines.indices, id: \.self) { index in
                                LyricsLineView(
                                    line: lyricsLine(at: index)!,
                                    showTranslation: showTranslation,
                                    isPlayingLine: currentLineIndex == index,
                                    isPlaying: isPlaying
                                )
                                .opacity(currentLineIndex == index ? 1 : 0.6)
                                .scaleEffect(
                                    currentLineIndex == index ? 1 : 0.9,
                                    anchor: .topLeading
                                )
                                .padding(.vertical, currentLineIndex == index ? 10 : 0)
                                .animation(.default, value: currentLineIndex == index)
                                .onTapGesture {
                                    scrollToIndex(index, proxy: scrollProxy)

                                    if let position = position(at: index) {
                                        onLyricsTap?(position)
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                            addHalfHeightSpacer(geometry)
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

                        VStack {
                            if showLockButton {
                                Button(action: {
                                    withAnimation {
                                        isAutoScrollEnabled.toggle()
                                    }
                                }) {
                                    Image(
                                        systemName: isAutoScrollEnabled
                                        ? "lock.fill" : "lock.open.fill"
                                    )
                                    .font(.title3)
                                    .foregroundColor(isAutoScrollEnabled ? .blue : .gray)
                                }
                                .buttonStyle(.plain)
                                .padding(.top)
                            }

                            Button(action: {
                                withAnimation {
                                    isPlaying.toggle()

                                    let position = progressing.playbackState.time
                                    coreStore.send(.progressingAction(.playbackStateUpdated(
                                        isPlaying ? .playing(time: position) : .paused(time: position)
                                    )))
                                }
                            }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title3)
                                    .foregroundColor(isPlaying ? .blue : .gray)
                            }
                            .buttonStyle(.plain)
                            .padding(.top)
                        }
                    }
                }
            }
        }
    }

    /// Add half height spacer.
    private func addHalfHeightSpacer(_ geometry: GeometryProxy) -> some View {
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
