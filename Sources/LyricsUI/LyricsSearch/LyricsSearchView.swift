//
//  LyricsSearchView.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/11/23.
//

import Combine
import LyricsService
import MusicPlayer
import SwiftUI

@available(macOS 12.0, *)
public struct LyricsSearchView: View {
    var track: MusicTrack?
    let onLyricsSelected: ((Lyrics) -> Void)?

    @State private var searchText: String
    @State private var searchResults: [Lyrics] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var selectedLyricsDescription: String?

    private let searchService = LyricsSearchService()

    public init(track: MusicTrack?, onLyricsSelected: ((Lyrics) -> Void)? = nil) {
        self.track = track
        self.onLyricsSelected = onLyricsSelected

        let keywords = "\(track?.title ?? "") \(track?.artist ?? "")"
        _searchText = State(initialValue: keywords)
    }

    public var body: some View {
        VStack {
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    performSearch()
                }

            HSplitView {
                VStack {
                    if isLoading {
                        Spacer()
                        ProgressView()
                    } else {
                        Table(searchResults, selection: $selectedLyricsDescription) {
                            TableColumn("Source") { lyrics in
                                Text(lyrics.metadata.service?.rawValue ?? "Unknown")
                            }
                            TableColumn("Song") { lyrics in
                                Text(lyrics.idTags[.title] ?? "Unknown")
                            }
                            TableColumn("Artist") { lyrics in
                                Text(lyrics.idTags[.artist] ?? "Unknown")
                            }
                            TableColumn("Album") { lyrics in
                                Text(lyrics.idTags[.album] ?? "Unknown")
                            }
                            TableColumn("Duration") { lyrics in
                                if let length = lyrics.length {
                                    Text(formatTime(length))
                                } else {
                                    Text("Unknown")
                                }
                            }
                            TableColumn("Cover") { lyrics in
                                LazyVStack(alignment: .leading) {
                                    if let coverURL = lyrics.metadata.artworkURL {
                                        AsyncImage(url: coverURL) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    } else {
                                        Image(systemName: "music.note")
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                        }
                        .tableStyle(.inset)
                    }
                    Spacer()
                }
                .frame(minWidth: 650, maxWidth: .infinity)

                ScrollView {
                    VStack(alignment: .leading) {
                        if let lyrics = getSelectedLyrics(selectedLyricsDescription) {
                            Button("Use Lyrics") {
                                onLyricsSelected?(lyrics)
                            }
                            .padding()

                            if let service = lyrics.metadata.service {
                                Text(service.rawValue)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }

                            if let coverURL = lyrics.metadata.artworkURL {
                                AsyncImage(url: coverURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200, height: 200)

                                } placeholder: {
                                    ProgressView()
                                }
                                .padding(.horizontal)
                            }

                            Text(lyrics.description)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        } else {
                            Text("Select a song to view the lyrics")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
                .frame(minWidth: 250, maxWidth: .infinity)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.secondary.opacity(0.3))
            }
            .padding()

            if let error = error {
                Text("Search failed: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .frame(minWidth: 1000, minHeight: 600)
        .onAppear {
            performSearch()
        }
    }

    private func performSearch() {
        isLoading = true
        searchResults = []
        error = nil

        Task {
            do {
                searchResults = try await searchService.searchLyrics(keyword: searchText)
                isLoading = false
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    /// Get selected lyrics from searchResults
    private func getSelectedLyrics(_ lyricsDescription: String?) -> Lyrics? {
        return searchResults.first { $0.description == lyricsDescription?.description }
    }
}

/// Format time to "mm:ss", e.g. 123 -> "02:03"
func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%d:%02d", minutes, seconds)
}

extension Lyrics: @retroactive Identifiable {
    public var id: String { description }
}

extension DispatchQueue {
    static let lyricsQueue = DispatchQueue(label: "lyricsQueue")
}
