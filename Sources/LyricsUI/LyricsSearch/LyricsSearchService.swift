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

public class LyricsSearchService {
    public var track: MusicTrack?

    private var provider: LyricsProviders.Group
    private var searchCanceller: AnyCancellable?

    public init(providers: [LyricsProviders.Service] = [.qq, .netease, .kugou], track: MusicTrack? = nil) {
        self.provider = .init(service: providers)
        self.track = track
    }

    /// Search lyrics with optional text and track info
    /// - Parameters:
    ///   - keyword: Search text, optional
    public func searchLyrics(keyword: String? = nil) async throws -> [Lyrics] {
        var searchText = keyword ?? ""
        if searchText.isEmpty {
            searchText = "\(track?.title ?? "") \(track?.artist ?? "")"
        }

        // if searchText is only whitespace, return empty array
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }

        let searchReq = LyricsSearchRequest(
            searchTerm: .keyword(searchText),
            duration: track?.duration ?? 0
        )

        return try await withCheckedThrowingContinuation { continuation in
            var results: [Lyrics] = []

            searchCanceller = provider.lyricsPublisher(request: searchReq)
                .timeout(.seconds(10), scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completionStatus in
                        switch completionStatus {
                        case .finished:
                            continuation.resume(returning: results)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { lyrics in
                        results.append(lyrics)
                    }
                )
        }
    }

    /// Cancel ongoing search
    public func cancelSearch() {
        searchCanceller?.cancel()
    }

    /// Pick the best lyrics from searchResults
    public func pickBestLyrics(from searchResults: [Lyrics], highQuality: Bool = false) -> Lyrics? {
        guard let track = track else { return nil }

        // 1. Perfect match (title + artist + album + duration)
        if let perfectMatch = searchResults.first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.idTags[.artist] == track.artist
                && lyrics.idTags[.album] == track.album && lyrics.length == track.duration
        }) {
            return perfectMatch
        }

        // 2. Near perfect match (title + artist + duration)
        if let nearPerfectMatch = searchResults.first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.idTags[.artist] == track.artist
                && lyrics.length == track.duration
        }) {
            return nearPerfectMatch
        }

        // Return nil if high quality match is required
        if highQuality {
            return nil
        }

        // 3. Title + album + duration match
        if let titleAlbumMatch = searchResults.first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.idTags[.album] == track.album
                && lyrics.length == track.duration
        }) {
            return titleAlbumMatch
        }

        // 4. Title + duration match
        if let titleDurationMatch = searchResults.first(where: { lyrics in
            lyrics.idTags[.title] == track.title && lyrics.length == track.duration
        }) {
            return titleDurationMatch
        }

        // 5. Duration match only
        if let durationMatch = searchResults.first(where: { lyrics in
            lyrics.length == track.duration
        }) {
            return durationMatch
        }

        // 6. Sort by quality if no matches found
        let sortedLyrics = searchResults.sorted { $0.quality > $1.quality }
        return sortedLyrics.first
    }
}
