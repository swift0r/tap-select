// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import ComposableArchitecture
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(initialState: SelectionFeature.State()) {
        SelectionFeature()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        store.send(.prepare)
        return true
    }
}

@main
struct TapSelectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            SelectionView(store: appDelegate.store)
        }
    }
}
