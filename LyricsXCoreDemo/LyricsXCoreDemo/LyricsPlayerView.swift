//
//  LyricsPlayerView.swift
//  LyricsXCoreDemo
//
//  Created by tisfeng on 2024/11/23.
//

import ComposableArchitecture
import LyricsCore
import LyricsUI
import LyricsXCore
import MusicPlayer
import SwiftUI

private let timerInterval = 0.1

struct LyricsPlayerView: View {
    private let selectedPlayer = MusicPlayers.SystemMedia()

    @State private var musicTrack: MusicTrack?
    @State private var artwork = Image(systemName: "music.note")

    @State private var elapsedTime: Double = 0
    @State private var isPlaying = false

    @State private var isPresentedSheet = false

    @State var isAutoScrollEnabled = true

    @State var lyrics: Lyrics?

    private let timer = Timer.publish(every: timerInterval, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                artwork
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .blur(radius: 5)
                    .opacity(0.6)
                    .overlay(Color.black.opacity(0.5))
            }

            HStack {
                VStack(spacing: 20) {
                    Text(musicTrack?.title ?? "")
                        .font(.title)
                    Text((musicTrack?.artist ?? "") + " - " + (musicTrack?.album ?? ""))

                    HStack(spacing: 30) {
                        Button(action: {
                            selectedPlayer?.skipToPreviousItem()
                        }) {
                            Image(systemName: "backward.end")
                                .font(.system(size: 25))
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            selectedPlayer?.playPause()
                        }) {
                            Image(systemName: isPlaying ? "play.circle" : "pause.circle")
                                .font(.system(size: 30))
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            selectedPlayer?.skipToNextItem()
                        }) {
                            Image(systemName: "forward.end")
                                .font(.system(size: 25))
                        }
                        .buttonStyle(.plain)
                    }

                    let duration = musicTrack?.duration ?? 0

                    Slider(value: $elapsedTime, in: 0...duration) {
                    } minimumValueLabel: {
                        Text(formatTime(elapsedTime))
                            .font(.caption)
                            .padding(.horizontal, 5)
                    } maximumValueLabel: {
                        Text(formatTime(duration))
                            .font(.caption)
                            .padding(.horizontal, 5)
                    } onEditingChanged: { editing in
                        if !editing {
                            selectedPlayer?.playbackTime = elapsedTime
                        }
                    }
                    .frame(width: 250)
                }
                .padding(30)

                Spacer()
                    .frame(minWidth: 100)

                if let track = musicTrack, let lyrics = lyrics {
                    let coreState: LyricsXCoreState = {
                        let playbackState = PlaybackState.playing(time: elapsedTime)
                        let player = MusicPlayerState(
                            player: MusicPlayers.Virtual(track: track, state: playbackState))

                        var searching = LyricsSearchingState(track: track)
                        searching.currentLyrics = lyrics
                        searching.searchResultSorted = [lyrics]
                        if let title = track.title, let artist = track.artist {
                            searching.searchTerm = .info(title: title, artist: artist)
                        }

                        let progressing = LyricsProgressingState(
                            lyrics: lyrics, playbackState: playbackState)

                        return LyricsXCoreState(
                            playerState: player,
                            searchingState: searching,
                            progressingState: progressing
                        )
                    }()

                    let store = Store(
                        initialState: coreState,
                        reducer: Reducer(LyricsProgressingState.reduce)
                            .optional()
                            .pullback(
                                state: \LyricsXCoreState.progressingState,
                                action: /LyricsXCoreAction.progressingAction,
                                environment: { $0 }),
                        environment: .default)

                    let viewStore = ViewStore(store)

                    LyricsView(
                        isAutoScrollEnabled: $isAutoScrollEnabled, showTranslation: true
                    )
                    .environmentObject(viewStore)
                    .padding(.horizontal)
                    .frame(width: 400)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .padding()
        .environment(\.colorScheme, .dark)
        .onReceive(selectedPlayer!.$currentTrack) {
            if let track = $0 {
                musicTrack = track

                if let coverImage = $0?.artwork {
                    artwork = Image(nsImage: coverImage)
                } else {
                    artwork = Image(systemName: "music.note")
                }
            }
        }
        .onReceive(selectedPlayer!.$playbackState) {
            elapsedTime = $0.time
            isPlaying = $0.isPlaying
        }
        .onReceive(timer) { _ in
            if isPlaying {
                elapsedTime += timerInterval
            }
        }
        .sheet(isPresented: $isPresentedSheet) {
            let trackText = (musicTrack?.title ?? "") + " " + (musicTrack?.artist ?? "")
            SearchLyricsView(
                initialSearchText: trackText,
                onLyricsSelected: { selectedLyrics in
                    self.lyrics = selectedLyrics
                    isPresentedSheet = false
                }
            )
            .frame(minWidth: 1000, minHeight: 600)
            .overlay(
                Button(action: {
                    isPresentedSheet = false
                }) {
                    Image(systemName: "xmark")
                }
                .padding(7),
                alignment: .topTrailing
            )
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isPresentedSheet = true
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
}

/// Format time to "mm:ss", e.g. 123 -> "02:03"
 func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%d:%02d", minutes, seconds)
}

#Preview {
    LyricsPlayerView()
}
