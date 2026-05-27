// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import ComposableArchitecture

enum CancelID: String {
    case countdown
    case detection
}

extension Effect {
    static func cancel(_ id: CancelID) -> Self {
        .cancel(id: id)
    }

    func cancellable(_ id: CancelID, cancelInFlight: Bool = false) -> Self {
        self.cancellable(id: id, cancelInFlight: cancelInFlight)
    }
}
