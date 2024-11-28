//
//  LyricsXCoreDemoApp.swift
//  LyricsXCoreDemo
//
//  Created by tisfeng on 2024/11/23.
//

import SwiftUI
import LyricsXCore
import LyricsUI
import LyricsCore

@main
struct LyricsXCoreDemoApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()

            let lyricsLine = LyricsLine(content: "欲洁何曾洁，云空未必空。可怜金玉质，终陷淖泥中。", position: 0)
            AnimatedLyricsView(lyricsLine: lyricsLine)
        }
    }
}
