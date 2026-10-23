import SwiftUI

struct ContentView: View {
    @Bindable var model: NoiseModel
    @Namespace private var glass

    private let timerOptions = [15, 30, 60, 90, 120]

    var body: some View {
        GlassEffectContainer(spacing: 16) {
            VStack(spacing: 22) {
                playButton
                colorPicker
                volumeBar
                timerBar
            }
            .padding(24)
        }
        .animation(.smooth(duration: 0.4), value: model.color)
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

    private var colorPicker: some View {
        HStack(spacing: 6) {
            ForEach(NoiseColor.allCases) { color in
                Button { model.color = color } label: {
                    Text(color.name)
                        .font(.callout.weight(model.color == color ? .semibold : .regular))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .background {
                    if model.color == color {
                        Capsule()
                            .fill(.clear)
                            .glassEffect(.regular.interactive(), in: .capsule)
                            .glassEffectID("selection", in: glass)
                    }
                }
            }
        }
        .padding(4)
        .glassEffect(in: .capsule)
        .overlay(alignment: .bottom) {
            Text(model.color.blurb)
                .font(.caption)
                .foregroundStyle(.secondary)
                .offset(y: 22)
                .id(model.color)
                .transition(.blurReplace)
        }
        .padding(.bottom, 14)
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
                Label("Sleep Timer", systemImage: "moon.zzz.fill")
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
        }
    }
}
