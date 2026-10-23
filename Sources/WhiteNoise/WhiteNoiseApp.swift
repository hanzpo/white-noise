import SwiftUI

@main
struct WhiteNoiseApp: App {
    @State private var model = NoiseModel()

    var body: some Scene {
        Window("White Noise", id: "main") {
            ContentView(model: model)
                .frame(width: 360)
                .glassEffect(.regular, in: .rect(cornerRadius: 26))
                .containerBackground(.clear, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .windowResizability(.contentSize)
        .commands {
            CommandMenu("Playback") {
                Button(model.isPlaying ? "Stop" : "Play") { model.toggle() }
                    .keyboardShortcut(.space, modifiers: [])
            }
        }

        MenuBarExtra {
            ContentView(model: model)
                .frame(width: 320)
        } label: {
            Image(systemName: model.isPlaying ? "waveform" : "waveform.slash")
        }
        .menuBarExtraStyle(.window)
    }
}
