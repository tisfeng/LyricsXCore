//
//  ContentView.swift
//  LyricsXCoreDemo
//
//  Created by tisfeng on 2024/11/23.
//

import ComposableArchitecture
import SwiftUI
import LyricsUIPreviewSupport
import LyricsXCore
import LyricsUI

struct ContentView: View {
    @State var isAutoScrollEnabled = true

    let store = Store(
        initialState: PreviewResources.coreState,
        reducer: Reducer(LyricsProgressingState.reduce)
            .optional()
            .pullback(
                state: \LyricsXCoreState.progressingState,
                action: /LyricsXCoreAction.progressingAction,
                environment: { $0 }),
        environment: .default)

    var body: some View {
        let viewStore = ViewStore(store)
        
        // Start progressing from current line
        viewStore.send(.progressingAction(.recalculateCurrentLineIndex))

        return LyricsView(isAutoScrollEnabled: $isAutoScrollEnabled) { position in
            print("Tap position: \(position)")
        }
        .environmentObject(viewStore)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
