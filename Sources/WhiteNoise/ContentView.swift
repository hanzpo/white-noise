import SwiftUI

extension NoiseColor {
    /// Palette for the background mesh and glass tint.
    var palette: [Color] {
        switch self {
        case .white: [.init(white: 0.92), .cyan.opacity(0.5), .indigo.opacity(0.45), .init(white: 0.75)]
        case .pink: [.pink.opacity(0.7), .purple.opacity(0.6), .orange.opacity(0.45), .pink.opacity(0.35)]
        case .brown: [.brown, .orange.opacity(0.7), .init(red: 0.3, green: 0.18, blue: 0.1), .yellow.opacity(0.4)]
        }
    }

    var tint: Color { palette[1] }
}

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
        .background { FlowingBackground(color: model.color, isPlaying: model.isPlaying) }
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
        .glassEffect(.regular.tint(model.isPlaying ? model.color.tint.opacity(0.35) : nil).interactive(), in: .circle)
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
                            .glassEffect(.regular.tint(color.tint.opacity(0.5)).interactive(), in: .capsule)
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
                .tint(model.color.tint)
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

/// Slowly drifting mesh gradient for the glass to refract. Freezes when paused.
struct FlowingBackground: View {
    let color: NoiseColor
    let isPlaying: Bool

    var body: some View {
        TimelineView(.animation(paused: !isPlaying)) { context in
            let t = Float(context.date.timeIntervalSinceReferenceDate)
            let c = color.palette
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5 + 0.2 * sin(t * 0.4), 0.5 + 0.2 * cos(t * 0.3)], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1],
                ],
                colors: [c[0], c[1], c[2], c[3], c[0], c[1], c[2], c[3], c[0]]
            )
        }
        .ignoresSafeArea()
    }
}
