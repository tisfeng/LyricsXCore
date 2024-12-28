//
//  LyricsXCoreDemoApp.swift
//  LyricsXCoreDemo
//
//  Created by tisfeng on 2024/11/23.
//

import LyricsService
import MusicPlayer
import SwiftUI

@main
struct LyricsXCoreDemoApp: App {
    @Environment(\.dismissWindow) var dismissWindow

    let track = MusicTrack(
        id: "1",
        title: "一生不变",
        album: "Purple Dream",
        artist: "李克勤",
        duration: 262
    )

    @StateObject private var searchState = SearchState()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)

        Window(String.searchLyrics, id: .searchLyrics) {
            LyricsSearchView(searchState: searchState) { lyrics in
                dismissWindow(id: .searchLyrics)
                print(lyrics)
            }
            .task {
                await searchLyrics()
            }
        }
    }

    /// Start searching lyrics
    func searchLyrics() async {
        searchState.searchText = track.searchText
        await searchState.performSearch()

        let sortedLyricsList = searchState.lyricsList.sortedByScore(track: track)

        searchState.lyricsList = sortedLyricsList.map { lyrics in
            lyrics.metadata[Lyrics.Metadata.Key("quality")] = lyrics.calculateMatchingScore(track: track)
            return lyrics
        }
    }
}

extension String {
    static let searchLyrics = "Search Lyrics"
}
