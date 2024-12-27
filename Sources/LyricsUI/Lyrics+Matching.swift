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
    /// - Returns: A normalized score between 0 and 1
    public func calculateMatchingScore(track: MusicTrack) -> Double {
        // Define scoring weights
        let durationWeight: Double = 0.3
        let titleWeight: Double = 0.2
        let artistWeight: Double = 0.2
        let albumWeight: Double = 0.1
        let translationWeight: Double = 0.1
        let timeTagWeight: Double = 0.1
        
        var score: Double = 0
        var maxPossibleScore: Double = 0
        
        // Duration match (30%)
        if let lyricsLength = length, let duration = track.duration {
            maxPossibleScore += durationWeight
            if lyricsLength == duration {
                score += durationWeight  // Perfect duration match
            } else {
                // Calculate duration difference ratio (0-1)
                let durationDiff = abs(lyricsLength - duration)
                let durationRatio = Swift.max(0, 1 - (durationDiff / duration))
                score += durationWeight * durationRatio
            }
        }
        
        // Title match (20%)
        if let title = idTags[.title], let trackTitle = track.title {
            maxPossibleScore += titleWeight
            let titleSimilarity = title.similarity(to: trackTitle)
            score += titleWeight * titleSimilarity
        }
        
        // Artist match (20%)
        if let artist = idTags[.artist], let trackArtist = track.artist {
            maxPossibleScore += artistWeight
            let artistSimilarity = artist.similarity(to: trackArtist)
            score += artistWeight * artistSimilarity
        }
        
        // Album match (10%)
        if let album = idTags[.album], let trackAlbum = track.album {
            maxPossibleScore += albumWeight
            let albumSimilarity = album.similarity(to: trackAlbum)
            score += albumWeight * albumSimilarity
        }
        
        // Translation (10%)
        if metadata.hasTranslation {
            maxPossibleScore += translationWeight
            score += translationWeight
        }
        
        // Time tag (10%)
        if metadata.attachmentTags.contains(.timetag) {
            maxPossibleScore += timeTagWeight
            score += timeTagWeight
        }
        
        // Normalize score based on available matching criteria
        return maxPossibleScore > 0 ? Swift.min(score / maxPossibleScore, 1.0) : 0
    }
}

extension MusicTrack {
    public var searchText: String {
        [title, artist].compactMap { $0 }.joined(separator: " ")
    }
}
