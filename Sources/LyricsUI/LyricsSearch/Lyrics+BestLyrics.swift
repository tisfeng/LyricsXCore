//
//  LyricsApp.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/26.
//

import Combine
import Foundation
import LyricsService
import MusicPlayer

extension [Lyrics] {
    /// Pick the best lyrics from searchResults
    public func pickBestLyrics(track: MusicTrack) -> Lyrics? {
        // QQ lyrics are almost the best if found
        if let qqLyrics = first(where: { $0.metadata.service == .qq }) {
            return qqLyrics
        }

        // 1. Perfect match (title + artist + album + duration)
        if let perfectMatch = first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.idTags[.artist] == track.artist
                && lyrics.idTags[.album] == track.album && lyrics.length == track.duration
        }) {
            return perfectMatch
        }

        // 2. Near perfect match (title + artist + duration)
        if let nearPerfectMatch = first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.idTags[.artist] == track.artist
                && lyrics.length == track.duration
        }) {
            return nearPerfectMatch
        }

        // 3. Title + album + duration match
        if let titleAlbumMatch = first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.idTags[.album] == track.album
                && lyrics.length == track.duration
        }) {
            return titleAlbumMatch
        }

        // 4. Title + duration match
        if let titleDurationMatch = first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.length == track.duration
        }) {
            return titleDurationMatch
        }

        // 5. Duration match only
        if let durationMatch = first(where: { lyrics in
            lyrics.length == track.duration
        }) {
            return durationMatch
        }

        // 6. Sort by quality if no matches found
        let sortedLyrics = sorted { $0.quality > $1.quality }
        return sortedLyrics.first
    }

}
