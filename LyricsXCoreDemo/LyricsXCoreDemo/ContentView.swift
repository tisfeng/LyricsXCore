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
    @State private var isPlaying = false

    @Environment(\.openWindow) var openWindow

    private var viewStore = createViewStore(
        track: PreviewResources.track,
        lyrics: PreviewResources.lyrics
    )

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled) { index, proxy  in
                let position = viewStore.progressingState?.lyrics[index].position ?? 0
                seekTo(position: position, isPlaying: isPlaying)

                withAnimation(.easeInOut) {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
            .environmentObject(viewStore)
            .padding()
            .onAppear {
                seekTo(position: 0, isPlaying: true)
            }
            .contextMenu {
                Button("Search Lyrics") {
                    openWindow(id: .searchLyrics)
                }
            }

            /// Controls for auto-scroll and play/pause, just for demo.
            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        withAnimation {
                            isAutoScrollEnabled.toggle()
                        }
                    }) {
                        Image(
                            systemName: isAutoScrollEnabled ? "lock.fill" : "lock.open.fill"
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
        }
    }

    /// Seek to position.
    private func seekTo(position: TimeInterval, isPlaying: Bool) {
        self.isPlaying = isPlaying

        let playbackState: PlaybackState = isPlaying ? .playing(time: position) : .paused(time: position)
        let updatedPlaybackState = LyricsProgressingAction.playbackStateUpdated(playbackState)
        viewStore.send(.progressingAction(updatedPlaybackState))
    }
}

#Preview {
    ContentView()
}
