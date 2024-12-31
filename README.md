# LyricsXCore

LyricsXCore is a powerful Swift package that provides core lyrics functionality for [LyricsX](https://github.com/ddddxxx/LyricsX), [LyricsX-iOS](https://github.com/ddddxxx/LyricsX-iOS), and [lyricsx-cli](https://github.com/ddddxxx/lyricsx-cli).

## Features

- **Lyrics Management**: Fetch, parse, and manage lyrics from multiple sources
- **Smart Matching**: Advanced lyrics matching algorithm with quality scoring
- **Time Synchronization**: Support for synchronized (LRC) lyrics
- **SwiftUI Components**: Ready-to-use views for displaying lyrics
  - `LyricsView`: Standard lyrics display
  - `KaraokeLyricsView`: Karaoke-style synchronized lyrics

## Installation

### Swift Package Manager

Add LyricsXCore to your project through Xcode or add it as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tisfeng/LyricsXCore.git", .upToNextMajor(from: "1.0.0"))
]
```

## Quick Start

```swift

struct ContentView: View {
    @State private var isAutoScrollEnabled = true

    private var viewStore = createViewStore(
        track: PreviewResources.track,
        lyrics: PreviewResources.lyrics
    )

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled) { index, proxy  in
                let position = viewStore.progressingState?.lyrics[index].position ?? 0
                seekTo(position: position, isPlaying: isPlaying)

                withAnimation(.easeInOut) {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
            .environmentObject(viewStore)
            .padding()
            .onAppear {
                seekTo(position: 0, isPlaying: true)
            }
        }
    }
}
```

## Core Components

- **LyricsKit**: Handles lyrics fetching, parsing, and management
- **MusicPlayer**: Provides music playback and track information
- **LyricsUI**: SwiftUI components for lyrics display

## Demo

Check out [LyricsXCoreDemo](LyricsXCoreDemo/) for a complete example of how to integrate and use LyricsXCore in your app.

![LyricsXCore Demo](https://raw.githubusercontent.com/tisfeng/ImageBed/main/uPic/tSN4U2.png)

## Requirements

- macOS 11.0+ / iOS 14.0+
- Swift 5.3+

## License

LyricsXCore is available under the [Mozilla Public License Version 2.0](LICENSE) license. 
