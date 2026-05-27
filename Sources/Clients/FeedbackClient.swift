// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import DependenciesMacros
import Dependencies
import UIKit

@DependencyClient
struct FeedbackClient: Sendable {
    var prepare: @Sendable () async -> Void
    var light: @Sendable () async -> Void
    var heavy: @Sendable () async -> Void
}

extension FeedbackClient: DependencyKey {
    static let liveValue: Self = {
        let light = UIImpactFeedbackGenerator(style: .light)
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        return Self(
            prepare: {
                light.prepare()
                heavy.prepare()
            },
            light: { light.impactOccurred() },
            heavy: { heavy.impactOccurred() }
        )
    }()
}

extension FeedbackClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.noop
}

extension FeedbackClient {
    static let noop = Self(
        prepare: {},
        light: {},
        heavy: {}
    )
}

extension DependencyValues {
    var feedbackClient: FeedbackClient {
        get { self[FeedbackClient.self] }
        set { self[FeedbackClient.self] = newValue }
    }
}
