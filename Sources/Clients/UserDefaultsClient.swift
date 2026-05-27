// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct UserDefaultsClient: Sendable {
    enum Key: String {
        case selectionCount
    }

    var integerForKey: @Sendable (Key) -> Int = { _ in 0 }
    var setInteger: @Sendable (Int, Key) -> Void
}

extension UserDefaultsClient: DependencyKey {
    static let liveValue = Self(
        integerForKey: { UserDefaults.standard.integer(forKey: $0.rawValue) },
        setInteger: { UserDefaults.standard.set($0, forKey: $1.rawValue) }
    )
}

extension UserDefaultsClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.noop
}

extension UserDefaultsClient {
    static let noop = Self(
        integerForKey: { _ in 0 },
        setInteger: { _, _ in }
    )
}

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
