// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import Foundation

enum AppPhase: Equatable, Sendable {
    case preparing
    case collecting
    case countdown(Int)
    case selectionFinished(UUID)

    var isPreparing: Bool { self == .preparing }
    var isCollecting: Bool { self == .collecting }
    var isCountdown: Bool { if case .countdown = self { true } else { false } }
    var isSelectionFinished: Bool { if case .selectionFinished = self { true } else { false } }
}
