//
//  File.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/12/20.
//

import ComposableArchitecture
import Foundation
import LyricsCore
import MusicPlayer

/// Creates a view store for the LyricsXCore.
/// - Parameters:
///   - track: The music track to display lyrics for.
///   - lyrics: The lyrics to display.
///   - elapsedTime: The current playback position relative to the start of the track.
///   - isPlaying: Whether the track is currently playing.
public func createViewStore(
    track: MusicTrack,
    lyrics: Lyrics,
    elapsedTime: TimeInterval = 0,
    isPlaying: Bool = false
) -> ViewStore<LyricsXCoreState, LyricsXCoreAction> {
    let playbackState = createPlaybackState(elapsedTime: elapsedTime, isPlaying: isPlaying)
    let player = MusicPlayerState(player: MusicPlayers.Virtual(track: track, state: playbackState))

    let searching = createSearchingState(track: track, lyrics: lyrics)
    let progressing = LyricsProgressingState(lyrics: lyrics, playbackState: playbackState)

    let coreState = LyricsXCoreState(
        playerState: player,
        searchingState: searching,
        progressingState: progressing
    )

    let store = Store(
        initialState: coreState,
        reducer: Reducer(LyricsProgressingState.reduce)
            .optional()
            .pullback(
                state: \LyricsXCoreState.progressingState,
                action: /LyricsXCoreAction.progressingAction,
                environment: { $0 }),
        environment: .default)

    return ViewStore(store)
}

private func createPlaybackState(elapsedTime: Double, isPlaying: Bool)
    -> MusicPlayer.PlaybackState
{
    isPlaying ? .playing(time: elapsedTime) : .paused(time: elapsedTime)
}

private func createSearchingState(track: MusicTrack, lyrics: Lyrics) -> LyricsSearchingState {
    var searching = LyricsSearchingState(track: track)
    searching.currentLyrics = lyrics
    searching.searchResultSorted = [lyrics]
    if let title = track.title, let artist = track.artist {
        searching.searchTerm = .info(title: title, artist: artist)
    }
    return searching
}
