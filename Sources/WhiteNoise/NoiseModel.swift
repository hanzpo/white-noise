import Foundation
import Observation

@MainActor
@Observable
final class NoiseModel {
    private let engine = NoiseEngine()
    private var timerTask: Task<Void, Never>?

    private(set) var isPlaying = false
    private(set) var timerEnd: Date?
    /// 1 normally, ramps to 0 over the last stretch of the sleep timer.
    private var fade: Double = 1 {
        didSet { applyVolume() }
    }

    var mode: Mode = .focus {
        didSet { engine.setMode(mode) }
    }

    var volume: Double = 0.5 {
        didSet { applyVolume() }
    }

    func toggle() { isPlaying ? stop() : play() }

    func play() {
        engine.play()
        isPlaying = true
    }

    func stop() {
        engine.stop()
        isPlaying = false
        cancelTimer()
    }

    /// Stop playback after `minutes`, fading out gradually so the ending doesn't wake you. Pass nil to clear.
    func setTimer(minutes: Int?) {
        cancelTimer()
        guard let minutes else { return }
        if !isPlaying { play() }
        let total = TimeInterval(minutes * 60)
        let fadeLength = min(10 * 60, total / 2)
        let start = Date()
        timerEnd = start.addingTimeInterval(total)
        timerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(total - fadeLength))
            while !Task.isCancelled {
                let remaining = total - Date().timeIntervalSince(start)
                guard remaining > 0 else { break }
                // Squared ramp sounds closer to linear in perceived loudness
                let progress = remaining / fadeLength
                self?.fade = progress * progress
                try? await Task.sleep(for: .milliseconds(250))
            }
            guard !Task.isCancelled else { return }
            self?.stop()
        }
    }

    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        timerEnd = nil
        fade = 1
    }

    private func applyVolume() {
        engine.volume = Float(volume * fade)
    }
}
