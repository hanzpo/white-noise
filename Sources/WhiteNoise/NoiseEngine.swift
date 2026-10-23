import AVFoundation

enum NoiseColor: Int, CaseIterable, Identifiable {
    case white, pink, brown

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .white: "White"
        case .pink: "Pink"
        case .brown: "Brown"
        }
    }

    var blurb: String {
        switch self {
        case .white: "Flat across all frequencies. Bright and hissy."
        case .pink: "Equal energy per octave. Softer, like steady rain."
        case .brown: "Heavy on the lows. Deep rumble, like a waterfall."
        }
    }
}

/// Generates noise in real time on the audio render thread.
/// State touched by the render block is plain scalars; races on them are benign.
final class NoiseEngine {
    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode!

    // Render-thread state
    private var color: NoiseColor = .white
    private var targetGain: Float = 0
    private var gain: Float = 0
    private var rng = SystemRandomNumberGenerator()
    private var pink = (b0: Float(0), b1: Float(0), b2: Float(0), b3: Float(0), b4: Float(0), b5: Float(0), b6: Float(0))
    private var brown: Float = 0

    var volume: Float {
        get { engine.mainMixerNode.outputVolume }
        set { engine.mainMixerNode.outputVolume = newValue }
    }

    init() {
        let format = engine.outputNode.inputFormat(forBus: 0)
        let mono = AVAudioFormat(standardFormatWithSampleRate: format.sampleRate, channels: 1)!
        // ~50 ms fade so start/stop/switch never clicks
        let smoothing = Float(1 - exp(-1 / (0.05 * format.sampleRate)))

        source = AVAudioSourceNode(format: mono) { [unowned self] _, _, frameCount, bufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            guard let out = buffers.first?.mData?.assumingMemoryBound(to: Float.self) else { return noErr }
            for i in 0..<Int(frameCount) {
                gain += (targetGain - gain) * smoothing
                out[i] = nextSample() * gain
            }
            return noErr
        }
        engine.attach(source)
        do { try engine.connectNode(source, to: engine.mainMixerNode, format: mono) } catch { print("Audio graph failed to connect: \(error)") }
        engine.mainMixerNode.outputVolume = 0.5
    }

    func setColor(_ newColor: NoiseColor) { color = newColor }

    func play() {
        if !engine.isRunning {
            do { try engine.start() } catch { print("Audio engine failed to start: \(error)"); return }
        }
        targetGain = 1
    }

    func stop() { targetGain = 0 }

    private func nextSample() -> Float {
        let white = Float(Int32(truncatingIfNeeded: rng.next())) / Float(Int32.max)
        switch color {
        case .white:
            return white * 0.5
        case .pink:
            // Paul Kellet's refined pink noise filter
            pink.b0 = 0.99886 * pink.b0 + white * 0.0555179
            pink.b1 = 0.99332 * pink.b1 + white * 0.0750759
            pink.b2 = 0.96900 * pink.b2 + white * 0.1538520
            pink.b3 = 0.86650 * pink.b3 + white * 0.3104856
            pink.b4 = 0.55000 * pink.b4 + white * 0.5329522
            pink.b5 = -0.7616 * pink.b5 - white * 0.0168980
            let out = pink.b0 + pink.b1 + pink.b2 + pink.b3 + pink.b4 + pink.b5 + pink.b6 + white * 0.5362
            pink.b6 = white * 0.115926
            return out * 0.11
        case .brown:
            // Leaky integrator over white noise
            brown = (brown + 0.02 * white) / 1.02
            return brown * 3.5
        }
    }
}
