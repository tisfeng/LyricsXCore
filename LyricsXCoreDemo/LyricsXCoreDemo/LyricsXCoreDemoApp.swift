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

    @StateObject private var searchService = LyricsSearchService()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)

        Window(String.searchLyrics, id: .searchLyrics) {
            LyricsSearchView(searchService: searchService) { lyrics in
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
        await searchService.searchLyrics(with: track.searchQuery)

        let sortedLyricsList = searchService.lyricsList.rankedByQuality(for: track)
        searchService.lyricsList = sortedLyricsList
    }
}

extension String {
    static let searchLyrics = "Search Lyrics"
}
