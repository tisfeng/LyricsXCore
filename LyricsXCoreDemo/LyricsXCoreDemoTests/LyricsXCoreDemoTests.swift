//
//  LyricsXCoreDemoTests.swift
//  LyricsXCoreDemoTests
//
//  Created by tisfeng on 2024/12/26.
//

import Testing
import LyricsService
import LyricsUI
import MusicPlayer

struct LyricsXCoreDemoTests {

    @Test func testLyricsSearchService() async throws {
        let track = MusicTrack(
            id: "1",
            title: "一生不变",
            album: "Purple Dream",
            artist: "李克勤",
            duration: 262
        )

        let service = LyricsSearchService()
        let lyricsList = try await service.searchLyrics(keyword: track.searchText)

        let bestLyrics = lyricsList.pickBestLyrics(track: track)
        #expect((bestLyrics?.metadata.service == .qq))

        let sortedLyrics = lyricsList.sortedByScore(for track: track)

        if let length = sortedLyrics.first?.length {
            #expect(Int(length) == 262)
        }
    }
}
