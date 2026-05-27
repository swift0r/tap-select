// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import ComposableArchitecture
import Foundation
import StoreKitClient

struct SelectionFeature: Reducer {
    @Dependency(\.audioClient) private var audio
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.feedbackClient) private var feedback
    @Dependency(\.storeKitClient) private var storeKit
    @Dependency(\.uuid) private var uuid

    @ObservableState
    struct State: Equatable {
        var phase: AppPhase = .preparing
        var touches: [TouchPoint] = []
        var showAboutSheet: Bool = false
    }

    @CasePathable
    enum Action: Sendable {
        case countdownTick(Int)
        case detectionTimerFired
        case fingerAdded(uiTouchID: ObjectIdentifier, location: CGPoint)
        case fingerMoved(uiTouchID: ObjectIdentifier, location: CGPoint)
        case fingerRemoved(uiTouchID: ObjectIdentifier)
        case prepare
        case prepareFinished
        case selectionMade(id: UUID)
        case showAboutSheet(Bool)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            case let .countdownTick(value):
                state.phase = .countdown(value)
                state.touches = state.touches.map { $0.update(isPulsing: true) }
                return .run { _ in
                    await audio.playCountdown()
                    await feedback.light()
                }

            case .detectionTimerFired:
                guard state.phase == .collecting, state.touches.count > 1 else { return .none }
                let touches = state.touches
                return .run { send in
                    for tick in stride(from: 3, through: 1, by: -1) {
                        await send(.countdownTick(tick))
                        try await clock.sleep(for: .seconds(1))
                    }
                    guard let winner = touches.randomElement() else { return }
                    await send(.selectionMade(id: winner.id))
                }
                .cancellable(.countdown, cancelInFlight: true)

            case let .fingerAdded(uiTouchID, location):
                if state.phase.isSelectionFinished {
                    state = .init(phase: .collecting)
                }
                guard state.phase.isCollecting || state.phase.isCountdown,
                      state.touches.count < 5
                else { return .none }
                let wasCountingDown = state.phase.isCountdown
                if wasCountingDown {
                    state.phase = .collecting
                    state.touches = state.touches.map { $0.update(isPulsing: false) }
                }
                let id = uuid()
                state.touches.append(TouchPoint(id: id, uiTouchID: uiTouchID, position: location))
                return .merge(
                    .run { _ in
                        await audio.playAdd()
                    },
                    wasCountingDown
                        ? .concatenate(.cancel(.countdown), scheduleDetection())
                        : scheduleDetection()
                )
            
            case let .fingerMoved(uiTouchID, location):
                guard let index = state.touches.firstIndex(where: { $0.uiTouchID == uiTouchID })
                else { return .none }
                state.touches[index].position = location
                return .none

            case let .fingerRemoved(uiTouchID):
                switch state.phase {
                case .selectionFinished:
                    state.touches.removeAll { $0.uiTouchID == uiTouchID }
                    if state.touches.isEmpty { state = .init(phase: .collecting) }
                    return .run { _ in
                        await audio.playRemove()
                    }
                case .countdown:
                    guard state.touches.contains(where: { $0.uiTouchID == uiTouchID }) else { return .none }
                    state.touches.removeAll { $0.uiTouchID == uiTouchID }
                    state.phase = .collecting
                    state.touches = state.touches.map { $0.update(isPulsing: false) }
                    return .merge(
                        .run { _ in
                            await audio.playRemove()
                        },
                        state.touches.count < 2
                            ? .cancel(.countdown)
                            : .concatenate(.cancel(.countdown), scheduleDetection())
                    )
                default:
                    guard state.touches.contains(where: { $0.uiTouchID == uiTouchID }) else { return .none }
                    state.touches.removeAll { $0.uiTouchID == uiTouchID }
                    return .merge(
                        .run { _ in
                            await audio.playRemove()
                        },
                        state.touches.isEmpty ? .cancel(.detection) : .none
                    )
                }

            case .prepare:
                return .run { send in
                    await feedback.prepare()
                    await send(.prepareFinished)
                }

            case .prepareFinished:
                state.phase = .collecting
                return .none

            case let .selectionMade(id):
                state.phase = .selectionFinished(id)
                state.touches = state.touches.map { $0.update(all: $0.id == id) }
                return .run { _ in
                    await audio.playDecision()
                    await feedback.heavy()
                    try await clock.sleep(for: .seconds(1))
                    await storeKit.requestReview()
                }

            case let .showAboutSheet(value):
                state.showAboutSheet = value
                return .none
        }
    }

    private func scheduleDetection() -> Effect<Action> {
        .run { send in
            try await clock.sleep(for: .seconds(0.8))
            await send(.detectionTimerFired)
        }
        .cancellable(.detection, cancelInFlight: true)
    }
}
