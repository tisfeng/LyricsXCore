//
//  LyricsLine+Extension.swift
//  LyricsXCore
//
//  Created by tisfeng on 2024/12/11.
//

import Foundation
import LyricsCore

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
        position + timeTagDuration
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
