//
//  File.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/12/11.
//

import Foundation
import LyricsCore

extension LyricsLine {
    var timeTags: [Attachments.InlineTimeTag.Tag] {
        attachments.timetag?.tags ?? []
    }

    var timeTagDuration: TimeInterval {
        timeTags.last?.time ?? 0
    }

    var lastTagIndex: Int {
        timeTags.last?.index ?? content.count
    }

    var maxPosition: TimeInterval {
        position + timeTagDuration
    }
}
