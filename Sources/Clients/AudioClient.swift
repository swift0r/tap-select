// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import AudioToolbox
import Dependencies
import DependenciesMacros

@DependencyClient
struct AudioClient: Sendable {
    var playAdd: @Sendable () async -> Void
    var playRemove: @Sendable () async -> Void
    var playCountdown: @Sendable () async -> Void
    var playDecision: @Sendable () async -> Void
}

extension AudioClient: DependencyKey {
    static let liveValue: Self = {
        let actor = AudioActor()
        return Self(
            playAdd: { await actor.playAdd() },
            playRemove: { await actor.playRemove() },
            playCountdown: { await actor.playCountdown() },
            playDecision: { await actor.playDecision() }
        )
    }()
}

private actor AudioActor {
    private var soundAdd: SystemSoundID?
    private var soundRemove: SystemSoundID?
    private var soundCountdown: SystemSoundID?
    private var soundDecision: SystemSoundID?

    init() {
        soundAdd = Self.makeSystemSound(for: .add)
        soundRemove = Self.makeSystemSound(for: .remove)
        soundCountdown = Self.makeSystemSound(for: .countdown)
        soundDecision = Self.makeSystemSound(for: .decision)
    }

    func playAdd() {
        soundAdd.map { AudioServicesPlaySystemSound($0) }
    }

    func playRemove() {
        soundRemove.map { AudioServicesPlaySystemSound($0) }
    }
    
    func playCountdown() {
        soundCountdown.map { AudioServicesPlaySystemSound($0) }
    }

    func playDecision() {
        soundDecision.map { AudioServicesPlaySystemSound($0) }
    }

    private static func makeSystemSound(for sound: Sound) -> SystemSoundID? {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: sound.extension) else { return nil }
        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        return status == noErr ? soundID : nil
    }
}

extension AudioClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.noop
}

extension AudioClient {
    static let noop = Self(
        playAdd: {},
        playRemove: {},
        playCountdown: {},
        playDecision: {}
    )
}

extension DependencyValues {
    var audioClient: AudioClient {
        get { self[AudioClient.self] }
        set { self[AudioClient.self] = newValue }
    }
}
