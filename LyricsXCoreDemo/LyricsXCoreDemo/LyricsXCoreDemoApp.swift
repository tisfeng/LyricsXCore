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

            var lyricsLine = LyricsLine(content: "一幽风飞散发披肩", position: 29.874)
            // 添加时间标签
            let timeTagStr = "<0,0><182,1><566,2><814,3><1126,4><1377,5><3003,6><3248,7><6504,8><6504>"
            lyricsLine.attachments.timetag = LyricsLine.Attachments.InlineTimeTag(timeTagStr)
            return KaraokeLyricsView(lyricsLine: lyricsLine)
        }
    }
}
