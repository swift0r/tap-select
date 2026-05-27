// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import ComposableArchitecture
import Foundation
import StoreKitClient
import Testing

@testable import TapSelect

@MainActor
struct SelectionFeatureTests {

    // MARK: - Tests

    @Test func addingFingerAppendsTouch() async {
        let audioSpy = AudioSpy()

        let touch = TouchMock(uuid: UUID(0))
        let store = TestStoreOf<SelectionFeature>() {
            $0.audioClient = audioSpy.client()
        }

        await store.send(.fingerAdded(uiTouchID: touch.id, location: touch.position)) {
            $0.touches = [touch.point]
        }
        
        #expect(audioSpy.playAddCount == 1)
    }

    @Test func removingFingerRemovesTouch() async {
        let audioSpy = AudioSpy()

        let touch = TouchMock(uuid: UUID(0))
        let store = TestStore(initialState: .init(touches: [touch.point])) {
            $0.audioClient = audioSpy.client()
        }

        await store.send(.fingerRemoved(uiTouchID: touch.id)) {
            $0.touches = []
        }
        
        #expect(audioSpy.playRemoveCount == 1)
    }

    @Test func movingFingerUpdatesPosition() async {
        let touch = TouchMock(uuid: UUID(0))
        let store = TestStoreOf<SelectionFeature>(initialState: .init(touches: [touch.point]))

        await store.send(.fingerMoved(uiTouchID: touch.id, location: .init(x: 20, y: 20))) {
            $0.touches[0].position = .init(x: 20, y: 20)
        }
    }

    @Test func detectionTimerDoesNotFireWithSingleFinger() async {
        let audioSpy = AudioSpy()
        let clock = TestClock()
        
        let touch = TouchMock(uuid: UUID(0))
        let store = TestStoreOf<SelectionFeature>(clock: clock) {
            $0.audioClient = audioSpy.client()
        }

        await store.send(.fingerAdded(uiTouchID: touch.id, location: touch.position))
        await clock.advance(by: .seconds(0.8))
        
        #expect(audioSpy.playAddCount == 1)
    }

    @Test func detectionTimerFiresCountdownWithTwoFingers() async {
        let audioSpy = AudioSpy()
        let feedbackSpy = FeedbackSpy()
        let clock = TestClock()

        let touches = [TouchMock](count: 2)
        let store = TestStoreOf<SelectionFeature>(clock: clock) {
            $0.audioClient = audioSpy.client()
            $0.feedbackClient = feedbackSpy.client()
        }

        await store.send(.fingerAdded(uiTouchID: touches[0].id, location: touches[0].position))
        await store.send(.fingerAdded(uiTouchID: touches[1].id, location: touches[1].position))
        await clock.advance(by: .seconds(0.8))
        await store.receive(\.detectionTimerFired)
        await store.receive(\.countdownTick) { $0.phase = .countdown(3) }

        #expect(feedbackSpy.lightCount == 1)
        #expect(feedbackSpy.heavyCount == 0)
        #expect(audioSpy.playAddCount == 2)
        #expect(audioSpy.playCountdownCount == 1)
        #expect(audioSpy.playDecisionCount == 0)
    }

    @Test func fullCountdownLeadsToSelection() async {
        let audioSpy = AudioSpy()
        let feedbackSpy = FeedbackSpy()
        let storeKitSpy = StoreKitSpy()
        let clock = TestClock()

        let touches = [TouchMock](count: 2)
        let store = TestStoreOf<SelectionFeature>(clock: clock) {
            $0.audioClient = audioSpy.client()
            $0.feedbackClient = feedbackSpy.client()
            $0.storeKitClient = storeKitSpy.client()
        }

        await store.send(.fingerAdded(uiTouchID: touches[0].id, location: touches[0].position))
        await store.send(.fingerAdded(uiTouchID: touches[1].id, location: touches[1].position))
        await clock.advance(by: .seconds(0.8))
        await store.receive(\.detectionTimerFired)
        await store.receive(\.countdownTick) { $0.phase = .countdown(3) }
        await clock.advance(by: .seconds(1))
        await store.receive(\.countdownTick) { $0.phase = .countdown(2) }
        await clock.advance(by: .seconds(1))
        await store.receive(\.countdownTick) { $0.phase = .countdown(1) }
        await clock.advance(by: .seconds(1))
        await store.receive(\.selectionMade) { state in
            if case .selectionFinished(let id) = state.phase {
                #expect(touches.map(\.uuid).contains(id))
            }
        }

        #expect(feedbackSpy.lightCount == 3)
        #expect(feedbackSpy.heavyCount == 1)
        #expect(audioSpy.playAddCount == 2)
        #expect(audioSpy.playCountdownCount == 3)
        #expect(audioSpy.playDecisionCount == 1)

        await clock.advance(by: .seconds(1))
        #expect(storeKitSpy.reviewRequestCount == 1)
    }

    @Test func addingFingerDuringCountdownRestartsCountdown() async {
        let audioSpy = AudioSpy()
        let feedbackSpy = FeedbackSpy()
        let clock = TestClock()

        let touches = [TouchMock](count: 2)
        let addedTouch = TouchMock(uuid: UUID(0))
        let store = TestStoreOf<SelectionFeature>(
            initialState: .init(phase: .countdown(2), touches: touches.map(\.point)),
            clock: clock
        ) {
            $0.feedbackClient = feedbackSpy.client()
            $0.audioClient = audioSpy.client()
        }

        await store.send(.fingerAdded(uiTouchID: addedTouch.id, location: addedTouch.position)) {
            $0.phase = .collecting
            $0.touches = (touches + [addedTouch]).map(\.point)
        }
        await clock.advance(by: .seconds(0.8))
        await store.receive(\.detectionTimerFired)
        await store.receive(\.countdownTick) { $0.phase = .countdown(3) }

        await clock.advance(by: .seconds(1))
        await store.receive(\.countdownTick) { $0.phase = .countdown(2) }

        #expect(feedbackSpy.lightCount == 2)
        #expect(feedbackSpy.heavyCount == 0)
        #expect(audioSpy.playAddCount == 1)
        #expect(audioSpy.playCountdownCount == 2)
        #expect(audioSpy.playDecisionCount == 0)
    }

    @Test func removingFingerDuringCountdownResetsPhase() async {
        let clock = TestClock()
        let feedbackSpy = FeedbackSpy()
        let audioSpy = AudioSpy()

        let touches = [TouchMock](count: 3)
        let store = TestStoreOf<SelectionFeature>(
            initialState: .init(phase: .countdown(2), touches: touches.map(\.point)),
            clock: clock
        ) {
            $0.feedbackClient = feedbackSpy.client()
            $0.audioClient = audioSpy.client()
        }

        await store.send(.fingerRemoved(uiTouchID: touches[0].id)) {
            $0.phase = .collecting
            $0.touches = [touches[1].point, touches[2].point]
        }
        await clock.advance(by: .seconds(0.8))
        await store.receive(\.detectionTimerFired)
        await store.receive(\.countdownTick) { $0.phase = .countdown(3) }

        #expect(feedbackSpy.lightCount == 1)
        #expect(feedbackSpy.heavyCount == 0)
        #expect(audioSpy.playRemoveCount == 1)
        #expect(audioSpy.playCountdownCount == 1)
        #expect(audioSpy.playDecisionCount == 0)
    }

    @Test func removingFingerDuringCountdownWithOnlyOneRemainingCancelsCompletely() async {
        let audioSpy = AudioSpy()
        let clock = TestClock()

        let touches = [TouchMock](count: 2)
        let store = TestStoreOf<SelectionFeature>(
            initialState: .init(phase: .countdown(2), touches: touches.map(\.point)),
            clock: clock
        ) {
            $0.audioClient = audioSpy.client()
        }

        await store.send(.fingerRemoved(uiTouchID: touches[1].id)) {
            $0.phase = .collecting
            $0.touches = [touches[0].point]
        }
        
        #expect(audioSpy.playRemoveCount == 1)
    }

    @Test func sixthFingerIsIgnored() async {
        let clock = TestClock()

        let touches = [TouchMock](count: 5)
        let sixthTouch = TouchMock(uuid: UUID(5))
        let store = TestStoreOf<SelectionFeature>(
            initialState: .init(phase: .countdown(2), touches: touches.map(\.point)),
            clock: clock
        )

        await store.send(.fingerAdded(uiTouchID: sixthTouch.id, location: sixthTouch.position))
    }
}

// MARK: - Helpers

private final class TouchMock {
    var uuid: UUID
    var position: CGPoint
    var isPulsing: Bool
    var isSelected: Bool

    init(uuid: UUID, position: CGPoint = .zero, isPulsing: Bool = false, isSelected: Bool = false) {
        self.uuid = uuid
        self.position = position
        self.isPulsing = isPulsing
        self.isSelected = isSelected
    }

    var id: ObjectIdentifier { ObjectIdentifier(self) }
    var point: TouchPoint {
        TouchPoint(
            id: uuid,
            uiTouchID: id,
            position: position,
            isPulsing: isPulsing,
            isSelected: isSelected
        )
    }
}

private final class FeedbackSpy: @unchecked Sendable {
    var lightCount = 0
    var heavyCount = 0

    func client() -> FeedbackClient {
        FeedbackClient(
            prepare: {},
            light: { self.lightCount += 1 },
            heavy: { self.heavyCount += 1 }
        )
    }
}

private final class AudioSpy: @unchecked Sendable {
    var playAddCount = 0
    var playRemoveCount = 0
    var playCountdownCount = 0
    var playDecisionCount = 0

    func client() -> AudioClient {
        AudioClient(
            playAdd: { self.playAddCount += 1 },
            playRemove: { self.playRemoveCount += 1 },
            playCountdown: { self.playCountdownCount += 1 },
            playDecision: { self.playDecisionCount += 1 }
        )
    }
}

private final class StoreKitSpy: @unchecked Sendable {
    var reviewRequestCount = 0

    func client() -> StoreKitClient {
        StoreKitClient(
            requestReview: { self.reviewRequestCount += 1 }
        )
    }
}

extension TestStoreOf<SelectionFeature> {
    convenience init(
        initialState: SelectionFeature.State = .init(phase: .collecting),
        clock: any Clock<Duration> = ImmediateClock(),
        uuid: UUIDGenerator = .incrementing,
        exhaustivity: Exhaustivity = .off,
        configure: (inout DependencyValues) -> Void = { _ in }
    ) {
        self.init(initialState: initialState) {
            SelectionFeature()
        } withDependencies: {
            $0.uuid = uuid
            $0.continuousClock = clock
            configure(&$0)
        }
        self.exhaustivity = exhaustivity
    }
}

extension [TouchMock] {
    init(count: Int) {
        self = (0..<count).map {
            TouchMock(
                uuid: UUID($0),
                position: .init(x: 10 + count, y: 10 + count)
            )
        }
    }
}
