//
//  LyricsSearchingModel.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import ComposableArchitecture
import LyricsService
import MusicPlayer
import Foundation

public struct LyricsSearchingState: Equatable {
    public let track: MusicTrack?
    public var searchResultSorted: [Lyrics] = []
    public var currentLyrics: Lyrics? = nil
    public var searchTerm: LyricsSearchRequest.SearchTerm? = nil
    
    public init(track: MusicTrack? = nil) {
        self.track = track
    }
    
    private mutating func setSearchTerm(_ term: LyricsSearchRequest.SearchTerm) -> LyricsSearchRequest {
        searchTerm = term
        return LyricsSearchRequest(searchTerm: term, duration: track?.duration ?? 0)
    }
    
    private mutating func clearPreviousSearch() {
        searchResultSorted = []
        currentLyrics = nil
        searchTerm = nil
    }
    
    public static func reduce(state: inout LyricsSearchingState, action: LyricsSearchingAction, env: LyricsSearchingEnvironment) -> Effect<LyricsSearchingAction, Never> {
        switch action {
        case .autoSearch:
            state.clearPreviousSearch()
            guard let title = state.track?.title, let artist = state.track?.artist else {
                state.searchTerm = nil
                return .none
            }
            let req = state.setSearchTerm(.info(title: title, artist: artist))
            return env.lyricsProvider.lyricsPublisher(request: req)
                .map { LyricsSearchingAction.lyricsReceived($0, isAuto: true) }
                .receive(on: env.uiSchedular)
                .eraseToEffect()
                .cancellable(id: state.track, cancelInFlight: true)
            
        case let .search(term: term):
            state.clearPreviousSearch()
            let req = state.setSearchTerm(term)
            return env.lyricsProvider.lyricsPublisher(request: req)
                .map { LyricsSearchingAction.lyricsReceived($0, isAuto: false) }
                .receive(on: env.uiSchedular)
                .eraseToEffect()
                .cancellable(id: state.track, cancelInFlight: true)
            
        case .clearPreviousSearch:
            state.clearPreviousSearch()
            return .cancel(id: state.track)
            
        case let .lyricsReceived(lyrics, isAuto):
            let idx = state.searchResultSorted.lastIndex { $0.quality < lyrics.quality } ?? state.searchResultSorted.endIndex
            defer {
                state.searchResultSorted.insert(lyrics, at: idx)
            }
            if isAuto, idx == state.searchResultSorted.startIndex {
                return Just(LyricsSearchingAction.setCurrentLyrics(lyrics))
                    .eraseToEffect()
            }
            return .none
            
        case let .setCurrentLyrics(lyrics):
            state.currentLyrics = lyrics
            return .none
        }
    }
}

public enum LyricsSearchingAction: Equatable {
    case autoSearch
    case search(term: LyricsSearchRequest.SearchTerm)
    case clearPreviousSearch
    case lyricsReceived(Lyrics, isAuto: Bool)
    case setCurrentLyrics(Lyrics)
}

public struct LyricsSearchingEnvironment {
    public let uiSchedular: DispatchQueue
    public let lyricsProvider: LyricsProvider
    
    public init(uiSchedular: DispatchQueue = .main, lyricsProvider: LyricsProvider = LyricsProviders.Group()) {
        self.uiSchedular = uiSchedular
        self.lyricsProvider = lyricsProvider
    }
}
