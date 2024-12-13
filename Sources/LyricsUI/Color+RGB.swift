//
//  File.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/12/13.
//

import SwiftUI

extension Color {

    init(_ rgb: UInt32) {
        self.init(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }

    init(_ r: UInt8, _ g: UInt8, _ b: UInt8) {
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0
        )
    }

    /// Create a color from a hex string, e.g. "#FF0000"
    init(_ hex: String) {
        var hex = hex
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(UInt32(rgb))
    }
}
