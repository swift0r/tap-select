// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import ComposableArchitecture
import SwiftUI

struct MultiTouchMap: UIViewRepresentable {
    let store: StoreOf<SelectionFeature>

    func makeUIView(context: Context) -> MultiTouchView {
        let view = MultiTouchView(store: store)
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: MultiTouchView, context: Context) {
        uiView.store = store
    }
}

final class MultiTouchView: UIView {
    var store: StoreOf<SelectionFeature>

    init(store: StoreOf<SelectionFeature>) {
        self.store = store
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { nil }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            store.send(.fingerAdded(uiTouchID: ObjectIdentifier(touch), location: touch.location(in: self)))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            store.send(.fingerMoved(uiTouchID: ObjectIdentifier(touch), location: touch.location(in: self)))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingersRemoved(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingersRemoved(touches)
    }

    private func fingersRemoved(_ touches: Set<UITouch>) {
        for touch in touches {
            store.send(.fingerRemoved(uiTouchID: ObjectIdentifier(touch)))
        }
    }
}
