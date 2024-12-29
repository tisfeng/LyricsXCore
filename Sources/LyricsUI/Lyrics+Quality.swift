//
//  Lyrics+Quality.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/26.
//

import Combine
import Foundation
import LyricsService
import MusicPlayer

extension [Lyrics] {
    /// Returns the lyrics with the highest quality score for the given track.
    /// The quality score is calculated using Lyrics.calculateQualityScore(for:).
    ///
    /// - Parameter track: The track to compare against
    /// - Returns: The best matching lyrics, or nil if the array is empty
    public func bestMatch(for track: MusicTrack) -> Lyrics? {
        rankedByQuality(for: track).first
    }

    /// Returns lyrics sorted by their quality score in descending order.
    /// The quality score is calculated using Lyrics.calculateQualityScore(for:).
    ///
    /// - Parameter track: The track to compare against
    /// - Returns: A sorted array of lyrics, from highest to lowest quality
    public func rankedByQuality(for track: MusicTrack) -> [Lyrics] {
        map { lyrics in
            (lyrics: lyrics, quality: lyrics.evaluateQuality(for: track))
        }
        .sorted { $0.quality > $1.quality }
        .map(\.lyrics)
    }
}

extension Lyrics {
    /// Evaluates how well these lyrics match the given track and returns a quality score.
    /// The score is calculated based on multiple criteria and stored in metadata.quality.
    ///
    /// Quality criteria and their weights:
    /// - Title match (25%): Text similarity between lyrics and track titles
    /// - Artist match (25%): Text similarity between lyrics and track artists
    /// - Duration match (25%): How closely the lyrics duration matches the track
    /// - Time tags (10%): Presence of synchronized timestamps
    /// - Translation (10%): Availability of translations
    /// - Album match (5%): Text similarity between lyrics and track albums
    ///
    /// - Parameter track: The track to evaluate against
    /// - Returns: A quality score between 0 and 1
    public func evaluateQuality(for track: MusicTrack) -> Double {
        // Scoring weights (sum = 1.0)
        enum Weight {
            static let title = 0.25
            static let artist = 0.25
            static let duration = 0.25
            static let timeTag = 0.10
            static let translation = 0.10
            static let album = 0.05
        }

        var quality: Double = 0

        // Title similarity (25%)
        if let title = idTags[.title], let trackTitle = track.title {
            quality += Weight.title * title.similarity(to: trackTitle)
        }

        // Artist similarity (25%)
        if let artist = idTags[.artist], let trackArtist = track.artist {
            quality += Weight.artist * artist.similarity(to: trackArtist)
        }

        // Duration match (25%)
        if let duration = track.duration {
            let lyricsLength = length ?? estimatedDuration // Fallback to estimated duration
            if let lyricsLength {
                quality += Weight.duration * lyricsLength.durationQuality(to: duration)
            }
        }

        // Enhanced features
        if metadata.attachmentTags.contains(.timetag) { quality += Weight.timeTag }      // Time tags (10%)
        if metadata.hasTranslation { quality += Weight.translation }                     // Translation (10%)

        // Album similarity (5%)
        if let album = idTags[.album], let trackAlbum = track.album {
            quality += Weight.album * album.similarity(to: trackAlbum)
        }

        // Cache quality score in metadata
        metadata.quality = quality
        return quality
    }
}

extension MusicTrack {
    /// Returns a search query string combining the track's title and artist.
    public var searchQuery: String {
        [title, artist].compactMap { $0 }.joined(separator: " ")
    }
}
