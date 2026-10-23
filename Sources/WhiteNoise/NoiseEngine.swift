import AVFoundation

/// Runs a `NoiseSynth` on the audio render thread.
/// `requestedMode` and `targetGain` are plain scalars written from the main thread; races on them are benign.
final class NoiseEngine {
    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode!

    // Render-thread state
    private var synth: NoiseSynth
    private var requestedMode: Mode = .focus
    private var targetGain: Float = 0
    private var gain: Float = 0

    var volume: Float {
        get { engine.mainMixerNode.outputVolume }
        set { engine.mainMixerNode.outputVolume = newValue }
    }

    init() {
        let format = engine.outputNode.inputFormat(forBus: 0)
        let mono = AVAudioFormat(standardFormatWithSampleRate: format.sampleRate, channels: 1)!
        synth = NoiseSynth(sampleRate: format.sampleRate)
        // ~50 ms fade so start/stop never clicks
        let smoothing = Float(1 - exp(-1 / (0.05 * format.sampleRate)))

        source = AVAudioSourceNode(format: mono) { [unowned self] _, _, frameCount, bufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            guard let out = buffers.first?.mData?.assumingMemoryBound(to: Float.self) else { return noErr }
            if synth.mode != requestedMode { synth.mode = requestedMode }
            for i in 0..<Int(frameCount) {
                gain += (targetGain - gain) * smoothing
                out[i] = synth.next() * gain
            }
            return noErr
        }
        engine.attach(source)
        do { try engine.connectNode(source, to: engine.mainMixerNode, format: mono) } catch { print("Audio graph failed to connect: \(error)") }
        engine.mainMixerNode.outputVolume = 0.5
    }

    func setMode(_ mode: Mode) { requestedMode = mode }

    func play() {
        if !engine.isRunning {
            do { try engine.start() } catch { print("Audio engine failed to start: \(error)"); return }
        }
        targetGain = 1
    }

    func stop() { targetGain = 0 }
}
