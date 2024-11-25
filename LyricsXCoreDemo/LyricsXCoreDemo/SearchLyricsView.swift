//
//  SearchLyricsView.swift
//  LyricsXCoreDemo
//
//  Created by tisfeng on 2024/11/23.
//

import Combine
import LyricsService
import SwiftUI

struct SearchLyricsView: View {
    @State private var searchText: String
    let onLyricsSelected: (Lyrics) -> Void

    @State private var searchResults: [Lyrics] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State public var selectedLyricsDescription: String?

    private var provider: LyricsProviders.Group = .init(service: [.qq, .netease, .kugou])
    private var searchCanceller = SearchCanceller()

    init(initialSearchText: String, onLyricsSelected: @escaping (Lyrics) -> Void) {
        _searchText = State(initialValue: initialSearchText)
        self.onLyricsSelected = onLyricsSelected
    }

    var body: some View {
        VStack {
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    searchLyrics()
                }

            HSplitView {
                VStack {
                    if isLoading {
                        ProgressView()
                    } else {
                        Table(searchResults, selection: $selectedLyricsDescription) {
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
                            TableColumn("Source") { lyrics in
                                Text(lyrics.metadata.service?.rawValue ?? "Unknown")
                            }
                        }
                        .tableStyle(.inset)
                    }
                    Spacer()
                }
                .frame(minWidth: 400, maxWidth: .infinity)

                ScrollView {
                    VStack(alignment: .leading) {
                        if let selectedLyricsDescription, let lyrics = Lyrics(selectedLyricsDescription) {
                            if let coverURL = lyrics.metadata.artworkURL {
                                AsyncImage(url: coverURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200, height: 200)

                                } placeholder: {
                                    ProgressView()
                                }
                                .padding()
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
                .frame(minWidth: 300, maxWidth: .infinity)
            }
            .padding()

            if let error = error {
                Text("Search failed: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            searchLyrics()
        }
        .onChange(of: selectedLyricsDescription) { _, _ in
            if let description = selectedLyricsDescription, let lyrics = Lyrics(description) {
                selectLyrics(lyrics)
            }
        }
    }

    func searchLyrics() {
        guard !searchText.isEmpty else { return }

        let searchReq = LyricsSearchRequest(
            searchTerm: .keyword(searchText),
            duration: 0
        )

        isLoading = true
        searchResults = []
        error = nil

        searchCanceller.cancellable = provider.lyricsPublisher(request: searchReq)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let err) = completion {
                        error = err
                    }
                },
                receiveValue: { lyrics in
                    searchResults.append(lyrics)
                }
            )
    }

    func selectLyrics(_ lyrics: Lyrics) {
        onLyricsSelected(lyrics)
    }
}

private class SearchCanceller {
    var cancellable: Cancellable?
}

extension Lyrics: @retroactive Identifiable {
    public var id: String { description }
}

#Preview {
    SearchLyricsView(
        initialSearchText: "一生不变 李克勤",
        onLyricsSelected: { lyrics in
            // Handle lyrics selection
        })
}
