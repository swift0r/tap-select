// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import AVFoundation
import Dependencies
import DependenciesMacros

@DependencyClient
struct AudioClient: Sendable {
    var prepare: @Sendable () async -> Void
    var playAdd: @Sendable () async -> Void
    var playRemove: @Sendable () async -> Void
    var playCountdown: @Sendable () async -> Void
    var playDecision: @Sendable () async -> Void
}

extension AudioClient: DependencyKey {
    static let liveValue: Self = {
        let actor = AudioActor()
        return Self(
            prepare: { await actor.prepare() },
            playAdd: { await actor.playAdd() },
            playRemove: { await actor.playRemove() },
            playCountdown: { await actor.playCountdown() },
            playDecision: { await actor.playDecision() }
        )
    }()
}

private actor AudioActor {
    let add: AVAudioPlayer?
    let remove: AVAudioPlayer?
    let countdown: AVAudioPlayer?
    let decision: AVAudioPlayer?

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        add = Self.makePlayer(for: .add)
        remove = Self.makePlayer(for: .remove)
        countdown = Self.makePlayer(for: .countdown)
        decision = Self.makePlayer(for: .decision)
    }

    func prepare() {
        add?.prepareToPlay()
        remove?.prepareToPlay()
        countdown?.prepareToPlay()
        decision?.prepareToPlay()
    }

    func playAdd() {
        add?.play()
    }

    func playRemove() {
        remove?.play()
    }
    
    func playCountdown() {
        countdown?.play()
    }

    func playDecision() {
        countdown?.stop()
        decision?.play()
    }

    private static func makePlayer(for sound: Sound) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: sound.extension) else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        return player
    }
}

extension AudioClient: TestDependencyKey {
    static let testValue = Self()
    static let previewValue = Self.noop
}

extension AudioClient {
    static let noop = Self(
        prepare: {},
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
