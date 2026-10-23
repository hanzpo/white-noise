import SwiftUI

@main
struct WhiteNoiseApp: App {
    @State private var model = NoiseModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView(model: model)
                .frame(width: 320)
        } label: {
            Image(systemName: model.isPlaying ? "waveform" : "waveform.slash")
        }
        .menuBarExtraStyle(.window)
    }
}
