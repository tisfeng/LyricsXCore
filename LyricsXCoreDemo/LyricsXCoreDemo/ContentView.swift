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

        // Start progressing from current line
        viewStore.send(.progressingAction(.recalculateCurrentLineIndex))

        return LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled) { position in
            seekTo(position: position)
            print("Tap position: \(position)")
        }
        .environmentObject(viewStore)
        .padding(.horizontal)
    }

    /// Seek to position.
    public func seekTo(position: TimeInterval) {
        if let progressing = viewStore.progressingState {
            if progressing.lyrics.lineIndex(at: position) != nil {
                let playbackState = playbackState(at: position)
                let action = LyricsProgressingAction.playbackStateUpdated(playbackState)
                viewStore.send(.progressingAction(action))
            }
        }
    }

    /// Play back state at position.
    public func playbackState(at position: TimeInterval) -> MusicPlayer.PlaybackState {
        if let isPlaying = viewStore.progressingState?.playbackState.isPlaying {
            return isPlaying ? .playing(time: position) : .paused(time: position)
        }
        return .paused(time: position)
    }
}

#Preview {
    ContentView()
}
