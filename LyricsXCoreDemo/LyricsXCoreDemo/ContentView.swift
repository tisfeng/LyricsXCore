//
//  ContentView.swift
//  LyricsXCoreDemo
//
//  Created by tisfeng on 2024/11/23.
//

import ComposableArchitecture
import SwiftUI
import LyricsUIPreviewSupport
import LyricsXCore
import LyricsUI
import MusicPlayer

struct ContentView: View {
    @State private var isAutoScrollEnabled = true
    @State private var isPlaying = true

    private let store = Store(
        initialState: PreviewResources.coreState,
        reducer: Reducer(LyricsProgressingState.reduce)
            .optional()
            .pullback(
                state: \LyricsXCoreState.progressingState,
                action: /LyricsXCoreAction.progressingAction,
                environment: { $0 }),
        environment: .default)

    private var viewStore: ViewStore<LyricsXCoreState, LyricsXCoreAction> {
        ViewStore(store)
    }

    var body: some View {
        VStack {
            LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled) { index, proxy  in
                let position = viewStore.progressingState?.lyrics.lines[index].position ?? 0
                seekTo(position: position, isPlaying: isPlaying)

                withAnimation(.easeInOut) {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
            .environmentObject(viewStore)
            .padding(.horizontal)
            .onAppear {
                seekTo(position: 0, isPlaying: true)
            }
            Spacer()
        }
        .overlay(
            HStack {
                Spacer()
                VStack {
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

                    Button(action: {
                        withAnimation {
                            isPlaying.toggle()

                            let position = viewStore.progressingState?.playbackState.time ?? 0
                            seekTo(position: position, isPlaying: isPlaying)
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
            .padding()
            , alignment: .topTrailing
        )
    }

    /// Seek to position.
    public func seekTo(position: TimeInterval, isPlaying: Bool) {
        let playbackState: PlaybackState = isPlaying ? .playing(time: position) : .paused(time: position)
        let progressingAction = LyricsProgressingAction.playbackStateUpdated(playbackState)
        viewStore.send(.progressingAction(progressingAction))
    }
}

#Preview {
    ContentView()
}
