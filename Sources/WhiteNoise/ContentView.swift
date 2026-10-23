import SwiftUI

struct ContentView: View {
    @Bindable var model: NoiseModel
    @Namespace private var glass

    private let timerOptions = [15, 30, 60, 90, 120]

    var body: some View {
        GlassEffectContainer(spacing: 16) {
            VStack(spacing: 22) {
                playButton
                VStack(spacing: 10) {
                    modePicker
                    blurb
                }
                volumeBar
                timerBar
            }
            .padding(24)
        }
        .animation(.smooth(duration: 0.4), value: model.mode)
        .animation(.smooth(duration: 0.4), value: model.isPlaying)
        .animation(.smooth(duration: 0.4), value: model.timerEnd)
    }

    private var playButton: some View {
        Button(action: model.toggle) {
            Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 40, weight: .semibold))
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 112, height: 112)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .help(model.isPlaying ? "Stop" : "Play")
    }

    private var modePicker: some View {
        HStack(spacing: 4) {
            ForEach(Mode.allCases) { mode in
                Button { model.mode = mode } label: {
                    VStack(spacing: 4) {
                        Image(systemName: mode.symbol)
                            .font(.title3)
                            .frame(height: 24)
                        Text(mode.name)
                            .font(.caption.weight(model.mode == mode ? .semibold : .regular))
                    }
                    .foregroundStyle(model.mode == mode ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(.rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .background {
                    if model.mode == mode {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.clear)
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
                            .glassEffectID("selection", in: glass)
                    }
                }
            }
        }
        .padding(4)
        .glassEffect(in: .rect(cornerRadius: 18))
    }

    private var blurb: some View {
        Text(model.mode.blurb)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 30)
            .id(model.mode)
            .transition(.blurReplace)
    }

    private var volumeBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "speaker.fill")
            Slider(value: $model.volume, in: 0...1)
            Image(systemName: "speaker.wave.3.fill")
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassEffect(in: .capsule)
    }

    private var timerBar: some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(timerOptions, id: \.self) { minutes in
                    Button(minutes < 60 ? "\(minutes) min" : "\(Double(minutes) / 60, specifier: "%g") hr") {
                        model.setTimer(minutes: minutes)
                    }
                }
                if model.timerEnd != nil {
                    Divider()
                    Button("Cancel Timer", role: .destructive) { model.setTimer(minutes: nil) }
                }
            } label: {
                Label("Timer", systemImage: "timer")
                    .padding(.horizontal, 6)
            }
            .menuIndicator(.hidden)
            .buttonStyle(.glass)
            .fixedSize()

            if let end = model.timerEnd {
                Text(timerInterval: Date.now...end, countsDown: true)
                    .monospacedDigit()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .glassEffect(in: .capsule)
                    .glassEffectID("countdown", in: glass)
                    .transition(.blurReplace)
            }

            Spacer()

            Button { NSApp.terminate(nil) } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.glass)
            .help("Quit White Noise")
        }
    }
}
