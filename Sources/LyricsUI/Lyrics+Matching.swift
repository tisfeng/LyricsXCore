//
//  Lyrics+Matching.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/26.
//

import Combine
import Foundation
import LyricsService
import MusicPlayer

extension [Lyrics] {
    /// Pick the best lyrics from the list of lyrics
    public func pickBestLyrics(track: MusicTrack) -> Lyrics? {
        // QQ lyrics are almost the best if found

        let qqLyrics = filter { $0.metadata.service == .qq }
        if !qqLyrics.isEmpty {
            // Find the best QQ lyrics
            if let bestQQ = qqLyrics.findBestMatchingLyrics(track: track) {
                return bestQQ
            }
        }

        // Find the best matching lyrics
        return findBestMatchingLyrics(track: track)
    }

    /// Find the best matching lyrics using a scoring system that considers:
    /// - Duration match (50 points)
    /// - Title match (30 points)
    /// - Artist match (15 points)
    /// - Album match (5 points)
    /// - Quality bonus (up to 10 points)
    public func findBestMatchingLyrics(track: MusicTrack) -> Lyrics? {
        return sortedByScore(track: track).first
    }

    /// Sort lyrics based on score
    public func sortedByScore(track: MusicTrack) -> [Lyrics] {
        // Calculate match score for each lyrics and sort by score
        let scoredLyrics = map { lyrics in
            (lyrics: lyrics, score: lyrics.calculateMatchingScore(track: track))
        }

        // Sort by score and return the best match
        return
            scoredLyrics
            .sorted { $0.score > $1.score }
            .map(\.lyrics)
    }
}

extension Lyrics {
    /// Calculate matching score for the lyrics based on various criteria
    /// - Parameters:
    ///   - track: The track to match against
    /// - Returns: A score between 0 and 100
    public func calculateMatchingScore(track: MusicTrack) -> Double {
        var score: Double = 0
        let maxScore: Double = 100

        // Duration match has the highest priority if exists
        if let lyricsLength = length, let duration = track.duration {
            if lyricsLength == duration {
                score += 50  // Duration exact match
            } else {
                // Calculate duration difference ratio (0-1)
                let durationDiff = abs(lyricsLength - duration)
                let durationRatio = Swift.max(0, 1 - (durationDiff / duration))
                score += 40 * durationRatio  // Up to 40 points for close duration match
            }
        }

        // Title match (30 points)
        if let title = idTags[.title], title == track.title {
            score += 30
        }

        // Artist match (15 points)
        if let artist = idTags[.artist], artist == track.artist {
            score += 15
        }

        // Album match (5 points)
        if let album = idTags[.album], album == track.album {
            score += 5
        }

        // Quality bonus (up to 10 points)
        score += Double(quality) * 10

        return Swift.min(score, maxScore)
    }
}
