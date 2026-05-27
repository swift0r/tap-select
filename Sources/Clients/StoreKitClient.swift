// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import Dependencies
import DependenciesMacros
import StoreKit
import UIKit

@DependencyClient
struct StoreKitClient: Sendable {
    var requestReview: @Sendable () async -> Void
}

extension StoreKitClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            requestReview: {
                @Dependency(\.userDefaultsClient) var userDefaults
                let selectionCount = userDefaults.integerForKey(.selectionCount) + 1
                userDefaults.setInteger(selectionCount, .selectionCount)
                guard selectionCount % 5 == 0 else { return }
                await MainActor.run {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        AppStore.requestReview(in: windowScene)
                    }
                }
            }
        )
    }()
}

extension StoreKitClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.noop
}

extension StoreKitClient {
    static let noop = Self(requestReview: {})
}

extension DependencyValues {
    var storeKitClient: StoreKitClient {
        get { self[StoreKitClient.self] }
        set { self[StoreKitClient.self] = newValue }
    }
}
