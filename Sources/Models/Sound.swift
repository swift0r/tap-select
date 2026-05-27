// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import Foundation

enum Sound: String {
    case add
    case remove
    case countdown
    case decision

    nonisolated var `extension`: String {
        switch self {
        case .add, .remove:
            "wav"
        case .countdown, .decision:
            "mp3"
        }
    }
}
