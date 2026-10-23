import Foundation
import Observation

@MainActor
@Observable
final class NoiseModel {
    private let engine = NoiseEngine()
    private var timerTask: Task<Void, Never>?

    private(set) var isPlaying = false
    private(set) var timerEnd: Date?

    var color: NoiseColor = .white {
        didSet { engine.setColor(color) }
    }

    var volume: Double = 0.5 {
        didSet { engine.volume = Float(volume) }
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

    /// Stop playback after `minutes`. Pass nil to clear.
    func setTimer(minutes: Int?) {
        cancelTimer()
        guard let minutes else { return }
        if !isPlaying { play() }
        let end = Date().addingTimeInterval(TimeInterval(minutes * 60))
        timerEnd = end
        timerTask = Task { [weak self] in
            try? await Task.sleep(until: .now + .seconds(minutes * 60), clock: .continuous)
            guard !Task.isCancelled else { return }
            self?.stop()
        }
    }

    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        timerEnd = nil
    }
}
