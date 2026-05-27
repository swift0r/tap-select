// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import Foundation

struct TouchPoint: Identifiable, Equatable, Sendable {
    let id: UUID
    let uiTouchID: ObjectIdentifier
    var position: CGPoint
    var isPulsing: Bool = false
    var isSelected: Bool = false
    var isVisible: Bool = true

    func update(isPulsing: Bool) -> Self {
        var touchPoint = self
        touchPoint.isPulsing = isPulsing
        return touchPoint
    }

    func update(all value: Bool) -> Self {
        var touchPoint = self
        touchPoint.isPulsing = value
        touchPoint.isSelected = value
        touchPoint.isVisible = value
        return touchPoint
    }
}
