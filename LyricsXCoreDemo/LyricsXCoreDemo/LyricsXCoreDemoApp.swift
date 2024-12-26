//
//  LyricsXCoreDemoApp.swift
//  LyricsXCoreDemo
//
//  Created by tisfeng on 2024/11/23.
//

import SwiftUI
import LyricsService

@main
struct LyricsXCoreDemoApp: App {
    @Environment(\.dismissWindow) var dismissWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)

        Window(String.searchLyrics, id: .searchLyrics) {
            LyricsSearchView(searchText: "一生不变 李克勤") { lyrics in
                dismissWindow(id: .searchLyrics)

                print(lyrics)
            }
        }
    }
}

extension String {
    static let searchLyrics = "Search Lyrics"
}
