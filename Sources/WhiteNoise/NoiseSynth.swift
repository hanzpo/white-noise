import Foundation

/// Listening intents, each mapped to a noise recipe grounded in the research summarized in README.md.
enum Mode: Int, CaseIterable, Identifiable {
    case focus, mask, sleep, calm

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .focus: "Focus"
        case .mask: "Mask"
        case .sleep: "Sleep"
        case .calm: "Calm"
        }
    }

    var symbol: String {
        switch self {
        case .focus: "scope"
        case .mask: "person.2.wave.2"
        case .sleep: "moon.zzz"
        case .calm: "water.waves"
        }
    }

    var blurb: String {
        switch self {
        case .focus: "Steady pink noise. Helps attention most if you're easily distracted. Keep it low."
        case .mask: "Shaped to the speech band to cover chatter, calls and TV."
        case .sleep: "Deep brown noise with no hiss. Keep it quiet and set a timer to fade out."
        case .calm: "Slow ten-second swells, like surf. Breathe along with them."
        }
    }
}

/// Sample-by-sample noise generator. Pure DSP, no audio framework, so it can run anywhere.
struct NoiseSynth {
    var mode: Mode = .focus

    private let sampleRate: Float
    private var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
    private var pinkState: (Float, Float, Float, Float, Float, Float, Float) = (0, 0, 0, 0, 0, 0, 0)
    private var brownState: Float = 0
    private var lowpass: Float = 0
    private var highpass: Float = 0
    private var phase: Float = 0

    init(sampleRate: Double) {
        self.sampleRate = Float(sampleRate)
    }

    mutating func next() -> Float {
        let w = white()
        switch mode {
        case .focus:
            return pink(w) * 0.77
        case .mask:
            // Pink, band-limited to roughly 150 Hz – 4 kHz where speech energy lives
            let p = pink(w)
            let low = onePole(&highpass, p, cutoff: 150)
            return onePole(&lowpass, p - low, cutoff: 4000) * 1.3
        case .sleep:
            // Brown with the remaining hiss rolled off
            return onePole(&lowpass, brown(w), cutoff: 900) * 0.8
        case .calm:
            // A 0.1 Hz swell that both opens a lowpass and raises the level, like a breaking wave
            phase += 0.1 / sampleRate
            if phase >= 1 { phase -= 1 }
            let swell = pow(0.5 - 0.5 * cos(2 * .pi * phase), 1.6)
            let filtered = onePole(&lowpass, pink(w), cutoff: 250 + 2200 * swell)
            return filtered * (0.15 + 0.85 * swell) * 1.3
        }
    }

    // MARK: - Building blocks

    /// Uniform white noise in [-1, 1] via xorshift64*, cheap enough for the render thread.
    private mutating func white() -> Float {
        seed ^= seed >> 12
        seed ^= seed << 25
        seed ^= seed >> 27
        let bits = (seed &* 0x2545_F491_4F6C_DD1D) >> 40
        return Float(bits) / Float(1 << 23) - 1
    }

    /// Paul Kellet's refined pink noise filter.
    private mutating func pink(_ w: Float) -> Float {
        var s = pinkState
        s.0 = 0.99886 * s.0 + w * 0.0555179
        s.1 = 0.99332 * s.1 + w * 0.0750759
        s.2 = 0.96900 * s.2 + w * 0.1538520
        s.3 = 0.86650 * s.3 + w * 0.3104856
        s.4 = 0.55000 * s.4 + w * 0.5329522
        s.5 = -0.7616 * s.5 - w * 0.0168980
        let out = s.0 + s.1 + s.2 + s.3 + s.4 + s.5 + s.6 + w * 0.5362
        s.6 = w * 0.115926
        pinkState = s
        return out * 0.11
    }

    /// Leaky integrator over white noise.
    private mutating func brown(_ w: Float) -> Float {
        brownState = (brownState + 0.02 * w) / 1.02
        return brownState * 3.5
    }

    private func onePole(_ state: inout Float, _ x: Float, cutoff: Float) -> Float {
        state += (1 - exp(-2 * .pi * cutoff / sampleRate)) * (x - state)
        return state
    }
}
