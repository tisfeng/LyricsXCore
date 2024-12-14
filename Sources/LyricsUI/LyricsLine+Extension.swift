//
//  LyricsLine+Extension.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/12/11.
//

import Foundation
import LyricsCore

/// The maximum duration of a line when no time tag is found
let lineMaxDuration = 10.0

public extension LyricsLine {
    var timeTags: [Attachments.InlineTimeTag.Tag] {
        attachments.timetag?.tags ?? []
    }

    var timeTagDuration: TimeInterval {
        timeTags.last?.time ?? 0
    }

    var lastTagIndex: Int {
        timeTags.last?.index ?? content.count
    }

    var lastLine: LyricsLine? {
        lyrics?.lastLine
    }

    var maxPosition: TimeInterval {
        let duration = timeTagDuration > 0 ? timeTagDuration : lineMaxDuration
        return position + duration
    }
}

public extension Lyrics {
    var lastLine: LyricsLine? {
        lines.last
    }

    var maxPosition: TimeInterval {
        lastLine?.maxPosition ?? 0
    }
}
